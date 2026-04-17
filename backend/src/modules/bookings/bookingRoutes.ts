import { Router } from "express";
import {
  createBooking,
  getUserBookings,
  getProviderBookings,
  acceptBooking,
  rejectBooking,
  startBooking,
  completeBooking
} from "./bookingController";
import { protect } from "../../middleware/authMiddleware";
import { requireRole } from "../../middleware/roleMiddleware";
import { validate } from "../../middleware/validate";
import { createBookingSchema } from "./bookingSchema";
import "express-async-errors";

const router = Router();

// All booking routes require authentication
router.use(protect);

// User strictly routes
router.post("/", requireRole("USER"), validate(createBookingSchema), createBooking);
router.get("/my", requireRole("USER"), getUserBookings);

// Provider strictly routes
router.get("/provider", requireRole("PROVIDER"), getProviderBookings);
router.patch("/:id/accept", requireRole("PROVIDER"), acceptBooking);
router.patch("/:id/reject", requireRole("PROVIDER"), rejectBooking);
router.patch("/:id/start", requireRole("PROVIDER"), startBooking);
router.patch("/:id/complete", requireRole("PROVIDER"), completeBooking);

export default router;
