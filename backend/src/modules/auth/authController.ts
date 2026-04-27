import { Request, Response } from "express";
import { prisma } from "../../config/db";
import { hashPassword, verifyPassword } from "../../utils/hash";
import { generateAccessToken, generateRefreshToken, verifyRefreshToken } from "../../utils/jwt";
import { sendResponse, sendError } from "../../utils/response";


export const register = async (req: Request, res: Response) => {
  console.log("[AuthController] Registration Attempt:", { 
    email: req.body.email, 
    role: req.body.role,
  });

  const { fullName, email, phone, password, role, businessName } = req.body;
  const normalizedEmail = email.toLowerCase().trim();

  try {
    const userExists = await prisma.user.findFirst({
      where: { OR: [{ email: normalizedEmail }, ...(phone ? [{ phone: phone }] : [])] },
    });

    if (userExists) {
      return sendError(res, 400, "User already exists with this email or phone number.");
    }

    const passwordHash = await hashPassword(password);
    
    // Generate 6-digit OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const otpExpiry = new Date(Date.now() + 15 * 60 * 1000); // 15 mins

    const result = await prisma.$transaction(async (tx) => {
      const user = await tx.user.create({
        data: {
          fullName,
          email: normalizedEmail,
          phone,
          passwordHash,
          role,
          isActive: false, // Must verify first
          verificationCode: otp,
          otpExpiry,
        },
      });

      if (role === "PROVIDER" && businessName) {
        await tx.providerProfile.create({
          data: { userId: user.id, businessName },
        });
      }

      return user;
    });

    // In a real app, send OTP via SMS/Email here
    console.log(`[AUTH] OTP for ${normalizedEmail}: ${otp}`);

    return sendResponse(res, 201, "Registration successful. Please verify your account.", {
      userId: result.id,
      email: result.email,
      phone: result.phone,
      // For development ease, we return the OTP. REMOVE IN PRODUCTION!
      debugOtp: otp, 
    });
  } catch (error: any) {
    console.error("[AuthController] Registration Error:", error);
    return sendError(res, 500, "Failed to create account.");
  }
};

export const verifyOtp = async (req: Request, res: Response) => {
  const { email, otp } = req.body;

  try {
    const user = await prisma.user.findUnique({
      where: { email: email.toLowerCase().trim() }
    });

    if (!user) return sendError(res, 404, "User not found.");
    if (user.isActive) return sendError(res, 400, "Account is already active.");

    if (user.verificationCode !== otp) {
      return sendError(res, 400, "Invalid verification code.");
    }

    if (user.otpExpiry && user.otpExpiry < new Date()) {
      return sendError(res, 400, "Verification code has expired.");
    }

    // Mark as verified and active
    await prisma.user.update({
      where: { id: user.id },
      data: {
        isActive: true,
        isEmailVerified: true,
        isPhoneVerified: true,
        verificationCode: null,
        otpExpiry: null,
      }
    });

    const { accessToken, refreshToken } = await generateAndSaveTokens(user.id, user.role);

    return sendResponse(res, 200, "Account verified successfully", {
      token: accessToken,
      refreshToken,
      user: {
        id: user.id,
        fullName: user.fullName,
        email: user.email,
        role: user.role,
        isRoleSet: user.isRoleSet,
      },
    });
  } catch (error: any) {
    return sendError(res, 500, "Verification failed.");
  }
};

export const login = async (req: Request, res: Response) => {
  const { email, password } = req.body;

  // Normalization for login lookup
  const identifier = email.toLowerCase().trim();

  console.log("[AuthController] Login Attempt:", identifier);

  try {
    const user = await prisma.user.findFirst({
      where: { 
        OR: [
          { email: identifier },
          { phone: email } 
        ]
      },
      include: {
        providerProfile: true,
      },
    });

    // Step 1: Check user existence
    if (!user) {
      console.log("[AuthController] Login Failed: User not found", identifier);
      return sendError(res, 401, "No account found with these credentials.");
    }

    // Step 2: Check active status
    if (!user.isActive) {
      if (user.verificationCode) {
        return sendError(res, 403, "Account not verified. Please verify your email/phone.");
      }
      return sendError(res, 403, "Your account is currently inactive. Please contact support.");
    }

    // Step 3: Handle Social Login Collision
    if (!user.passwordHash) {
      return sendError(res, 401, "This account is linked with Google. Please login using Google.");
    }

    // Step 4: Verify Password
    const isMatch = await verifyPassword(password, user.passwordHash);

    if (!isMatch) {
      console.log("[AuthController] Login Failed: Invalid Password", identifier);
      return sendError(res, 401, "The password you entered is incorrect.");
    }

    // Step 5: Success
    const { accessToken, refreshToken } = await generateAndSaveTokens(user.id, user.role);

    console.log("[AuthController] Login Successful:", user.id);
    return sendResponse(res, 200, "Login successful", {
      token: accessToken,
      refreshToken,
      user: {
        id: user.id,
        fullName: user.fullName,
        email: user.email,
        role: user.role,
        isRoleSet: user.isRoleSet,
        hasPaidPublishingFee: user.hasPaidPublishingFee,
        canPublishService: user.canPublishService,
        providerProfile: user.providerProfile,
      },
    });
  } catch (error: any) {
    console.error("[AuthController] FATAL_LOGIN_ERROR:", error);
    return sendError(res, 500, `Internal server error: ${error.message}`);
  }
};

