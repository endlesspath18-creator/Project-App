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
  const { bookingId } = req.body;

  try {
    const booking = await prisma.booking.findUnique({ 
      where: { id: bookingId },
      include: { service: true }
    });
    
    if (!booking) return sendError(res, 404, "Booking not found");

    const amountInPaise = Math.round(Number(booking.amount) * 100);
    
    const options = {
      amount: amountInPaise,
      currency: "INR",
      receipt: `receipt_${booking.id.substring(0, 8)}`,
    };

    const order = await razorpay.orders.create(options);

    // Save orderId to booking
    await prisma.booking.update({
      where: { id: bookingId },
      data: { orderId: order.id }
    });

    sendResponse(res, 201, "Razorpay order created", {
      orderId: order.id,
      amount: Number(booking.amount),
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
  const { 
    razorpay_order_id, 
    razorpay_payment_id, 
    razorpay_signature,
    bookingId
  } = req.body;

  try {
    // 1. Verify Signature (Standard Razorpay Security)
    const body = razorpay_order_id + "|" + razorpay_payment_id;
    const expectedSignature = crypto
      .createHmac("sha256", env.RAZORPAY_KEY_SECRET || "razor_secret_placeholder")
      .update(body.toString())
      .digest("hex");

    if (expectedSignature !== razorpay_signature) {
      console.warn(`SECURITY_ALERT: Invalid payment signature attempt for Order: ${razorpay_order_id}`);
      return sendError(res, 400, "Payment verification failed: Invalid signature");
    }

    // 2. Check for Replay Attack (Duplicate paymentId)
    const existingTransaction = await prisma.paymentTransaction.findUnique({
      where: { paymentId: razorpay_payment_id }
    });
    if (existingTransaction) {
      return sendResponse(res, 200, "Payment already processed", existingTransaction);
    }

    // 3. Update booking and track revenue in a single transaction
    const result = await prisma.$transaction(async (tx) => {
      const booking = await tx.booking.findUnique({ 
        where: { id: bookingId },
        include: { service: true }
      });

      if (!booking) throw new Error("BOOKING_NOT_FOUND");
      if (booking.userId !== req.user!.id) throw new Error("UNAUTHORIZED_PAYMENT");
      if (booking.paymentStatus === "PAID") return booking; // Already processed
      if (booking.orderId !== razorpay_order_id) throw new Error("ORDER_ID_MISMATCH");

      const updatedBooking = await tx.booking.update({
        where: { id: bookingId },
        data: {
          paymentStatus: "PAID",
          paymentId: razorpay_payment_id,
        }
      });

      // Calculate Split: 18% GST and 10% Admin Commission on Base
      const total = booking.amount;
      const baseAmount = total / 1.18;
      const gstAmount = total - baseAmount;
      const commissionAmount = baseAmount * 0.10;
      const providerAmount = baseAmount - commissionAmount;

      await tx.paymentTransaction.create({
        data: {
          userId: booking.userId,
          type: "BOOKING",
          amount: total,
          gstAmount: gstAmount,
          commissionAmount: commissionAmount,
          providerAmount: providerAmount,
          status: "SUCCESS",
          paymentId: razorpay_payment_id,
          orderId: razorpay_order_id,
          gatewayResponse: req.body,
        }
      });

      console.log(`FINANCE_LOG: Booking ${bookingId} verified. Rev: ${commissionAmount}, GST: ${gstAmount}, Pro: ${providerAmount}`);
      return booking;
    });

    sendResponse(res, 200, "Payment verified successfully", result);
  } catch (error: any) {
    if (error.message === "BOOKING_NOT_FOUND") return sendError(res, 404, "Booking record not found");
    if (error.message === "UNAUTHORIZED_PAYMENT") return sendError(res, 403, "Fraud detected: Booking does not belong to user");
    if (error.message === "ORDER_ID_MISMATCH") return sendError(res, 400, "Payment security breach: Order ID mismatch");
    
    console.error("CRITICAL_PAYMENT_ERROR:", error);
    sendError(res, 500, "Secure payment verification failed");
  }
};

/**
 * Step 1: Create Activation Order for Providers (₹300)
 */
export const createActivationOrder = async (req: Request, res: Response) => {
  const userId = req.user!.id;
  const amount = 300; 

  try {
    // Check if already paid to prevent double charging
    const user = await prisma.user.findUnique({ where: { id: userId } });
    if (user?.hasPaidPublishingFee) {
      return sendError(res, 400, "Your account is already activated");
    }

    const options = {
      amount: amount * 100,
      currency: "INR",
      receipt: `activation_${userId.substring(0, 8)}_${Date.now()}`,
    };

    const order = await razorpay.orders.create(options);

    sendResponse(res, 201, "Activation order created", {
      orderId: order.id,
      amount: amount,
      currency: "INR",
      key: env.RAZORPAY_KEY_ID,
    });
  } catch (error: any) {
    console.error("ACTIVATION_ORDER_ERROR:", error);
    sendError(res, 500, "Secure activation order creation failed");
  }
};

/**
 * Step 2: Verify Activation Payment
 */
export const verifyActivationPayment = async (req: Request, res: Response) => {
  const { 
    razorpay_order_id, 
    razorpay_payment_id, 
    razorpay_signature 
  } = req.body;
  const userId = req.user!.id;

  try {
    // 1. Verify Signature
    const body = razorpay_order_id + "|" + razorpay_payment_id;
    const expectedSignature = crypto
      .createHmac("sha256", env.RAZORPAY_KEY_SECRET || "razor_secret_placeholder")
      .update(body.toString())
      .digest("hex");

    if (expectedSignature !== razorpay_signature) {
      console.warn(`SECURITY_ALERT: Invalid activation signature attempt for User: ${userId}`);
      return sendError(res, 400, "Activation verification failed");
    }

    // 2. Check for Replay Attack
    const existing = await prisma.paymentTransaction.findUnique({ where: { paymentId: razorpay_payment_id } });
    if (existing) return sendResponse(res, 200, "Activation already processed");

    // 3. Atomically update user and log transaction
    const user = await prisma.$transaction(async (tx) => {
      const updatedUser = await tx.user.update({
        where: { id: userId },
        data: {
          hasPaidPublishingFee: true,
          canPublishService: true,
        }
      });

      await tx.paymentTransaction.create({
        data: {
          userId,
          type: "PROVIDER_ACTIVATION",
          amount: 300,
          commissionAmount: 300, // Activation fee is 100% platform revenue
          providerAmount: 0.0,
          status: "SUCCESS",
          paymentId: razorpay_payment_id,
          orderId: razorpay_order_id,
          gatewayResponse: req.body,
        }
      });

      console.log(`FINANCE_LOG: Provider ${userId} activated. Revenue: 300`);
      return updatedUser;
    });

    sendResponse(res, 200, "Account activated securely", user);
  } catch (error: any) {
    console.error("CRITICAL_ACTIVATION_ERROR:", error);
    sendError(res, 500, "Secure activation failed");
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
