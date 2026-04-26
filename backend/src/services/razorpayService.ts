import Razorpay from "razorpay";
import { env } from "../config/env";
import crypto from "crypto";

// Initialize Razorpay with production-ready error handling
const razorpay = new Razorpay({
  key_id: env.RAZORPAY_KEY_ID,
  key_secret: env.RAZORPAY_KEY_SECRET,
});

/**
 * Creates a Razorpay Order for a specific booking.
 * Orders are idempotent on Razorpay's end if we send a unique receipt.
 */
export const createRazorpayOrder = async (amount: number, bookingId: string) => {
  const options = {
    amount: Math.round(amount * 100), // Convert to paise
    currency: "INR",
    receipt: `b_${bookingId}`, // Unique receipt for idempotency (Must be < 40 chars)
    notes: {
      bookingId,
    },
  };
  console.log("[RazorpayService] Creating Order with options:", JSON.stringify(options, null, 2));

  try {
    const order = await razorpay.orders.create(options);
    return order;
  } catch (error: any) {
    console.error("[RazorpayService] Order Creation Error Summary:", {
      message: error.message,
      description: error.description,
      statusCode: error.statusCode
    });
    throw new Error("RAZORPAY_ORDER_FAILED");
  }
};

/**
 * Verifies the signature sent by the mobile app after a successful payment.
 * This is the FIRST line of defense against payment spoofing.
 */
export const verifyRazorpaySignature = (
  razorpayOrderId: string,
  razorpayPaymentId: string,
  signature: string
) => {
  const body = razorpayOrderId + "|" + razorpayPaymentId;
  const expectedSignature = crypto
    .createHmac("sha256", env.RAZORPAY_KEY_SECRET)
    .update(body)
    .digest("hex");

  return expectedSignature === signature;
};

/**
 * Verifies the signature for incoming Webhooks from Razorpay servers.
 * This is the FINAL source of truth for the platform.
 */
export const verifyWebhookSignature = (body: string, signature: string) => {
  if (!env.RAZORPAY_WEBHOOK_SECRET) {
    console.warn("[RazorpayService] Webhook secret missing. Skipping verification (Insecure!)");
    return true; 
  }

  const expectedSignature = crypto
    .createHmac("sha256", env.RAZORPAY_WEBHOOK_SECRET)
    .update(body)
    .digest("hex");

  return expectedSignature === signature;
};
