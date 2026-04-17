import { Request, Response, NextFunction } from "express";
import { sendError } from "../utils/response";

export const notFound = (req: Request, res: Response, next: NextFunction) => {
  return sendError(res, 404, `Route not found: ${req.originalUrl}`);
};
