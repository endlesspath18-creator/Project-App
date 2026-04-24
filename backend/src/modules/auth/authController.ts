import { Request, Response } from "express";
import { prisma } from "../../config/db";
import { hashPassword, verifyPassword } from "../../utils/hash";
import { generateToken } from "../../utils/jwt";
import { sendResponse, sendError } from "../../utils/response";

export const register = async (req: Request, res: Response) => {
  const { fullName, email, phone, password, role, businessName } = req.body;

  // Normalization
  const normalizedEmail = email.toLowerCase().trim();

  // Check if user already exists
  const userExists = await prisma.user.findFirst({
    where: { 
      OR: [
        { email: normalizedEmail },
        { phone: phone || '---' }
      ]
    },
  });

  if (userExists) {
    return sendError(res, 400, "User already exists with this email or phone number.");
  }

  // Hash password
  const passwordHash = await hashPassword(password);

  // Use transaction to ensure both user and profile are created together if provider
  try {
    const result = await prisma.$transaction(async (tx) => {
      const user = await tx.user.create({
        data: {
          fullName,
          email: normalizedEmail,
          phone,
          passwordHash,
          role,
          isActive: true, // Explicitly set to active during social/email registration
        },
      });

      if (role === "PROVIDER" && businessName) {
        await tx.providerProfile.create({
          data: {
            userId: user.id,
            businessName,
          },
        });
      }

      return user;
    });

    const token = generateToken({ id: result.id, role: result.role });

    return sendResponse(res, 201, "User registered successfully", {
      token,
      user: {
        id: result.id,
        fullName: result.fullName,
        email: result.email,
        role: result.role,
        isRoleSet: true,
      },
    });
  } catch (error: any) {
    console.error("REGISTRATION_ERROR:", error);
    return sendError(res, 500, "Failed to create account. Please try again.");
  }
};

export const login = async (req: Request, res: Response) => {
  const { email, password } = req.body;

  // Normalization for login lookup
  const identifier = email.toLowerCase().trim();

  const user = await prisma.user.findFirst({
    where: { 
      OR: [
        { email: identifier },
        { phone: email } // Allow phone login using original input
      ]
    },
    include: {
      providerProfile: true,
    },
  });

  // Step 1: Check user existence
  if (!user) {
    return sendError(res, 401, "No account found with these credentials.");
  }

  // Step 2: Check active status separately for better UX
  if (!user.isActive) {
    return sendError(res, 403, "Your account is currently inactive. Please contact support.");
  }

  // Step 3: Handle Social Login Collision
  if (!user.passwordHash) {
    return sendError(res, 401, "This account is linked with Google. Please login using Google.");
  }

  // Step 4: Verify Password
  const isMatch = await verifyPassword(password, user.passwordHash);

  if (!isMatch) {
    return sendError(res, 401, "The password you entered is incorrect.");
  }

  // Step 5: Success
  const token = generateToken({ id: user.id, role: user.role });

  return sendResponse(res, 200, "Login successful", {
    token,
    user: {
      id: user.id,
      fullName: user.fullName,
      email: user.email,
      role: user.role,
      isRoleSet: user.isRoleSet,
      providerProfile: user.providerProfile,
    },
  });
};

export const getMe = async (req: Request, res: Response) => {
  const userId = req.user?.id;

  if (!userId) {
    return sendError(res, 401, "Session invalid. Please log in again.");
  }

  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: {
      id: true,
      fullName: true,
      email: true,
      phone: true,
      role: true,
      isRoleSet: true,
      isActive: true,
      createdAt: true,
      providerProfile: true,
    },
  });

  if (!user) {
    return sendError(res, 404, "User profile not found.");
  }

  return sendResponse(res, 200, "User profile retrieved", user);
};

export const logout = async (req: Request, res: Response) => {
  return sendResponse(res, 200, "Logged out successfully.");
};
