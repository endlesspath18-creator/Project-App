import { Request, Response } from "express";
import { prisma } from "../../config/db";
import { hashPassword, verifyPassword } from "../../utils/hash";
import { generateToken } from "../../utils/jwt";
import { sendResponse, sendError } from "../../utils/response";

export const register = async (req: Request, res: Response) => {
  const { fullName, email, phone, password, role, businessName } = req.body;

  // Check if user already exists
  const userExists = await prisma.user.findUnique({
    where: { email },
  });

  if (userExists) {
    return sendError(res, 400, "User already exists with this email");
  }

  // Hash password
  const passwordHash = await hashPassword(password);

  // Use transaction to ensure both user and profile are created together if provider
  const result = await prisma.$transaction(async (tx) => {
    const user = await tx.user.create({
      data: {
        fullName,
        email,
        phone,
        passwordHash,
        role,
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

  sendResponse(res, 201, "User registered successfully", {
    token,
    user: {
      id: result.id,
      fullName: result.fullName,
      email: result.email,
      role: result.role,
    },
  });
};

export const login = async (req: Request, res: Response) => {
  const { email, password } = req.body;

  const user = await prisma.user.findUnique({
    where: { email },
    include: {
      providerProfile: true,
    },
  });

  if (!user || !user.isActive) {
    return sendError(res, 401, "Invalid credentials or inactive account");
  }

  const isMatch = await verifyPassword(password, user.passwordHash);

  if (!isMatch) {
    return sendError(res, 401, "Invalid credentials");
  }

  const token = generateToken({ id: user.id, role: user.role });

  sendResponse(res, 200, "Login successful", {
    token,
    user: {
      id: user.id,
      fullName: user.fullName,
      email: user.email,
      role: user.role,
      providerProfile: user.providerProfile,
    },
  });
};

export const getMe = async (req: Request, res: Response) => {
  const userId = req.user?.id;

  if (!userId) {
    return sendError(res, 401, "User not found");
  }

  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: {
      id: true,
      fullName: true,
      email: true,
      phone: true,
      role: true,
      isActive: true,
      createdAt: true,
      providerProfile: true, // Auto includes if they are provider
    },
  });

  if (!user) {
    return sendError(res, 404, "User not found");
  }

  sendResponse(res, 200, "User profile retrieved", user);
};

export const logout = async (req: Request, res: Response) => {
  // Since we use JWTs, logout is typically handled client-side by dropping the token.
  // Placeholder structure for token blacklisting if needed in future
  sendResponse(res, 200, "Logged out successfully (Please clear token on client)");
};
