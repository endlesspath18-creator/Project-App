import { z } from "zod";

export const createReviewSchema = z.object({
  body: z.object({
    bookingId: z.string().uuid("Invalid booking ID"),
    rating: z.number().int().min(1, "Rating must be at least 1").max(5, "Rating cannot be more than 5"),
    comment: z.string().max(500, "Comment is too long").optional(),
  })
});
