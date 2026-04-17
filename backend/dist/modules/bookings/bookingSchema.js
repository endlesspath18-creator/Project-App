"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.updateBookingStatusSchema = exports.createBookingSchema = void 0;
const zod_1 = require("zod");
exports.createBookingSchema = zod_1.z.object({
    body: zod_1.z.object({
        serviceId: zod_1.z.string().uuid("Invalid service ID"),
        bookingDate: zod_1.z.string().datetime("Invalid ISO date string"),
        address: zod_1.z.string().min(5, "Address must be at least 5 characters"),
    })
});
// Providers updating status
exports.updateBookingStatusSchema = zod_1.z.object({
    body: zod_1.z.object({
        status: zod_1.z.enum(["ACCEPTED", "REJECTED", "IN_PROGRESS", "COMPLETED", "CANCELLED"]),
    })
});
