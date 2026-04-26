import { Router } from "express";
import {
  createBooking,
  getUserBookings,
  getProviderBookings,
  getProviderDashboardData,
  confirmPayment,
  completeBooking,
  handlePaymentWebhook
} from "./bookingController";
import { protect } from "../../middleware/authMiddleware";
import { requireRole } from "../../middleware/roleMiddleware";
import { validate } from "../../middleware/validate";
import { createBookingSchema } from "./bookingSchema";
import "express-async-errors";

const router = Router();

// ─── Public/Webhook Routes (No Auth) ──────────────────────────────────────────
// In a real app, this should have signature verification middleware
router.post("/webhook/razorpay", handlePaymentWebhook);

// ─── Protected Routes ──────────────────────────────────────────────────────────
router.use(protect);

// User Routes
router.post("/", requireRole("USER"), validate(createBookingSchema), createBooking);
router.get("/my", requireRole("USER"), getUserBookings);
router.post("/confirm-payment", requireRole("USER"), confirmPayment);

// Provider Routes
router.get("/provider", requireRole("PROVIDER"), getProviderBookings);
router.get("/provider/dashboard", requireRole("PROVIDER"), getProviderDashboardData);
router.patch("/:id/complete", requireRole("PROVIDER"), completeBooking);

export default router;
