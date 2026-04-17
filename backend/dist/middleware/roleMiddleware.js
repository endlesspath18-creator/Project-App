"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.requireRole = void 0;
const response_1 = require("../utils/response");
const requireRole = (role) => {
    return (req, res, next) => {
        if (!req.user) {
            return (0, response_1.sendError)(res, 401, "Not authorized");
        }
        if (req.user.role !== role) {
            return (0, response_1.sendError)(res, 403, `Forbidden: Only ${role} can access this route`);
        }
        next();
    };
};
exports.requireRole = requireRole;
