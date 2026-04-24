import { Request, Response } from "express";
import { prisma } from "../../config/db";
import { sendSuccess, sendError } from "../../utils/response";

export const getDashboardStats = async (req: Request, res: Response) => {
  try {
    const [userCount, providerCount, bookingCount, serviceCount, bookings] = await Promise.all([
      prisma.user.count({ where: { role: "USER" } }),
      prisma.user.count({ where: { role: "PROVIDER" } }),
      prisma.booking.count(),
      prisma.service.count(),
      prisma.booking.findMany({ select: { amount: true } }),
    ]);

    const revenue = bookings.reduce((sum, b) => sum + b.amount, 0);

    sendSuccess(res, "Admin stats fetched", {
      totalUsers: userCount,
      totalProviders: providerCount,
      totalBookings: bookingCount,
      totalServices: serviceCount,
      totalRevenue: revenue,
    });
  } catch (error) {
    sendError(res, 500, "Failed to fetch dashboard stats");
  }
};

export const getAllUsers = async (req: Request, res: Response) => {
  try {
    const users = await prisma.user.findMany({
      where: { role: "USER" },
      orderBy: { createdAt: "desc" },
    });
    sendSuccess(res, "Users fetched", users);
  } catch (error) {
    sendError(res, 500, "Failed to fetch users");
  }
};

export const getAllProviders = async (req: Request, res: Response) => {
  try {
    const providers = await prisma.user.findMany({
      where: { role: "PROVIDER" },
      include: { providerProfile: true },
      orderBy: { createdAt: "desc" },
    });
    sendSuccess(res, "Providers fetched", providers);
  } catch (error) {
    sendError(res, 500, "Failed to fetch providers");
  }
};

export const toggleUserStatus = async (req: Request, res: Response) => {
  const { id } = req.params;
  try {
    const user = await prisma.user.findUnique({ where: { id } });
    if (!user) return sendError(res, 404, "User not found");

    const updatedUser = await prisma.user.update({
      where: { id },
      data: { isActive: !user.isActive },
    });

    sendSuccess(res, `User ${updatedUser.isActive ? "activated" : "deactivated"}`, updatedUser);
  } catch (error) {
    sendError(res, 500, "Failed to toggle user status");
  }
};

export const getAllBookings = async (req: Request, res: Response) => {
  try {
    const bookings = await prisma.booking.findMany({
      include: {
        user: { select: { fullName: true, email: true } },
        provider: { select: { fullName: true } },
        service: { select: { title: true } },
      },
      orderBy: { createdAt: "desc" },
    });
    sendSuccess(res, "Bookings fetched", bookings);
  } catch (error) {
    sendError(res, 500, "Failed to fetch bookings");
  }
};
