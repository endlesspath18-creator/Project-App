import { Request, Response } from "express";
import { prisma } from "../../config/db";
import { sendResponse, sendError } from "../../utils/response";
import { createRazorpayOrder, verifyRazorpaySignature, verifyWebhookSignature } from "../../services/razorpayService";
import { env } from "../../config/env";


/**
 * Creates a new booking with "Pay First" / "Instant Booking" logic.
 * The booking is created in PAYMENT_PENDING state and a Razorpay Order is returned immediately.
 * The slot is held for 15 minutes.
 */
export const createBooking = async (req: Request, res: Response) => {
  const userId = req.user!.id;
  const { serviceId, scheduledDate, address, notes, idempotencyKey, paymentMethod } = req.body;
  const method = paymentMethod === "COD" ? "COD" : "ONLINE";

  try {
    // 0. Check idempotency
    if (idempotencyKey) {
      const existing = await prisma.booking.findUnique({ 
        where: { idempotencyKey },
        include: { service: true, provider: true }
      });
      if (existing) return sendResponse(res, 200, "Booking already exists", existing);
    }

    const result = await prisma.$transaction(async (tx) => {
      // 1. Check if service is available
      const service = await tx.service.findUnique({ 
        where: { id: serviceId },
        include: { provider: { include: { providerProfile: true } } } 
      });

      if (!service) throw new Error("SERVICE_NOT_FOUND");
      if (!service.isActive) throw new Error("SERVICE_INACTIVE");

      const requestedStart = new Date(scheduledDate);
      const requestedEnd = new Date(requestedStart.getTime() + service.durationMinutes * 60000);

      // 1.5 Check for overlapping bookings (Instant check) using Prisma API for better compatibility
      const overlap = await tx.booking.findFirst({
        where: {
          providerId: service.providerId,
          status: { notIn: ["CANCELLED", "REJECTED", "EXPIRED", "PAYMENT_FAILED"] },
          AND: [
            { dateTime: { lt: requestedEnd } },
            { 
              OR: [
                // If we don't have durationMinutes in DB for some reason, assume 60
                { dateTime: { gt: new Date(requestedStart.getTime() - 24 * 60 * 60000) } } 
              ]
            }
          ]
        }
      });

      // Refined overlap check logic (Since raw SQL "interval" is tricky across DBs)
      // We'll fetch potential overlaps and filter in JS if needed, but for now let's use a simpler range
      const potentialOverlaps = await tx.booking.findMany({
        where: {
          providerId: service.providerId,
          status: { notIn: ["CANCELLED", "REJECTED", "EXPIRED", "PAYMENT_FAILED"] },
          dateTime: {
            gte: new Date(requestedStart.getTime() - 4 * 60 * 60000), // 4 hours before
            lte: new Date(requestedStart.getTime() + 4 * 60 * 60000), // 4 hours after
          }
        }
      });

      for (const b of potentialOverlaps) {
        const bStart = b.dateTime.getTime();
        const bEnd = bStart + (b.durationMinutes || 60) * 60000;
        if (requestedStart.getTime() < bEnd && requestedEnd.getTime() > bStart) {
          throw new Error("PROVIDER_BUSY");
        }
      }

      // 2. Create the booking
      const holdExpiresAt = method === "ONLINE" ? new Date(Date.now() + 15 * 60 * 1000) : null;
      const initialStatus = method === "ONLINE" ? "PAYMENT_PENDING" : "REQUESTED";

      const newBooking = await tx.booking.create({
        data: {
          userId,
          providerId: service.providerId,
          serviceId,
          dateTime: requestedStart,
          slot: req.body.slot || "Unspecified Slot",
          durationMinutes: service.durationMinutes,
          address,
          notes,
          amount: service.price,
          paymentMethod: method,
          status: initialStatus,
          holdExpiresAt,
          idempotencyKey
        }
      });

      let order = null;
      if (method === "ONLINE") {
        // 3. Initiate Razorpay Order immediately
        order = await createRazorpayOrder(service.price, newBooking.id);

        // 4. Update booking with Order ID
        await tx.booking.update({
          where: { id: newBooking.id },
          data: { orderId: order.id }
        });
      }

      // 5. Log event
      await tx.bookingEvent.create({
        data: {
          bookingId: newBooking.id,
          fromStatus: "DRAFT",
          toStatus: initialStatus,
          actorId: userId,
          meta: method === "ONLINE" ? { razorpayOrderId: order?.id } : { method: "COD" }
        }
      });

      return { 
        booking: newBooking, 
        razorpayOrder: order,
        key: order ? env.RAZORPAY_KEY_ID : null
      };
    });

    const successMsg = method === "ONLINE" 
      ? "Booking initiated. Complete payment to confirm." 
      : "Booking requested successfully.";
    sendResponse(res, 201, successMsg, result);
  } catch (error: any) {
    if (error.message === "SERVICE_NOT_FOUND") return sendError(res, 404, "Service not found");
    if (error.message === "SERVICE_INACTIVE") return sendError(res, 400, "This service is currently disabled");
    if (error.message === "PROVIDER_BUSY") return sendError(res, 409, "Provider is already booked for this time slot");
    if (error.message === "RAZORPAY_ORDER_FAILED") {
       return sendError(res, 502, "Failed to connect to payment gateway. Please verify RAZORPAY_KEY_ID and RAZORPAY_KEY_SECRET in Render environment variables.");
    }
    
    console.error("Booking Error Detail:", error);
    // Returning the actual error message to the client temporarily for easier production debugging
    sendError(res, 500, `Failed to initiate booking: ${error.message || 'Unknown Error'}`);
  }
};

