import { Request, Response, NextFunction } from "express";
import { verifyToken, JwtPayload } from "../utils/jwt";
import { sendError } from "../utils/response";
import { prisma } from "../config/db";

// Extend Express Request to include user
declare global {
  namespace Express {
    interface Request {
      user?: JwtPayload & { isActive?: boolean };
    }
  }
}

export const protect = async (req: Request, res: Response, next: NextFunction) => {
  let token;

  if (req.headers.authorization && req.headers.authorization.startsWith("Bearer")) {
    token = req.headers.authorization.split(" ")[1];
  }

  if (!token) {
    return sendError(res, 401, "Not authorized to access this route");
  }

  try {
    const decoded = verifyToken(token);

    // Verify user still exists and isActive
    const user = await prisma.user.findUnique({
      where: { id: decoded.id },
      select: { id: true, role: true, isActive: true },
    });

    if (!user) {
      return sendError(res, 401, "User no longer exists");
    }

    if (!user.isActive) {
      return sendError(res, 403, "User account is deactivated");
    }

    if (decoded.role && decoded.role !== user.role) {
      return sendError(res, 401, "Role mismatch, please login again");
    }

    req.user = decoded;
    next();
  } catch (error) {
    return sendError(res, 401, "Not authorized to access this route");
  }
};

export const adminOnly = (req: Request, res: Response, next: NextFunction) => {
  if (req.user && req.user.role === "ADMIN") {
    next();
  } else {
    return sendError(res, 403, "Access denied: Admin role required");
  }
};
