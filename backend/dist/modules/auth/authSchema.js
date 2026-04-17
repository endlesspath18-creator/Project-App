"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.loginSchema = exports.registerSchema = void 0;
const zod_1 = require("zod");
exports.registerSchema = zod_1.z.object({
    body: zod_1.z.object({
        fullName: zod_1.z.string().min(2, "Full name must be at least 2 characters"),
        email: zod_1.z.string().email("Invalid email address"),
        phone: zod_1.z.string().optional(),
        password: zod_1.z.string().min(6, "Password must be at least 6 characters"),
        role: zod_1.z.enum(["USER", "PROVIDER"]),
        businessName: zod_1.z.string().optional(),
    }).refine((data) => {
        if (data.role === "PROVIDER" && (!data.businessName || data.businessName.trim() === "")) {
            return false;
        }
        return true;
    }, {
        message: "businessName is required when role is PROVIDER",
        path: ["businessName"]
    })
});
exports.loginSchema = zod_1.z.object({
    body: zod_1.z.object({
        email: zod_1.z.string().email("Invalid email address"),
        password: zod_1.z.string().min(1, "Password is required"),
    })
});
