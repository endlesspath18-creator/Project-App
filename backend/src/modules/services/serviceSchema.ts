import { z } from "zod";

export const createServiceSchema = z.object({
  body: z.object({
    title: z.string().min(3, "Title must be at least 3 characters"),
    category: z.string().min(2, "Category is required"),
    description: z.string().min(10, "Description must be at least 10 characters"),
    price: z.number().positive("Price must be positive"),
    durationMinutes: z.number().int().positive("Duration must be a positive integer"),
  })
});

export const updateServiceSchema = z.object({
  body: z.object({
    title: z.string().min(3).optional(),
    category: z.string().min(2).optional(),
    description: z.string().min(10).optional(),
    price: z.number().positive().optional(),
    durationMinutes: z.number().int().positive().optional(),
    isActive: z.boolean().optional(),
  })
});
