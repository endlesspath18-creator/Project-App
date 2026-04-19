"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.completeBooking = exports.startBooking = exports.rejectBooking = exports.acceptBooking = exports.getProviderBookings = exports.getUserBookings = exports.createBooking = void 0;
const db_1 = require("../../config/db");
const response_1 = require("../../utils/response");
const createBooking = async (req, res) => {
    const userId = req.user.id;
    const { serviceId, scheduledDate, address, notes } = req.body;
    try {
        const result = await db_1.prisma.$transaction(async (tx) => {
            // 1. Check if service is available
            const service = await tx.service.findUnique({
                where: { id: serviceId },
                include: { provider: true }
            });
            if (!service)
                throw new Error("SERVICE_NOT_FOUND");
            if (!service.isActive)
                throw new Error("SERVICE_INACTIVE");
            if (service.status !== "AVAILABLE")
                throw new Error("SERVICE_BUSY");
            // 2. Create the booking
            const newBooking = await tx.booking.create({
                data: {
                    userId,
                    providerId: service.providerId,
                    serviceId,
                    scheduledDate: new Date(scheduledDate),
                    address,
                    notes,
                    totalAmount: service.price,
                    status: "PENDING",
                }
            });
            // 3. Mark service as BUSY
            await tx.service.update({
                where: { id: serviceId },
                data: { status: "BUSY" }
            });
            return newBooking;
        });
        (0, response_1.sendResponse)(res, 201, "Booking created successfully", result);
    }
    catch (error) {
        if (error.message === "SERVICE_NOT_FOUND")
            return (0, response_1.sendError)(res, 404, "Service not found");
        if (error.message === "SERVICE_INACTIVE")
            return (0, response_1.sendError)(res, 400, "This service is currently disabled");
        if (error.message === "SERVICE_BUSY")
            return (0, response_1.sendError)(res, 400, "Service is currently busy or already booked");
        console.error("Booking Error:", error);
        (0, response_1.sendError)(res, 500, "Failed to create booking");
    }
};
exports.createBooking = createBooking;
const getUserBookings = async (req, res) => {
    const userId = req.user.id;
    const bookings = await db_1.prisma.booking.findMany({
        where: { userId },
        include: {
            provider: {
                select: {
                    fullName: true,
                    providerProfile: { select: { businessName: true, rating: true } }
                }
            },
            service: { select: { title: true, category: true, images: true } }
        },
        orderBy: { createdAt: "desc" },
    });
    (0, response_1.sendResponse)(res, 200, "User bookings fetched", bookings);
};
exports.getUserBookings = getUserBookings;
const getProviderBookings = async (req, res) => {
    const providerId = req.user.id;
    const bookings = await db_1.prisma.booking.findMany({
        where: { providerId },
        include: {
            user: { select: { fullName: true, email: true, phone: true } },
            service: { select: { title: true, category: true } }
        },
        orderBy: { createdAt: "desc" },
    });
    (0, response_1.sendResponse)(res, 200, "Provider bookings fetched", bookings);
};
exports.getProviderBookings = getProviderBookings;
const acceptBooking = async (req, res) => {
    await updateBookingStatus(req, res, "ACCEPTED");
};
exports.acceptBooking = acceptBooking;
const rejectBooking = async (req, res) => {
    // If rejected, mark service as AVAILABLE again
    const { id } = req.params;
    const providerId = req.user.id;
    try {
        await db_1.prisma.$transaction(async (tx) => {
            const booking = await tx.booking.findUnique({ where: { id } });
            if (!booking || booking.providerId !== providerId)
                throw new Error("AUTH_ERROR");
            await tx.booking.update({
                where: { id },
                data: { status: "REJECTED" }
            });
            await tx.service.update({
                where: { id: booking.serviceId },
                data: { status: "AVAILABLE" }
            });
        });
        (0, response_1.sendResponse)(res, 200, "Booking rejected and service freed");
    }
    catch (error) {
        (0, response_1.sendError)(res, 403, "Failed to reject booking");
    }
};
exports.rejectBooking = rejectBooking;
const startBooking = async (req, res) => {
    await updateBookingStatus(req, res, "IN_PROGRESS");
};
exports.startBooking = startBooking;
const completeBooking = async (req, res) => {
    const { id } = req.params;
    const providerId = req.user.id;
    try {
        const result = await db_1.prisma.$transaction(async (tx) => {
            const booking = await tx.booking.findUnique({ where: { id } });
            if (!booking || booking.providerId !== providerId)
                throw new Error("AUTH_ERROR");
            // 1. Update Booking
            const updated = await tx.booking.update({
                where: { id },
                data: { status: "COMPLETED" }
            });
            // 2. Mark Service AVAILABLE and increment stats
            await tx.service.update({
                where: { id: booking.serviceId },
                data: {
                    status: "AVAILABLE",
                    totalJobs: { increment: 1 }
                }
            });
            // 3. Update Provider Profile stats
            await tx.providerProfile.update({
                where: { userId: providerId },
                data: { totalJobs: { increment: 1 } }
            });
            return updated;
        });
        (0, response_1.sendResponse)(res, 200, "Job completed and stats updated", result);
    }
    catch (error) {
        console.error("Complete Job Error:", error);
        (0, response_1.sendError)(res, 403, "Failed to complete job");
    }
};
exports.completeBooking = completeBooking;
const updateBookingStatus = async (req, res, status) => {
    const providerId = req.user.id;
    const { id } = req.params;
    const booking = await db_1.prisma.booking.findUnique({ where: { id } });
    if (!booking)
        return (0, response_1.sendError)(res, 404, "Booking not found");
    if (booking.providerId !== providerId)
        return (0, response_1.sendError)(res, 403, "Not authorized");
    const updated = await db_1.prisma.booking.update({
        where: { id },
        data: { status }
    });
    (0, response_1.sendResponse)(res, 200, `Status updated to ${status}`, updated);
};
