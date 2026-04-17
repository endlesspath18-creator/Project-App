"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.completeBooking = exports.startBooking = exports.rejectBooking = exports.acceptBooking = exports.getProviderBookings = exports.getUserBookings = exports.createBooking = void 0;
const db_1 = require("../../config/db");
const response_1 = require("../../utils/response");
const createBooking = async (req, res) => {
    const userId = req.user.id;
    const { serviceId, bookingDate, address } = req.body;
    const service = await db_1.prisma.service.findUnique({ where: { id: serviceId } });
    if (!service)
        return (0, response_1.sendError)(res, 404, "Service not found");
    if (!service.isActive)
        return (0, response_1.sendError)(res, 400, "Service is not available");
    const newBooking = await db_1.prisma.booking.create({
        data: {
            userId,
            providerId: service.providerId,
            serviceId,
            bookingDate: new Date(bookingDate),
            address,
            totalAmount: service.price,
            status: "PENDING",
        }
    });
    (0, response_1.sendResponse)(res, 201, "Booking created successfully", newBooking);
};
exports.createBooking = createBooking;
const getUserBookings = async (req, res) => {
    const userId = req.user.id;
    const bookings = await db_1.prisma.booking.findMany({
        where: { userId },
        include: {
            provider: { select: { fullName: true, providerProfile: true } },
            service: { select: { title: true, category: true } }
        },
        orderBy: { createdAt: "desc" },
    });
    (0, response_1.sendResponse)(res, 200, "My bookings fetched", bookings);
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
    await updateStatus(req, res, "ACCEPTED");
};
exports.acceptBooking = acceptBooking;
const rejectBooking = async (req, res) => {
    // If we had REJECTED in enum, we could use that. Let's map it to CANCELLED.
    // Wait, the instructions didn't list REJECTED in schema but did say PATCH /api/bookings/:id/reject
    // We will set status to CANCELLED if they reject it.
    await updateStatus(req, res, "CANCELLED");
};
exports.rejectBooking = rejectBooking;
const startBooking = async (req, res) => {
    await updateStatus(req, res, "IN_PROGRESS");
};
exports.startBooking = startBooking;
const completeBooking = async (req, res) => {
    await updateStatus(req, res, "COMPLETED");
};
exports.completeBooking = completeBooking;
const updateStatus = async (req, res, targetStatus) => {
    const providerId = req.user.id;
    const { id } = req.params;
    const booking = await db_1.prisma.booking.findUnique({ where: { id } });
    if (!booking)
        return (0, response_1.sendError)(res, 404, "Booking not found");
    if (booking.providerId !== providerId)
        return (0, response_1.sendError)(res, 403, "Not authorized to update this booking");
    const updatedBooking = await db_1.prisma.booking.update({
        where: { id },
        data: { status: targetStatus },
    });
    (0, response_1.sendResponse)(res, 200, `Booking status updated to ${targetStatus}`, updatedBooking);
};
