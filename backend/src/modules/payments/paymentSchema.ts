import { z } from "zod";

export const createOrderSchema = z.object({
  body: z.object({
    bookingId: z.string().uuid("Invalid booking ID"),
  })
});

export const verifyPaymentSchema = z.object({
  body: z.object({
    razorpay_order_id: z.string().min(1, "Order ID is required"),
    razorpay_payment_id: z.string().min(1, "Payment ID is required"),
    razorpay_signature: z.string().min(1, "Signature is required"),
    bookingId: z.string().uuid("Booking ID is required"),
  })
});
