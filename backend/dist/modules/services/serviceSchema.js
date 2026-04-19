"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.updateServiceSchema = exports.createServiceSchema = void 0;
const zod_1 = require("zod");
exports.createServiceSchema = zod_1.z.object({
    body: zod_1.z.object({
        title: zod_1.z.string().min(3, "Title must be at least 3 characters"),
        category: zod_1.z.string().min(2, "Category is required"),
        description: zod_1.z.string().min(10, "Description must be at least 10 characters"),
        price: zod_1.z.number().positive("Price must be positive"),
        durationMinutes: zod_1.z.number().int().positive("Duration must be a positive integer"),
        images: zod_1.z.array(zod_1.z.string().url("Invalid image URL")).optional(),
    })
});
exports.updateServiceSchema = zod_1.z.object({
    body: zod_1.z.object({
        title: zod_1.z.string().min(3).optional(),
        category: zod_1.z.string().min(2).optional(),
        description: zod_1.z.string().min(10).optional(),
        price: zod_1.z.number().positive().optional(),
        durationMinutes: zod_1.z.number().int().positive().optional(),
        isActive: zod_1.z.boolean().optional(),
        status: zod_1.z.enum(["AVAILABLE", "BUSY", "DISABLED"]).optional(),
        images: zod_1.z.array(zod_1.z.string().url()).optional(),
    })
});
