"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.verifyPayment = exports.createOrder = void 0;
const db_1 = require("../../config/db");
const response_1 = require("../../utils/response");
// import crypto from "crypto";
// import Razorpay from "razorpay";
const env_1 = require("../../config/env");
/*
// Placeholder initialization for Razorpay
const razorpay = new Razorpay({
  key_id: env.RAZORPAY_KEY_ID || "test_key",
  key_secret: env.RAZORPAY_KEY_SECRET || "test_secret",
});
*/
const createOrder = async (req, res) => {
    const userId = req.user.id;
    const { bookingId } = req.body;
    const booking = await db_1.prisma.booking.findUnique({
        where: { id: bookingId },
    });
    if (!booking)
        return (0, response_1.sendError)(res, 404, "Booking not found");
    if (booking.userId !== userId)
        return (0, response_1.sendError)(res, 403, "Not authorized");
    if (booking.status !== "ACCEPTED" && booking.status !== "PENDING") {
        return (0, response_1.sendError)(res, 400, "Booking cannot be paid in current status");
    }
    // Placeholder logic for creating an order with Razorpay
    const amountInPaise = Math.round(booking.totalAmount * 100);
    /*
    const options = {
      amount: amountInPaise,
      currency: "INR",
      receipt: `receipt_order_${booking.id}`,
      payment_capture: 1,
    };
    const order = await razorpay.orders.create(options);
    */
    // Mocking order creation for placeholder
    const mockOrderId = `order_${Math.random().toString(36).substring(7)}`;
    await db_1.prisma.payment.create({
        data: {
            bookingId,
            amount: booking.totalAmount,
            method: "RAZORPAY",
            status: "CREATED",
            gatewayOrderId: mockOrderId,
        }
    });
    (0, response_1.sendResponse)(res, 201, "Payment order created", {
        orderId: mockOrderId,
        amount: booking.totalAmount,
        currency: "INR",
        key: env_1.env.RAZORPAY_KEY_ID,
    });
};
exports.createOrder = createOrder;
const verifyPayment = async (req, res) => {
    const { razorpay_order_id, razorpay_payment_id, razorpay_signature, bookingId } = req.body;
    /*
    // Real signature verification
    const body = razorpay_order_id + "|" + razorpay_payment_id;
    const expectedSignature = crypto
      .createHmac("sha256", env.RAZORPAY_KEY_SECRET!)
      .update(body.toString())
      .digest("hex");
  
    if (expectedSignature !== razorpay_signature) {
      return sendError(res, 400, "Invalid payment signature");
    }
    */
    // Placeholder logic: assume verification passes
    const isValid = true;
    if (isValid) {
        await db_1.prisma.$transaction(async (tx) => {
            await tx.payment.update({
                where: { bookingId },
                data: {
                    status: "SUCCESS",
                    gatewayPaymentId: razorpay_payment_id,
                }
            });
            // Optionally, change booking status to something else if needed, 
            // but usually wait for provider to start/complete.
            // await tx.booking.update({ where: { id: bookingId }, data: { status: "ACCEPTED" } });
        });
        return (0, response_1.sendResponse)(res, 200, "Payment verified successfully", { bookingId });
    }
    (0, response_1.sendError)(res, 400, "Verification failed");
};
exports.verifyPayment = verifyPayment;
