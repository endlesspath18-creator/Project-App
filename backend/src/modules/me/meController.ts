import { Request, Response } from "express";
import { prisma } from "../../config/db";
import bcrypt from "bcrypt";

export const getDashboard = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user.id;

    const upcomingBookings = await prisma.booking.findMany({
      where: {
        userId,
        status: { in: ["ACCEPTED", "PROVIDER_ACCEPTED", "CONFIRMED"] },
        dateTime: { gte: new Date() },
      },
      include: {
        service: true,
        provider: {
          select: { fullName: true, profileImage: true },
        },
      },
      orderBy: { dateTime: "asc" },
      take: 5,
    });

    const stats = {
      totalBookings: await prisma.booking.count({ where: { userId } }),
      activeBookings: upcomingBookings.length,
      savedProviders: await prisma.favorite.count({ where: { userId, providerId: { not: null } } }),
    };

    const recentActivity = await prisma.bookingEvent.findMany({
      where: { booking: { userId } },
      orderBy: { createdAt: "desc" },
      take: 5,
      include: { booking: { include: { service: true } } },
    });

    res.status(200).json({
      success: true,
      data: {
        upcomingBookings,
        stats,
        recentActivity,
      },
    });
  } catch (error: any) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const getMyBookings = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user.id;
    const { status, page = 1, limit = 10 } = req.query;

    const where: any = { userId };
    if (status) {
      where.status = status;
    }

    const bookings = await prisma.booking.findMany({
      where,
      include: {
        service: true,
        provider: {
          select: { fullName: true, profileImage: true, phone: true },
        },
        reviews: true,
      },
      orderBy: { dateTime: "desc" },
      skip: (Number(page) - 1) * Number(limit),
      take: Number(limit),
    });

    const total = await prisma.booking.count({ where });

    res.status(200).json({
      success: true,
      data: bookings,
      meta: {
        total,
        page: Number(page),
        limit: Number(limit),
        totalPages: Math.ceil(total / Number(limit)),
      },
    });
  } catch (error: any) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const getFavorites = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user.id;

    const favorites = await prisma.favorite.findMany({
      where: { userId },
      include: {
        service: {
          include: { provider: { select: { fullName: true } } },
        },
        provider: {
          select: {
            id: true,
            fullName: true,
            profileImage: true,
            providerProfile: true,
          },
        },
      },
    });

    res.status(200).json({ success: true, data: favorites });
  } catch (error: any) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const addFavorite = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user.id;
    const { serviceId, providerId } = req.body;

    const favorite = await prisma.favorite.create({
      data: {
        userId,
        serviceId,
        providerId,
      },
    });

    res.status(201).json({ success: true, data: favorite });
  } catch (error: any) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const removeFavorite = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user.id;
    const { id } = req.params;

    await prisma.favorite.delete({
      where: { id, userId },
    });

    res.status(200).json({ success: true, message: "Removed from favorites" });
  } catch (error: any) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const getPayments = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user.id;

    const payments = await prisma.paymentTransaction.findMany({
      where: { userId },
      include: {
        booking: { include: { service: true } },
      },
      orderBy: { createdAt: "desc" },
    });

    res.status(200).json({ success: true, data: payments });
  } catch (error: any) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const getNotifications = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user.id;

    const notifications = await prisma.notification.findMany({
      where: { userId },
      orderBy: { createdAt: "desc" },
    });

    res.status(200).json({ success: true, data: notifications });
  } catch (error: any) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const markNotificationRead = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user.id;
    const { id } = req.params;

    await prisma.notification.update({
      where: { id, userId },
      data: { isRead: true },
    });

    res.status(200).json({ success: true, message: "Marked as read" });
  } catch (error: any) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const getProfile = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user.id;

    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: {
        addresses: true,
        providerProfile: true,
      },
    });

    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }

    // Omit password hash
    const { passwordHash, ...userWithoutPassword } = user;

    res.status(200).json({ success: true, data: userWithoutPassword });
  } catch (error: any) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const updateProfile = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user.id;
    const { fullName, phone, profileImage } = req.body;

    const user = await prisma.user.update({
      where: { id: userId },
      data: {
        fullName,
        phone,
        profileImage,
      },
    });

    res.status(200).json({ success: true, data: user });
  } catch (error: any) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const changePassword = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user.id;
    const { oldPassword, newPassword } = req.body;

    const user = await prisma.user.findUnique({ where: { id: userId } });
    if (!user || !user.passwordHash) {
      return res.status(404).json({ success: false, message: "User not found or no password set" });
    }

    const isMatch = await bcrypt.compare(oldPassword, user.passwordHash);
    if (!isMatch) {
      return res.status(400).json({ success: false, message: "Invalid old password" });
    }

    const hashedPassword = await bcrypt.hash(newPassword, 10);
    await prisma.user.update({
      where: { id: userId },
      data: { passwordHash: hashedPassword },
    });

    res.status(200).json({ success: true, message: "Password changed successfully" });
  } catch (error: any) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const createSupportTicket = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user.id;
    const { subject, description, category, bookingId, priority } = req.body;

    const ticket = await prisma.supportTicket.create({
      data: {
        userId,
        subject,
        description,
        category,
        bookingId,
        priority,
      },
    });

    res.status(201).json({ success: true, data: ticket });
  } catch (error: any) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const getSupportTickets = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user.id;

    const tickets = await prisma.supportTicket.findMany({
      where: { userId },
      orderBy: { createdAt: "desc" },
    });

    res.status(200).json({ success: true, data: tickets });
  } catch (error: any) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const logoutAllDevices = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user.id;

    await prisma.refreshToken.deleteMany({
      where: { userId },
    });

    res.status(200).json({ success: true, message: "Logged out from all devices" });
  } catch (error: any) {
    res.status(500).json({ success: false, message: error.message });
  }
};