export const getMe = async (req: Request, res: Response) => {
  const userId = req.user?.id;

  if (!userId) {
    return sendError(res, 401, "Session invalid. Please log in again.");
  }

  try {
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
        hasPaidPublishingFee: true,
        canPublishService: true,
        createdAt: true,
        providerProfile: true,
      },
    });

    if (!user) {
      return sendError(res, 404, "User profile not found.");
    }

    return sendResponse(res, 200, "User profile retrieved", user);
  } catch (error) {
    console.error("[AuthController] GET_ME_ERROR:", error);
    return sendError(res, 500, "Internal server error.");
  }
};

export const updateProfile = async (req: Request, res: Response) => {
  const userId = req.user!.id;
  const { fullName, phone } = req.body;

  try {
    const updatedUser = await prisma.user.update({
      where: { id: userId },
      data: {
        fullName: fullName || undefined,
        phone: phone || undefined,
      },
    });

    return sendResponse(res, 200, "Profile updated successfully", updatedUser);
  } catch (error: any) {
    console.error("[AuthController] UPDATE_PROFILE_ERROR:", error);
    return sendError(res, 500, "Failed to update profile.");
  }
};

export const updatePassword = async (req: Request, res: Response) => {
  const userId = req.user!.id;
  const { currentPassword, newPassword } = req.body;

  try {
    const user = await prisma.user.findUnique({ where: { id: userId } });
    if (!user || !user.passwordHash) {
      return sendError(res, 404, "User not found or password not set.");
    }

    const isMatch = await verifyPassword(currentPassword, user.passwordHash);
    if (!isMatch) {
      return sendError(res, 401, "Current password incorrect.");
    }

    const newHash = await hashPassword(newPassword);
    await prisma.user.update({
      where: { id: userId },
      data: { passwordHash: newHash },
    });

    return sendResponse(res, 200, "Password updated successfully.");
  } catch (error: any) {
    console.error("[AuthController] UPDATE_PASSWORD_ERROR:", error);
    return sendError(res, 500, "Failed to update password.");
  }
};

export const logout = async (req: Request, res: Response) => {
  const { refreshToken } = req.body;
  if (refreshToken) {
    await prisma.refreshToken.deleteMany({ where: { token: refreshToken } });
  }
  return sendResponse(res, 200, "Logged out successfully.");
};

export const refresh = async (req: Request, res: Response) => {
  const { refreshToken } = req.body;
  if (!refreshToken) return sendError(res, 400, "Refresh token required");

  try {
    const payload = verifyRefreshToken(refreshToken);
    const storedToken = await prisma.refreshToken.findUnique({
      where: { token: refreshToken },
    });

    if (!storedToken || storedToken.expiresAt < new Date()) {
      if (storedToken) await prisma.refreshToken.delete({ where: { id: storedToken.id } });
      return sendError(res, 401, "Invalid or expired refresh token");
    }

    // Generate new access token
    const accessToken = generateAccessToken({ id: payload.id, role: payload.role });
    return sendResponse(res, 200, "Token refreshed", { accessToken });
  } catch (error) {
    return sendError(res, 401, "Invalid refresh token");
  }
};

const generateAndSaveTokens = async (userId: string, role: string) => {
  const accessToken = generateAccessToken({ id: userId, role });
  const refreshToken = generateRefreshToken({ id: userId, role });
  
  // Save refresh token to DB (limit to 5 sessions per user for security)
  const tokenCount = await prisma.refreshToken.count({ where: { userId } });
  if (tokenCount >= 5) {
    await prisma.refreshToken.deleteMany({ where: { userId } }); // Simple flush for now
  }

  await prisma.refreshToken.create({
    data: {
      token: refreshToken,
      userId,
      expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // 30 days
    }
  });

  return { accessToken, refreshToken };
};
