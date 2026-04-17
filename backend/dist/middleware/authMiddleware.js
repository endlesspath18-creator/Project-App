"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.protect = void 0;
const jwt_1 = require("../utils/jwt");
const response_1 = require("../utils/response");
const db_1 = require("../config/db");
const protect = async (req, res, next) => {
    let token;
    if (req.headers.authorization && req.headers.authorization.startsWith("Bearer")) {
        token = req.headers.authorization.split(" ")[1];
    }
    if (!token) {
        return (0, response_1.sendError)(res, 401, "Not authorized to access this route");
    }
    try {
        const decoded = (0, jwt_1.verifyToken)(token);
        // Verify user still exists and isActive
        const user = await db_1.prisma.user.findUnique({
            where: { id: decoded.id },
            select: { id: true, role: true, isActive: true },
        });
        if (!user) {
            return (0, response_1.sendError)(res, 401, "User no longer exists");
        }
        if (!user.isActive) {
            return (0, response_1.sendError)(res, 403, "User account is deactivated");
        }
        req.user = decoded;
        next();
    }
    catch (error) {
        return (0, response_1.sendError)(res, 401, "Not authorized to access this route");
    }
};
exports.protect = protect;
