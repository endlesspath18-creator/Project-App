import { Router } from "express";
import * as bookingController from "./bookingController";

import { protect } from "../../middleware/authMiddleware";
import { requireRole } from "../../middleware/roleMiddleware";
import { validate } from "../../middleware/validate";
import { createBookingSchema } from "./bookingSchema";
import "express-async-errors";

const router = Router();

// ─── Public/Webhook Routes (No Auth) ──────────────────────────────────────────
// In a real app, this should have signature verification middleware
router.post("/webhook/razorpay", bookingController.handlePaymentWebhook);


// ─── Protected Routes ──────────────────────────────────────────────────────────
router.use(protect);

// User Routes
router.post("/", requireRole("USER"), validate(createBookingSchema), bookingController.createBooking);
router.get("/user/dashboard", requireRole("USER"), bookingController.getUserDashboardData);
router.get("/my", requireRole("USER"), bookingController.getUserBookings);
router.post("/confirm-payment", requireRole("USER"), bookingController.confirmPayment);


// Provider Routes
router.get("/provider", requireRole("PROVIDER"), bookingController.getProviderBookings);
router.get("/provider/dashboard", requireRole("PROVIDER"), bookingController.getProviderDashboardData);
router.patch("/:id/complete", requireRole("PROVIDER"), bookingController.completeBooking);


router.patch("/:id/cancel", protect, bookingController.cancelBooking);
router.patch("/:id/reschedule", protect, bookingController.rescheduleBooking);
router.post("/:id/retry-payment", protect, bookingController.retryPayment);

export default router;

