import { Request, Response } from "express";
import { prisma } from "../../config/db";
import { sendResponse, sendError } from "../../utils/response";
import { createRazorpayOrder, verifyRazorpaySignature, verifyWebhookSignature } from "../../services/razorpayService";

/**
 * Creates a new booking with "Pay First" / "Instant Booking" logic.
 * The booking is created in PAYMENT_PENDING state and a Razorpay Order is returned immediately.
 * The slot is held for 15 minutes.
 */
export const createBooking = async (req: Request, res: Response) => {
  const userId = req.user!.id;
  const { serviceId, scheduledDate, address, notes, idempotencyKey } = req.body;

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

      // 1.5 Check for overlapping bookings (Instant check)
      const overlaps: any[] = await tx.$queryRaw`
        SELECT id FROM "Booking"
        WHERE "providerId" = ${service.providerId}
        AND "status" NOT IN ('CANCELLED', 'REJECTED', 'EXPIRED')
        AND "dateTime" < ${requestedEnd}
        AND ("dateTime" + ("durationMinutes" * interval '1 minute')) > ${requestedStart}
        LIMIT 1
      `;

      if (overlaps.length > 0) throw new Error("PROVIDER_BUSY");

      // 2. Create the booking in PAYMENT_PENDING state
      const holdExpiresAt = new Date(Date.now() + 15 * 60 * 1000); // 15 min payment lock

      const newBooking = await tx.booking.create({
        data: {
          userId,
          providerId: service.providerId,
          serviceId,
          dateTime: requestedStart,
          slot: req.body.slot,
          durationMinutes: service.durationMinutes,
          address,
          notes,
          amount: service.price,
          paymentMethod: "ONLINE", // Instant bookings are typically online
          status: "PAYMENT_PENDING",
          holdExpiresAt,
          idempotencyKey
        }
      });

      // 3. Initiate Razorpay Order immediately
      const order = await createRazorpayOrder(service.price, newBooking.id);

      // 4. Update booking with Order ID
      const finalBooking = await tx.booking.update({
        where: { id: newBooking.id },
        data: { orderId: order.id }
      });

      // 5. Log event
      await tx.bookingEvent.create({
        data: {
          bookingId: newBooking.id,
          fromStatus: "DRAFT",
          toStatus: "PAYMENT_PENDING",
          actorId: userId,
          meta: { razorpayOrderId: order.id }
        }
      });

      return { booking: finalBooking, razorpayOrder: order };
    });

    sendResponse(res, 201, "Booking initiated. Complete payment to confirm.", result);
  } catch (error: any) {
    if (error.message === "SERVICE_NOT_FOUND") return sendError(res, 404, "Service not found");
    if (error.message === "SERVICE_INACTIVE") return sendError(res, 400, "This service is currently disabled");
    if (error.message === "PROVIDER_BUSY") return sendError(res, 409, "Provider is already booked for this time slot");
    if (error.message === "RAZORPAY_ORDER_FAILED") return sendError(res, 502, "Failed to connect to payment gateway");
    
    console.error("Booking Error:", error);
    sendError(res, 500, "Failed to initiate booking");
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
  } catch (error) {
    console.error("Payment Confirmation Error:", error);
    sendError(res, 500, "Payment confirmation failed");
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
