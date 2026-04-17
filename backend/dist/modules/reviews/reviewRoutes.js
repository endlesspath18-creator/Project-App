"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const reviewController_1 = require("./reviewController");
const authMiddleware_1 = require("../../middleware/authMiddleware");
const roleMiddleware_1 = require("../../middleware/roleMiddleware");
const validate_1 = require("../../middleware/validate");
const reviewSchema_1 = require("./reviewSchema");
require("express-async-errors");
const router = (0, express_1.Router)();
// Public route to fetch reviews
router.get("/provider/:providerId", reviewController_1.getProviderReviews);
// Protected route to create review
router.post("/", authMiddleware_1.protect, (0, roleMiddleware_1.requireRole)("USER"), (0, validate_1.validate)(reviewSchema_1.createReviewSchema), reviewController_1.createReview);
exports.default = router;
