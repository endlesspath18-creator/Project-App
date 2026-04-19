"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getActiveJobs = exports.getIncomingRequests = exports.getDashboardStats = void 0;
const db_1 = require("../../config/db");
const response_1 = require("../../utils/response");
const getDashboardStats = async (req, res) => {
    const providerId = req.user.id;
    try {
        const profile = await db_1.prisma.providerProfile.findUnique({
            where: { userId: providerId },
        });
        if (!profile)
            return (0, response_1.sendError)(res, 404, "Provider profile not found");
        // Get earnings (Total amount from COMPLETED bookings)
        const earnings = await db_1.prisma.booking.aggregate({
            where: {
                providerId,
                status: "COMPLETED"
            },
            _sum: {
                totalAmount: true
            }
        });
        // Get counts
        const pendingCount = await db_1.prisma.booking.count({
            where: { providerId, status: "PENDING" }
        });
        const activeCount = await db_1.prisma.booking.count({
            where: {
                providerId,
                status: { in: ["ACCEPTED", "IN_PROGRESS"] }
            }
        });
        const completedCount = profile.totalJobs;
        (0, response_1.sendResponse)(res, 200, "Dashboard stats fetched", {
            earnings: earnings._sum.totalAmount || 0,
            completedJobs: completedCount,
            pendingRequests: pendingCount,
            activeJobs: activeCount,
            rating: profile.rating,
            isOnline: profile.isOnline
        });
    }
    catch (error) {
        console.error("Dashboard Stats Error:", error);
        (0, response_1.sendError)(res, 500, "Failed to fetch dashboard stats");
    }
};
exports.getDashboardStats = getDashboardStats;
const getIncomingRequests = async (req, res) => {
    const providerId = req.user.id;
    const requests = await db_1.prisma.booking.findMany({
        where: {
            providerId,
            status: "PENDING"
        },
        include: {
            user: {
                select: {
                    fullName: true,
                    phone: true,
                    email: true,
                }
            },
            service: {
                select: {
                    title: true,
                    category: true,
                    price: true
                }
            }
        },
        orderBy: { createdAt: "desc" }
    });
    (0, response_1.sendResponse)(res, 200, "Incoming requests fetched", requests);
};
exports.getIncomingRequests = getIncomingRequests;
const getActiveJobs = async (req, res) => {
    const providerId = req.user.id;
    const jobs = await db_1.prisma.booking.findMany({
        where: {
            providerId,
            status: { in: ["ACCEPTED", "IN_PROGRESS"] }
        },
        include: {
            user: {
                select: {
                    fullName: true,
                    phone: true,
                }
            },
            service: {
                select: {
                    title: true,
                    category: true,
                }
            }
        },
        orderBy: { scheduledDate: "asc" }
    });
    (0, response_1.sendResponse)(res, 200, "Active jobs fetched", jobs);
};
exports.getActiveJobs = getActiveJobs;
