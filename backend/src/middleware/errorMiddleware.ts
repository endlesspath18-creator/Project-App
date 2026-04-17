import { Request, Response, NextFunction } from "express";
import { ZodError } from "zod";
import { sendError } from "../utils/response";

export const errorHandler = (
  err: Error,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  console.error(`[Error] ${err.name}: ${err.message}`);

  // Handle Syntax Errors
  if (err instanceof SyntaxError && "body" in err) {
    return sendError(res, 400, "Invalid JSON payload parsed");
  }

  // Handle Validation Errors
  if (err instanceof ZodError) {
    const formattedErrors = err.errors.map((e) => ({
      field: e.path.join("."),
      message: e.message,
    }));
    return sendError(res, 400, "Validation failed", formattedErrors);
  }

  // Handle Prisma Errors
  if (err.name === "PrismaClientKnownRequestError") {
    // Example: Unique constraint violation
    if ((err as any).code === "P2002") {
      return sendError(res, 409, "Duplicate resource. Field already exists.");
    }
  }

  const statusCode = res.statusCode !== 200 ? res.statusCode : 500;
  return sendError(res, statusCode, err.message || "Internal Server Error");
};
