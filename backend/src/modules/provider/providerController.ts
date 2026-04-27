import { Request, Response } from "express";
import { prisma } from "../../config/db";
import { sendResponse, sendError } from "../../utils/response";

export const getDashboardStats = async (req: Request, res: Response) => {
  const providerId = req.user!.id;

  try {
    const profile = await prisma.providerProfile.findUnique({
      where: { userId: providerId },
    });

    if (!profile) return sendError(res, 404, "Provider profile not found");

    // Get earnings (Total amount from COMPLETED bookings)
    const earnings = await prisma.booking.aggregate({
      where: { 
        providerId,
        status: "COMPLETED" 
      },
      _sum: {
        amount: true
      }
    });

    // Get counts
    const pendingCount = await prisma.booking.count({
      where: { providerId, status: "PENDING" }
    });

    const activeCount = await prisma.booking.count({
      where: { 
        providerId, 
        status: { in: ["ACCEPTED", "IN_PROGRESS"] } 
      }
    });

    const completedCount = profile.totalJobs;

    const requiresBankUpdate = !profile.bankAccountNumber || !profile.bankIFSC || !profile.bankName || !profile.bankAccountName;

    sendResponse(res, 200, "Dashboard stats fetched", {
      earnings: earnings._sum?.amount || 0,
      completedJobs: completedCount,
      pendingRequests: pendingCount,
      activeJobs: activeCount,
      rating: profile.rating,
      isOnline: profile.isOnline,
      requiresBankUpdate
    });
  } catch (error) {
    console.error("Dashboard Stats Error:", error);
    sendError(res, 500, "Failed to fetch dashboard stats");
  }
};

export const getIncomingRequests = async (req: Request, res: Response) => {
  const providerId = req.user!.id;

  const requests = await prisma.booking.findMany({
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

  sendResponse(res, 200, "Incoming requests fetched", requests);
};

export const getActiveJobs = async (req: Request, res: Response) => {
  const providerId = req.user!.id;

  const jobs = await prisma.booking.findMany({
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
    orderBy: { dateTime: "asc" }
  });

  sendResponse(res, 200, "Active jobs fetched", jobs);
};
export const updateProviderProfile = async (req: Request, res: Response) => {
  const userId = req.user!.id;
  const { 
    businessName, bio, experienceYears,
    bankAccountName, bankAccountNumber, bankIFSC, bankName 
  } = req.body;

  try {
    const profile = await prisma.providerProfile.update({
      where: { userId },
      data: {
        businessName: businessName || undefined,
        bio: bio || undefined,
        experienceYears: experienceYears ? parseInt(experienceYears) : undefined,
        bankAccountName: bankAccountName || undefined,
        bankAccountNumber: bankAccountNumber || undefined,
        bankIFSC: bankIFSC || undefined,
        bankName: bankName || undefined,
      },
    });

    return sendResponse(res, 200, "Business profile updated successfully", profile);
  } catch (error) {
    console.error("Update Provider Profile Error:", error);
    sendError(res, 500, "Failed to update business profile");
  }
};

export const toggleAvailability = async (req: Request, res: Response) => {
  const userId = req.user!.id;

  try {
    const profile = await prisma.providerProfile.findUnique({
      where: { userId },
    });

    if (!profile) return sendError(res, 404, "Provider profile not found");

    const updatedProfile = await prisma.providerProfile.update({
      where: { userId },
      data: { isOnline: !profile.isOnline },
    });

    return sendResponse(res, 200, `You are now ${updatedProfile.isOnline ? "Online" : "Offline"}`, updatedProfile);
  } catch (error) {
    console.error("Toggle Availability Error:", error);
    sendError(res, 500, "Failed to toggle online status");
  }
};
