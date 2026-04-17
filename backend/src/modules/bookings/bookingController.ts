import { Request, Response } from "express";
import { prisma } from "../../config/db";
import { sendResponse, sendError } from "../../utils/response";

export const createBooking = async (req: Request, res: Response) => {
  const userId = req.user!.id;
  const { serviceId, bookingDate, address } = req.body;

  const service = await prisma.service.findUnique({ where: { id: serviceId } });

  if (!service) return sendError(res, 404, "Service not found");
  if (!service.isActive) return sendError(res, 400, "Service is not available");

  const newBooking = await prisma.booking.create({
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

  sendResponse(res, 201, "Booking created successfully", newBooking);
};

export const getUserBookings = async (req: Request, res: Response) => {
  const userId = req.user!.id;

  const bookings = await prisma.booking.findMany({
    where: { userId },
    include: {
      provider: { select: { fullName: true, providerProfile: true } },
      service: { select: { title: true, category: true } }
    },
    orderBy: { createdAt: "desc" },
  });

  sendResponse(res, 200, "My bookings fetched", bookings);
};

export const getProviderBookings = async (req: Request, res: Response) => {
  const providerId = req.user!.id;

  const bookings = await prisma.booking.findMany({
    where: { providerId },
    include: {
      user: { select: { fullName: true, email: true, phone: true } },
      service: { select: { title: true, category: true } }
    },
    orderBy: { createdAt: "desc" },
  });

  sendResponse(res, 200, "Provider bookings fetched", bookings);
};

export const acceptBooking = async (req: Request, res: Response) => {
  await updateStatus(req, res, "ACCEPTED");
};

export const rejectBooking = async (req: Request, res: Response) => {
  // If we had REJECTED in enum, we could use that. Let's map it to CANCELLED.
  // Wait, the instructions didn't list REJECTED in schema but did say PATCH /api/bookings/:id/reject
  // We will set status to CANCELLED if they reject it.
  await updateStatus(req, res, "CANCELLED");
};

export const startBooking = async (req: Request, res: Response) => {
  await updateStatus(req, res, "IN_PROGRESS");
};

export const completeBooking = async (req: Request, res: Response) => {
  await updateStatus(req, res, "COMPLETED");
};

const updateStatus = async (req: Request, res: Response, targetStatus: "ACCEPTED" | "IN_PROGRESS" | "COMPLETED" | "CANCELLED") => {
  const providerId = req.user!.id;
  const { id } = req.params;

  const booking = await prisma.booking.findUnique({ where: { id } });

  if (!booking) return sendError(res, 404, "Booking not found");
  if (booking.providerId !== providerId) return sendError(res, 403, "Not authorized to update this booking");

  const updatedBooking = await prisma.booking.update({
    where: { id },
    data: { status: targetStatus },
  });

  sendResponse(res, 200, `Booking status updated to ${targetStatus}`, updatedBooking);
};
