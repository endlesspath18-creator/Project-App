import { z } from "zod";

export const createOrderSchema = z.object({
  body: z.object({
    serviceId: z.string().uuid("Invalid service ID"),
  })
});

export const verifyPaymentSchema = z.object({
  body: z.object({
    razorpay_order_id: z.string().min(1, "Order ID is required"),
    razorpay_payment_id: z.string().min(1, "Payment ID is required"),
    razorpay_signature: z.string().min(1, "Signature is required"),
    bookingData: z.object({
      serviceId: z.string().uuid("Service ID is required"),
      dateTime: z.string().min(1, "Date/Time is required"),
      address: z.string().min(5, "Address is too short"),
      notes: z.string().optional(),
    })
  })
});
