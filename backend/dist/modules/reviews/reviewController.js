"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getProviderReviews = exports.createReview = void 0;
const db_1 = require("../../config/db");
const response_1 = require("../../utils/response");
const createReview = async (req, res) => {
    const userId = req.user.id;
    const { bookingId, rating, comment } = req.body;
    // Check if booking exists
    const booking = await db_1.prisma.booking.findUnique({ where: { id: bookingId } });
    if (!booking)
        return (0, response_1.sendError)(res, 404, "Booking not found");
    if (booking.userId !== userId)
        return (0, response_1.sendError)(res, 403, "Not authorized to review this booking");
    if (booking.status !== "COMPLETED")
        return (0, response_1.sendError)(res, 400, "Can only review completed bookings");
    // Check if already reviewed
    const existingReview = await db_1.prisma.review.findUnique({ where: { bookingId } });
    if (existingReview)
        return (0, response_1.sendError)(res, 400, "Review already submitted for this booking");
    await db_1.prisma.$transaction(async (tx) => {
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
    (0, response_1.sendResponse)(res, 201, "Review submitted successfully");
};
exports.createReview = createReview;
const getProviderReviews = async (req, res) => {
    const { providerId } = req.params;
    const reviews = await db_1.prisma.review.findMany({
        where: { providerId },
        include: {
            user: { select: { fullName: true } }
        },
        orderBy: { createdAt: "desc" }
    });
    (0, response_1.sendResponse)(res, 200, "Reviews fetched successfully", reviews);
};
exports.getProviderReviews = getProviderReviews;
