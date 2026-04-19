import { Request, Response } from "express";
import { prisma } from "../../config/db";
import { hashPassword, verifyPassword } from "../../utils/hash";
import { generateToken } from "../../utils/jwt";
import { sendResponse, sendError } from "../../utils/response";
import { OAuth2Client } from "google-auth-library";

const googleClientId = process.env.GOOGLE_CLIENT_ID || "";
const client = new OAuth2Client(googleClientId);

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

  if (!user.passwordHash) {
    return sendError(res, 401, "This account is linked with Google. Please login using Google.");
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
      isRoleSet: true,
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

export const googleLogin = async (req: Request, res: Response) => {
  const { idToken } = req.body;

  try {
    const ticket = await client.verifyIdToken({
      idToken,
      audience: googleClientId,
    });

    const payload = ticket.getPayload();
    if (!payload || !payload.email) {
      return sendError(res, 400, "Invalid ID Token");
    }

    const { email, name, sub: googleId } = payload;

    // Find or create user
    let user = await prisma.user.findUnique({
      where: { email },
      include: { providerProfile: true }
    });

    if (!user) {
      // Create new user (role selection mandatory next)
      user = await prisma.user.create({
        data: {
          email,
          fullName: name || "Google User",
          googleId,
          isRoleSet: false,
          // role defaults to USER, but isRoleSet = false triggers onboarding
        },
        include: { providerProfile: true }
      });
    } else if (!user.googleId) {
      // Link Google ID if it's an existing email user
      user = await prisma.user.update({
        where: { id: user.id },
        data: { googleId },
        include: { providerProfile: true }
      });
    }

    const token = generateToken({ id: user.id, role: user.role });

    sendResponse(res, 200, "Google login successful", {
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
  } catch (error) {
    console.error("Google login verification failed:", error);
    return res.status(401).json({ message: "Google authentication failed" });
  }
};

export const completeSocialSignup = async (req: Request, res: Response) => {
  const userId = req.user?.id;
  const { role, businessName } = req.body;

  if (!userId) {
    return sendError(res, 401, "Not authenticated");
  }

  const user = await prisma.user.findUnique({ where: { id: userId } });
  if (!user) {
    return sendError(res, 404, "User not found");
  }

  if (user.isRoleSet) {
    return sendError(res, 400, "Role is already set and cannot be changed");
  }

  const result = await prisma.$transaction(async (tx) => {
    const updatedUser = await tx.user.update({
      where: { id: userId },
      data: {
        role,
        isRoleSet: true,
      },
    });

    if (role === "PROVIDER" && businessName) {
      await tx.providerProfile.create({
        data: {
          userId,
          businessName,
        },
      });
    }

    return updatedUser;
  });

  const token = generateToken({ id: result.id, role: result.role });

  sendResponse(res, 200, "Profile completed successfully", {
    token,
    user: {
      id: result.id,
      fullName: result.fullName,
      email: result.email,
      role: result.role,
      isRoleSet: true,
    },
  });
};