/**
 * Confirms payment from the client-side callback.
 */
export const confirmPayment = async (req: Request, res: Response) => {
  const { bookingId, razorpayPaymentId, razorpayOrderId, razorpaySignature } = req.body;
  const userId = req.user!.id;

  try {
    // 0. Idempotency Check
    const existing = await prisma.booking.findUnique({ where: { id: bookingId } });
    if (existing?.status === "CONFIRMED") return sendResponse(res, 200, "Booking already confirmed", existing);

    // 1. Verify Signature
    const isValid = verifyRazorpaySignature(razorpayOrderId, razorpayPaymentId, razorpaySignature);
    if (!isValid) return sendError(res, 400, "Invalid payment signature.");

    const result = await prisma.$transaction(async (tx) => {
      const booking = await tx.booking.findUnique({ where: { id: bookingId } });
      if (!booking || booking.userId !== userId) throw new Error("AUTH_ERROR");

      // Verify that this payment is for the correct Razorpay Order tied to this booking
      if (booking.orderId !== razorpayOrderId) {
        throw new Error("ORDER_MISMATCH");
      }

      const updated = await tx.booking.update({
        where: { id: bookingId },
        data: {
          status: "CONFIRMED",
          paymentStatus: "PAID",
          paymentId: razorpayPaymentId,
          orderId: razorpayOrderId,
          holdExpiresAt: null
        }
      });

      await tx.bookingEvent.create({
        data: {
          bookingId,
          fromStatus: booking.status,
          toStatus: "CONFIRMED",
          actorId: userId,
          meta: { method: "CLIENT_CONFIRM", razorpayPaymentId }
        }
      });

      // Create a notification for the provider
      await tx.notification.create({
        data: {
          userId: booking.providerId,
          title: "New Confirmed Booking!",
          message: `You have a new booking confirmed for ${booking.slot}. Check your dashboard.`,
          type: "BOOKING_CONFIRMED"
        }
      });

      return updated;
    });

    sendResponse(res, 200, "Payment confirmed successfully", result);
  } catch (error: any) {
    if (error.message === "AUTH_ERROR") return sendError(res, 401, "Not authorized to confirm this booking");
    if (error.message === "ORDER_MISMATCH") return sendError(res, 400, "Payment order ID does not match booking records");
    console.error("Payment Confirmation Error:", error);
    sendError(res, 500, "Payment confirmation failed");
  }
};

