import { Request, Response } from "express";
import { prisma } from "../../config/db";
import { sendResponse, sendError } from "../../utils/response";

export const createReview = async (req: Request, res: Response) => {
  const userId = req.user!.id;
  const { bookingId, rating, comment } = req.body;

  // Check if booking exists
  const booking = await prisma.booking.findUnique({ where: { id: bookingId } });

  if (!booking) return sendError(res, 404, "Booking not found");
  if (booking.userId !== userId) return sendError(res, 403, "Not authorized to review this booking");
  if (booking.status !== "COMPLETED") return sendError(res, 400, "Can only review completed bookings");

  // Check if already reviewed
  const existingReview = await prisma.review.findUnique({ where: { bookingId } });
  if (existingReview) return sendError(res, 400, "Review already submitted for this booking");

  await prisma.$transaction(async (tx) => {
    const review = await tx.review.create({
      data: {
        bookingId,
        userId,
        providerId: booking.providerId,
        rating,
        comment,
      }
    });

    // Update provider's average rating
    const aggregates = await tx.review.aggregate({
      where: { providerId: booking.providerId },
      _avg: { rating: true },
      _count: { id: true }
    });

    await tx.providerProfile.updateMany({
      where: { userId: booking.providerId },
      data: {
        rating: aggregates._avg.rating || rating,
        totalJobs: { increment: 1 } // Alternatively can just count COMPLETED jobs elsewhere
      }
    });

    return review;
  });

  sendResponse(res, 201, "Review submitted successfully");
};

export const getProviderReviews = async (req: Request, res: Response) => {
  const { providerId } = req.params;

  const reviews = await prisma.review.findMany({
    where: { providerId },
    include: {
      user: { select: { fullName: true } }
    },
    orderBy: { createdAt: "desc" }
  });

  sendResponse(res, 200, "Reviews fetched successfully", reviews);
};
