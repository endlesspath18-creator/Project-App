"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.errorHandler = void 0;
const zod_1 = require("zod");
const response_1 = require("../utils/response");
const errorHandler = (err, req, res, next) => {
    console.error(`[Error] ${err.name}: ${err.message}`);
    // Handle Syntax Errors
    if (err instanceof SyntaxError && "body" in err) {
        return (0, response_1.sendError)(res, 400, "Invalid JSON payload parsed");
    }
    // Handle Validation Errors
    if (err instanceof zod_1.ZodError) {
        const formattedErrors = err.errors.map((e) => ({
            field: e.path.join("."),
            message: e.message,
        }));
        return (0, response_1.sendError)(res, 400, "Validation failed", formattedErrors);
    }
    // Handle Prisma Errors
    if (err.name === "PrismaClientKnownRequestError") {
        // Example: Unique constraint violation
        if (err.code === "P2002") {
            return (0, response_1.sendError)(res, 409, "Duplicate resource. Field already exists.");
        }
    }
    const statusCode = res.statusCode !== 200 ? res.statusCode : 500;
    return (0, response_1.sendError)(res, statusCode, err.message || "Internal Server Error");
};
exports.errorHandler = errorHandler;