/**
 * Explicitly mark a booking as failed if user cancels payment or gateway fails.
 */
export const handlePaymentFailure = async (req: Request, res: Response) => {
  const { bookingId, reason } = req.body;
  const userId = req.user!.id;

  try {
    const booking = await prisma.booking.findUnique({ where: { id: bookingId } });
    if (!booking || booking.userId !== userId) return sendError(res, 404, "Booking not found");

    if (booking.status !== "PAYMENT_PENDING") {
      return sendError(res, 400, "Only pending payments can be marked as failed");
    }

    const updated = await prisma.booking.update({
      where: { id: bookingId },
      data: { 
        status: "PAYMENT_FAILED",
        holdExpiresAt: null // Release slot
      }
    });

    await prisma.bookingEvent.create({
      data: {
        bookingId,
        fromStatus: "PAYMENT_PENDING",
        toStatus: "PAYMENT_FAILED",
        actorId: userId,
        meta: { reason: reason || "User cancelled payment or gateway timeout" }
      }
    });

    sendResponse(res, 200, "Booking updated to failed state", updated);
  } catch (error) {
    sendError(res, 500, "Failed to update booking status");
  }
};

/**
 * Webhook Handler (Final Source of Truth)
 * Now supports Raw Body Buffer for precise signature verification.
 */
export const handlePaymentWebhook = async (req: Request, res: Response) => {
  const signature = req.headers["x-razorpay-signature"] as string;
  const rawBody = req.body.toString();
  const body = JSON.parse(rawBody);

  try {
    const isValid = verifyWebhookSignature(rawBody, signature);
    if (!isValid) {
       console.error("[Webhook] Signature mismatch!");
       return res.status(400).send("Invalid signature");
    }

    const event = body.event;
    const payload = body.payload.payment.entity;
    const bookingId = payload.notes.bookingId;

    if (event === "payment.captured" || event === "order.paid") {
      await prisma.$transaction(async (tx) => {
        const booking = await tx.booking.findUnique({ where: { id: bookingId } });
        if (!booking || booking.status === "CONFIRMED") return;

        await tx.booking.update({
          where: { id: bookingId },
          data: { 
            status: "CONFIRMED",
            paymentStatus: "PAID",
            paymentId: payload.id,
            orderId: payload.order_id,
            holdExpiresAt: null
          }
        });

        await tx.bookingEvent.create({
          data: {
            bookingId,
            fromStatus: booking.status,
            toStatus: "CONFIRMED",
            actorId: "RAZORPAY_WEBHOOK",
            meta: { razorpayEvent: event }
          }
        });

        // Provider Notification via Webhook (Backup)
        await tx.notification.create({
          data: {
            userId: booking.providerId,
            title: "New Booking (Auto-Confirmed)!",
            message: `A job for ${booking.slot} was confirmed via payment.`,
            type: "BOOKING_CONFIRMED"
          }
        });
      });
    }

    res.status(200).send("Webhook processed");
  } catch (error) {
    console.error("Webhook Error:", error);
    res.status(500).send("Webhook failed");
  }
};

/**
 * Provider Dashboard Data aggregator.
 * Returns everything a provider needs in one go.
 */
