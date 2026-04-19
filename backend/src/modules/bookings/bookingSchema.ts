import { z } from "zod";

export const createBookingSchema = z.object({
  body: z.object({
    serviceId: z.string().uuid("Invalid service ID"),
    scheduledDate: z.string().datetime("Invalid ISO date string"),
    address: z.string().min(5, "Address must be at least 5 characters"),
    notes: z.string().max(500, "Notes are too long").optional(),
  })
});

// Providers updating status
export const updateBookingStatusSchema = z.object({
  body: z.object({
    status: z.enum(["ACCEPTED", "REJECTED", "IN_PROGRESS", "COMPLETED", "CANCELLED"]),
  })
});
