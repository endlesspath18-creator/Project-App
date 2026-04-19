import { Request, Response } from "express";
import { prisma } from "../../config/db";
import { sendResponse, sendError } from "../../utils/response";

export const createBooking = async (req: Request, res: Response) => {
  const userId = req.user!.id;
  const { serviceId, scheduledDate, address, notes } = req.body;

  try {
    const result = await prisma.$transaction(async (tx) => {
      // 1. Check if service is available
      const service = await tx.service.findUnique({ 
        where: { id: serviceId },
        include: { provider: true } 
      });

      if (!service) throw new Error("SERVICE_NOT_FOUND");
      if (!service.isActive) throw new Error("SERVICE_INACTIVE");
      if (service.status !== "AVAILABLE") throw new Error("SERVICE_BUSY");

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

    sendResponse(res, 201, "Booking created successfully", result);
  } catch (error: any) {
    if (error.message === "SERVICE_NOT_FOUND") return sendError(res, 404, "Service not found");
    if (error.message === "SERVICE_INACTIVE") return sendError(res, 400, "This service is currently disabled");
    if (error.message === "SERVICE_BUSY") return sendError(res, 400, "Service is currently busy or already booked");
    
    console.error("Booking Error:", error);
    sendError(res, 500, "Failed to create booking");
  }
};

export const getUserBookings = async (req: Request, res: Response) => {
  const userId = req.user!.id;

  const bookings = await prisma.booking.findMany({
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

  sendResponse(res, 200, "User bookings fetched", bookings);
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
  await updateBookingStatus(req, res, "ACCEPTED");
};

export const rejectBooking = async (req: Request, res: Response) => {
  // If rejected, mark service as AVAILABLE again
  const { id } = req.params;
  const providerId = req.user!.id;

  try {
    await prisma.$transaction(async (tx) => {
      const booking = await tx.booking.findUnique({ where: { id } });
      if (!booking || booking.providerId !== providerId) throw new Error("AUTH_ERROR");

      await tx.booking.update({
        where: { id },
        data: { status: "REJECTED" }
      });

      await tx.service.update({
        where: { id: booking.serviceId },
        data: { status: "AVAILABLE" }
      });
    });
    sendResponse(res, 200, "Booking rejected and service freed");
  } catch (error) {
    sendError(res, 403, "Failed to reject booking");
  }
};

export const startBooking = async (req: Request, res: Response) => {
  await updateBookingStatus(req, res, "IN_PROGRESS");
};

export const completeBooking = async (req: Request, res: Response) => {
  const { id } = req.params;
  const providerId = req.user!.id;

  try {
    const result = await prisma.$transaction(async (tx) => {
      const booking = await tx.booking.findUnique({ where: { id } });
      if (!booking || booking.providerId !== providerId) throw new Error("AUTH_ERROR");

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

    sendResponse(res, 200, "Job completed and stats updated", result);
  } catch (error) {
    console.error("Complete Job Error:", error);
    sendError(res, 403, "Failed to complete job");
  }
};

const updateBookingStatus = async (req: Request, res: Response, status: any) => {
  const providerId = req.user!.id;
  const { id } = req.params;

  const booking = await prisma.booking.findUnique({ where: { id } });
  if (!booking) return sendError(res, 404, "Booking not found");
  if (booking.providerId !== providerId) return sendError(res, 403, "Not authorized");

  const updated = await prisma.booking.update({
    where: { id },
    data: { status }
  });

  sendResponse(res, 200, `Status updated to ${status}`, updated);
};
