"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const bookingController_1 = require("./bookingController");
const authMiddleware_1 = require("../../middleware/authMiddleware");
const roleMiddleware_1 = require("../../middleware/roleMiddleware");
const validate_1 = require("../../middleware/validate");
const bookingSchema_1 = require("./bookingSchema");
require("express-async-errors");
const router = (0, express_1.Router)();
// All booking routes require authentication
router.use(authMiddleware_1.protect);
// User strictly routes
router.post("/", (0, roleMiddleware_1.requireRole)("USER"), (0, validate_1.validate)(bookingSchema_1.createBookingSchema), bookingController_1.createBooking);
router.get("/my", (0, roleMiddleware_1.requireRole)("USER"), bookingController_1.getUserBookings);
// Provider strictly routes
router.get("/provider", (0, roleMiddleware_1.requireRole)("PROVIDER"), bookingController_1.getProviderBookings);
router.patch("/:id/accept", (0, roleMiddleware_1.requireRole)("PROVIDER"), bookingController_1.acceptBooking);
router.patch("/:id/reject", (0, roleMiddleware_1.requireRole)("PROVIDER"), bookingController_1.rejectBooking);
router.patch("/:id/start", (0, roleMiddleware_1.requireRole)("PROVIDER"), bookingController_1.startBooking);
router.patch("/:id/complete", (0, roleMiddleware_1.requireRole)("PROVIDER"), bookingController_1.completeBooking);
exports.default = router;