export const getProviderDashboardData = async (req: Request, res: Response) => {
  const providerId = req.user!.id;

  try {
    const [stats, upcomingBookings, recentReviews, profile, todayStats] = await Promise.all([
      // 1. Stats
      prisma.booking.aggregate({
        where: { providerId, status: "COMPLETED" },
        _sum: { amount: true },
        _count: { id: true }
      }),
      // 2. Upcoming Jobs (Confirmed but not yet completed)
      prisma.booking.findMany({
        where: { 
          providerId, 
          status: "CONFIRMED",
          dateTime: { gte: new Date() }
        },
        include: { user: { select: { fullName: true, phone: true } }, service: { select: { title: true } } },
        orderBy: { dateTime: "asc" },
        take: 10
      }),
      // 3. Recent Reviews
      prisma.review.findMany({
        where: { providerId },
        include: { user: { select: { fullName: true } } },
        orderBy: { createdAt: "desc" },
        take: 5
      }),
      // 4. Profile for Online Status
      prisma.providerProfile.findUnique({ where: { userId: providerId } }),
      // 5. Today's Earnings
      prisma.booking.aggregate({
        where: { 
          providerId, 
          status: "COMPLETED",
          updatedAt: { gte: new Date(new Date().setHours(0,0,0,0)) }
        },
        _sum: { amount: true }
      })
    ]);

    const dashboardData = {
      totalEarnings: stats._sum.amount || 0,
      completedJobs: stats._count.id || 0,
      todayEarnings: todayStats._sum.amount || 0,
      upcomingBookings,
      recentReviews,
      isOnline: profile?.isOnline ?? true
    };

    sendResponse(res, 200, "Dashboard data fetched", dashboardData);
  } catch (error) {
    sendError(res, 500, "Failed to fetch dashboard data");
  }
};

export const getUserBookings = async (req: Request, res: Response) => {
  const userId = req.user!.id;
  const bookings = await prisma.booking.findMany({
    where: { userId },
    include: {
      provider: { select: { fullName: true, providerProfile: { select: { businessName: true } } } },
      service: { select: { title: true, category: true, images: true } }
    },
    orderBy: { createdAt: "desc" },
  });
  sendResponse(res, 200, "User bookings fetched", bookings);
};

export const getProviderBookings = async (req: Request, res: Response) => {
  const providerId = req.user!.id;
  const bookings = await prisma.booking.findMany({
    where: { providerId },
    include: {
      user: { select: { fullName: true, phone: true } },
      service: { select: { title: true } }
    },
    orderBy: { dateTime: "asc" },
  });
  sendResponse(res, 200, "Provider bookings fetched", bookings);
};

export const completeBooking = async (req: Request, res: Response) => {
  const { id } = req.params;
  const providerId = req.user!.id;

  try {
    await prisma.$transaction(async (tx) => {
      const booking = await tx.booking.findUnique({ where: { id } });
      if (!booking || booking.providerId !== providerId) throw new Error("AUTH_ERROR");

      await tx.booking.update({
        where: { id },
        data: { status: "COMPLETED" }
      });

      await tx.bookingEvent.create({
        data: { bookingId: id, fromStatus: booking.status, toStatus: "COMPLETED", actorId: providerId }
      });

      // Update aggregate stats
      await tx.providerProfile.update({
        where: { userId: providerId },
        data: { totalJobs: { increment: 1 } }
      });
    });
    sendResponse(res, 200, "Job marked as completed");
  } catch (error) {
    sendError(res, 500, "Failed to complete job");
  }
};

/**
 * User Dashboard Data aggregator.
 */
export const getUserDashboardData = async (req: Request, res: Response) => {
  const userId = req.user!.id;

  try {
    const [activeBookings, stats, totalSpent] = await Promise.all([
      // 1. Active Bookings (Confirmed/In Progress)
      prisma.booking.findMany({
        where: { userId, status: { in: ["CONFIRMED", "IN_PROGRESS"] } },
        include: { 
          provider: { select: { fullName: true } }, 
          service: { select: { title: true, images: true } } 
        },
        orderBy: { dateTime: "asc" }
      }),
      // 2. Completed Count
      prisma.booking.count({ where: { userId, status: "COMPLETED" } }),
      // 3. Total Spent
      prisma.booking.aggregate({
        where: { userId, status: "COMPLETED" },
        _sum: { amount: true }
      })
    ]);

    sendResponse(res, 200, "User dashboard data fetched", {
      activeBookings,
      completedCount: stats,
      totalSpent: totalSpent._sum.amount || 0,
      nextJob: activeBookings[0] || null
    });
  } catch (error) {
    console.error("User Dashboard Error:", error);
    sendError(res, 500, "Failed to fetch dashboard data");
  }
};

