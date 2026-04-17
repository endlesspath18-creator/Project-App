import { Request, Response, NextFunction } from "express";
import { sendError } from "../utils/response";

export const requireRole = (role: "USER" | "PROVIDER") => {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.user) {
      return sendError(res, 401, "Not authorized");
    }

    if (req.user.role !== role) {
      return sendError(res, 403, `Forbidden: Only ${role} can access this route`);
    }

    next();
  };
};
