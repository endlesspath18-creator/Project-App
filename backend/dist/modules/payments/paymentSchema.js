"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.verifyPaymentSchema = exports.createOrderSchema = void 0;
const zod_1 = require("zod");
exports.createOrderSchema = zod_1.z.object({
    body: zod_1.z.object({
        bookingId: zod_1.z.string().uuid("Invalid booking ID"),
    })
});
exports.verifyPaymentSchema = zod_1.z.object({
    body: zod_1.z.object({
        razorpay_order_id: zod_1.z.string().min(1, "Order ID is required"),
        razorpay_payment_id: zod_1.z.string().min(1, "Payment ID is required"),
        razorpay_signature: zod_1.z.string().min(1, "Signature is required"),
        bookingId: zod_1.z.string().uuid("Booking ID is required"),
    })
});