export const cancelBooking = async (req: Request, res: Response) => {
  const { id } = req.params;
  const userId = req.user!.id;

  try {
    const booking = await prisma.booking.findUnique({ where: { id } });
    if (!booking || booking.userId !== userId) {
      return sendError(res, 404, "Booking not found");
    }

    if (["COMPLETED", "CANCELLED", "REJECTED"].includes(booking.status)) {
      return sendError(res, 400, "Booking cannot be cancelled in its current state");
    }

    const updated = await prisma.booking.update({
      where: { id },
      data: { status: "CANCELLED" }
    });

    await prisma.bookingEvent.create({
      data: {
        bookingId: id,
        fromStatus: booking.status,
        toStatus: "CANCELLED",
        actorId: userId,
        meta: { reason: req.body.reason || "Cancelled by user" }
      }
    });

    sendResponse(res, 200, "Booking cancelled successfully", updated);
  } catch (error) {
    sendError(res, 500, "Failed to cancel booking");
  }
};

export const rescheduleBooking = async (req: Request, res: Response) => {
  const { id } = req.params;
  const { scheduledDate, slot } = req.body;
  const userId = req.user!.id;

  try {
    const booking = await prisma.booking.findUnique({ where: { id } });
    if (!booking || booking.userId !== userId) {
      return sendError(res, 404, "Booking not found");
    }

    const updated = await prisma.booking.update({
      where: { id },
      data: {
        dateTime: new Date(scheduledDate),
        slot,
        status: "PENDING" // Reset to pending if it was accepted? Or keep confirmed?
      }
    });

    await prisma.bookingEvent.create({
      data: {
        bookingId: id,
        fromStatus: booking.status,
        toStatus: "PENDING",
        actorId: userId,
        meta: { oldDate: booking.dateTime, newDate: scheduledDate }
      }
    });

    sendResponse(res, 200, "Booking rescheduled successfully", updated);
  } catch (error) {
    sendError(res, 500, "Failed to reschedule booking");
  }
};

export const retryPayment = async (req: Request, res: Response) => {
  const { id } = req.params;
  const userId = req.user!.id;

  try {
    const booking = await prisma.booking.findUnique({ 
      where: { id },
      include: { service: true }
    });

    if (!booking || booking.userId !== userId) {
      return sendError(res, 404, "Booking not found");
    }

    if (booking.paymentStatus === "PAID") {
      return sendError(res, 400, "Booking is already paid");
    }

    const order = await createRazorpayOrder(booking.amount, booking.id);

    const updated = await prisma.booking.update({
      where: { id },
      data: { orderId: order.id }
    });

    sendResponse(res, 200, "Payment retry initiated", {
      booking: updated,
      razorpayOrder: order
    });
  } catch (error) {
    sendError(res, 500, "Failed to retry payment");
  }
};

/**
 * Scheduled cleanup for abandoned bookings (e.g. locks that never paid)
 * Can be called by a cron job or admin manually.
 */
export const cleanupExpiredBookings = async (req: Request, res: Response) => {
  try {
    const expiredCount = await prisma.booking.updateMany({
      where: {
        status: "PAYMENT_PENDING",
        holdExpiresAt: { lt: new Date() }
      },
      data: {
        status: "EXPIRED",
        holdExpiresAt: null
      }
    });

    sendResponse(res, 200, `${expiredCount.count} abandoned bookings marked as EXPIRED`);
  } catch (error) {
    sendError(res, 500, "Cleanup failed");
  }
};

