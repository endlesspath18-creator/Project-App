import { z } from "zod";

export const updateProfileSchema = z.object({
  fullName: z.string().min(2).optional(),
  phone: z.string().min(10).optional(),
  profileImage: z.string().url().optional(),
});

export const changePasswordSchema = z.object({
  oldPassword: z.string().min(6),
  newPassword: z.string().min(6),
});

export const createSupportTicketSchema = z.object({
  subject: z.string().min(5),
  description: z.string().min(10),
  category: z.string().optional(),
  bookingId: z.string().uuid().optional(),
  priority: z.enum(["LOW", "MEDIUM", "HIGH"]).optional(),
});

export const addFavoriteSchema = z.object({
  serviceId: z.string().uuid().optional(),
  providerId: z.string().uuid().optional(),
}).refine(data => data.serviceId || data.providerId, {
  message: "Either serviceId or providerId must be provided",
});
