import { Request, Response } from "express";
import { prisma } from "../../config/db";
import { sendResponse, sendError } from "../../utils/response";
import crypto from "crypto";
import Razorpay from "razorpay";
import { env } from "../../config/env";

const razorpay = new Razorpay({
  key_id: env.RAZORPAY_KEY_ID || "rzp_test_placeholder",
  key_secret: env.RAZORPAY_KEY_SECRET || "razor_secret_placeholder",
});

/**
 * Step 1: Create Razorpay Order
 * User wants to book a service online.
 */
export const createOrder = async (req: Request, res: Response) => {
  const { serviceId } = req.body;

  try {
    const service = await prisma.service.findUnique({ where: { id: serviceId } });
    if (!service) return sendError(res, 404, "Service not found");

    const amountInPaise = Math.round(service.price * 100);
    
    const options = {
      amount: amountInPaise,
      currency: "INR",
      receipt: `receipt_${Date.now()}`,
    };

    const order = await razorpay.orders.create(options);

    sendResponse(res, 201, "Razorpay order created", {
      orderId: order.id,
      amount: service.price,
      currency: "INR",
      key: env.RAZORPAY_KEY_ID,
    });
  } catch (error: any) {
    console.error("Razorpay Order Error:", error);
    sendError(res, 500, "Failed to create payment order");
  }
};

/**
 * Step 2: Verify Payment & Create Final Booking
 */
export const verifyPayment = async (req: Request, res: Response) => {
  const userId = req.user!.id;
  const { 
    razorpay_order_id, 
    razorpay_payment_id, 
    razorpay_signature,
    bookingData // Contains serviceId, dateTime, address, etc.
  } = req.body;

  try {
    // 1. Verify Signature
    const body = razorpay_order_id + "|" + razorpay_payment_id;
    const expectedSignature = crypto
      .createHmac("sha256", env.RAZORPAY_KEY_SECRET || "razor_secret_placeholder")
      .update(body.toString())
      .digest("hex");

    if (expectedSignature !== razorpay_signature) {
      return sendError(res, 400, "Payment verification failed: Invalid signature");
    }

    // 2. Signature is valid, now finalize the booking in a transaction
    const result = await prisma.$transaction(async (tx) => {
      const service = await tx.service.findUnique({ where: { id: bookingData.serviceId } });
      if (!service) throw new Error("SERVICE_NOT_FOUND");

      const booking = await tx.booking.create({
        data: {
          userId,
          serviceId: bookingData.serviceId,
          providerId: service.providerId,
          dateTime: new Date(bookingData.dateTime),
          address: bookingData.address,
          notes: bookingData.notes,
          amount: service.price,
          paymentMethod: "ONLINE",
          paymentStatus: "PAID",
          status: "PENDING", // Provider still needs to ACCEPT
          orderId: razorpay_order_id,
          paymentId: razorpay_payment_id,
        }
      });

      // Mark service as BUSY
      await tx.service.update({
        where: { id: service.id },
        data: { status: "BUSY" }
      });

      return booking;
    });

    sendResponse(res, 201, "Payment verified and booking confirmed", result);
  } catch (error: any) {
    console.error("Payment Verification Error:", error);
    sendError(res, 500, "Booking confirmation failed after payment");
  }
};

/**
 * Fetch Payment/Booking History for authenticated user
 */
export const getPaymentHistory = async (req: Request, res: Response) => {
  const userId = req.user!.id;

  const history = await prisma.booking.findMany({
    where: { 
      userId,
      paymentMethod: "ONLINE",
      paymentStatus: "PAID"
    },
    include: {
      service: { select: { title: true, category: true } },
      provider: { select: { fullName: true } }
    },
    orderBy: { createdAt: "desc" }
  });

  sendResponse(res, 200, "Payment history fetched", history);
};
