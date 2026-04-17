import { Router } from "express";
import { createReview, getProviderReviews } from "./reviewController";
import { protect } from "../../middleware/authMiddleware";
import { requireRole } from "../../middleware/roleMiddleware";
import { validate } from "../../middleware/validate";
import { createReviewSchema } from "./reviewSchema";
import "express-async-errors";

const router = Router();

// Public route to fetch reviews
router.get("/provider/:providerId", getProviderReviews);

// Protected route to create review
router.post("/", protect, requireRole("USER"), validate(createReviewSchema), createReview);

export default router;
