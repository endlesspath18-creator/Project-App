import { Request, Response } from "express";
import { prisma } from "../../config/db";
import { sendResponse, sendError } from "../../utils/response";

export const getDashboardStats = async (req: Request, res: Response) => {
  try {
    const [userCount, providerCount, bookingCount, serviceCount, bookingStats, activationStats] = await Promise.all([
      prisma.user.count({ where: { role: "USER" } }),
      prisma.user.count({ where: { role: "PROVIDER" } }),
      prisma.booking.count(),
      prisma.service.count(),
      prisma.paymentTransaction.aggregate({
        where: { type: "BOOKING", status: "SUCCESS" },
        _sum: { amount: true, commissionAmount: true }
      }),
      prisma.paymentTransaction.aggregate({
        where: { type: "PROVIDER_ACTIVATION", status: "SUCCESS" },
        _sum: { amount: true }
      }),
    ]);

    const bookingRevenue = bookingStats._sum.amount ?? 0;
    const bookingCommission = bookingStats._sum.commissionAmount ?? 0;
    const activationRevenue = activationStats._sum.amount ?? 0;

    sendResponse(res, 200, "Admin stats fetched", {
      totalUsers: userCount,
      totalProviders: providerCount,
      totalBookings: bookingCount,
      totalServices: serviceCount,
      bookingRevenue,
      bookingCommission,
      activationRevenue,
      totalPlatformEarnings: bookingCommission + activationRevenue,
    });
  } catch (error) {
    sendError(res, 500, "Failed to fetch dashboard stats");
  }
};

export const getPayoutSettings = async (req: Request, res: Response) => {
  try {
    const settings = await prisma.adminPaymentConfig.findFirst();
    if (!settings) return sendResponse(res, 200, "Payout settings fetched", {});

    // Mask sensitive account number for security
    const masked = {
      ...settings,
      accountNumber: settings.accountNumber 
        ? `****${settings.accountNumber.slice(-4)}` 
        : null
    };

    sendResponse(res, 200, "Payout settings fetched", masked);
  } catch (error) {
    sendError(res, 500, "Failed to fetch payout settings");
  }
};

export const updatePayoutSettings = async (req: Request, res: Response) => {
  const { upiId, accountName, bankName, accountNumber, ifscCode } = req.body;
  const adminEmail = "endlesspath18@gmail.com";

  try {
    const user = await prisma.user.findUnique({ where: { id: req.user!.id } });
    if (!user || user.email !== adminEmail) {
      console.warn(`SECURITY_ALERT: Unauthorized payout settings change attempt by ${user?.email}`);
      return sendError(res, 403, "Access Denied: Only the primary admin can edit finance details.");
    }

    const existing = await prisma.adminPaymentConfig.findFirst();
    let settings;
    
    await prisma.$transaction(async (tx) => {
      const dataToUpdate: any = { upiId, accountName, bankName, ifscCode };
      
      // Only update account number if it's not masked or empty
      if (accountNumber && !accountNumber.startsWith("****")) {
        dataToUpdate.accountNumber = accountNumber;
      }

      if (existing) {
        settings = await tx.adminPaymentConfig.update({
          where: { id: existing.id },
          data: dataToUpdate,
        });
      } else {
        settings = await tx.adminPaymentConfig.create({
          data: { ...dataToUpdate, accountNumber: accountNumber || "" },
        });
      }

      await tx.auditLog.create({
        data: {
          userId: user.id,
          action: "UPDATE_PAYOUT_SETTINGS",
          details: `Payout settings updated by ${adminEmail}. UPI: ${upiId}, Bank: ${bankName}`,
          ipAddress: req.ip
        }
      });
    });

    sendResponse(res, 200, "Payout settings updated and audited", settings);
  } catch (error) {
    console.error("ADMIN_FINANCE_ERROR:", error);
    sendError(res, 500, "Failed to update secure payout settings");
  }
};

export const getRevenueStats = async (req: Request, res: Response) => {
  try {
    const stats = await prisma.$transaction([
      prisma.paymentTransaction.groupBy({
        by: ['type'],
        _sum: { amount: true },
        where: { status: "SUCCESS" },
        orderBy: { type: 'asc' }
      }),
      prisma.booking.aggregate({
        _sum: { amount: true },
        where: { paymentStatus: "PAID" }
      })
    ]);
    sendResponse(res, 200, "Revenue stats fetched", stats);
  } catch (error) {
    sendError(res, 500, "Failed to fetch revenue stats");
  }
};

export const getAllTransactions = async (req: Request, res: Response) => {
  try {
    const transactions = await prisma.paymentTransaction.findMany({
      include: { user: { select: { fullName: true, email: true } } },
      orderBy: { createdAt: "desc" }
    });
    sendResponse(res, 200, "Transactions fetched", transactions);
  } catch (error) {
    sendError(res, 500, "Failed to fetch transactions");
  }
};

export const getAllUsers = async (req: Request, res: Response) => {
  try {
    const users = await prisma.user.findMany({
      where: { role: "USER" },
      orderBy: { createdAt: "desc" },
    });
    sendResponse(res, 200, "Users fetched", users);
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
    sendResponse(res, 200, "Providers fetched", providers);
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

    sendResponse(res, 200, `User ${updatedUser.isActive ? "activated" : "deactivated"}`, updatedUser);
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
    sendResponse(res, 200, "Bookings fetched", bookings);
  } catch (error) {
    sendError(res, 500, "Failed to fetch bookings");
  }
};

export const verifyProvider = async (req: Request, res: Response) => {
  const { id } = req.params;
  const { isVerified } = req.body;

  try {
    const updatedUser = await prisma.user.update({
      where: { id },
      data: { isVerified },
    });

    await prisma.auditLog.create({
      data: {
        userId: req.user!.id,
        action: isVerified ? "VERIFY_PROVIDER" : "UNVERIFY_PROVIDER",
        details: `Provider ${id} verification set to ${isVerified} by admin ${req.user!.email}`,
        ipAddress: req.ip
      }
    });

    sendResponse(res, 200, `Provider ${isVerified ? "verified" : "unverified"} successfully`, updatedUser);
  } catch (error) {
    sendError(res, 500, "Failed to update provider verification status");
  }
};

export const manualUnlockProvider = async (req: Request, res: Response) => {
  const { id } = req.params;
  try {
    const updatedUser = await prisma.user.update({
      where: { id },
      data: { 
        hasPaidPublishingFee: true,
        canPublishService: true
      },
    });

    await prisma.auditLog.create({
      data: {
        userId: req.user!.id,
        action: "MANUAL_UNLOCK_PROVIDER",
        details: `Provider ${id} manually unlocked by admin ${req.user!.email}`,
        ipAddress: req.ip
      }
    });

    sendResponse(res, 200, "Provider manually unlocked for publishing", updatedUser);
  } catch (error) {
    sendError(res, 500, "Failed to unlock provider");
  }
};
