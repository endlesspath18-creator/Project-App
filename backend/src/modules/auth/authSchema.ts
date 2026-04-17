import { z } from "zod";

export const registerSchema = z.object({
  body: z.object({
    fullName: z.string().min(2, "Full name must be at least 2 characters"),
    email: z.string().email("Invalid email address"),
    phone: z.string().optional(),
    password: z.string().min(6, "Password must be at least 6 characters"),
    role: z.enum(["USER", "PROVIDER"]),
    businessName: z.string().optional(),
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

export const loginSchema = z.object({
  body: z.object({
    email: z.string().email("Invalid email address"),
    password: z.string().min(1, "Password is required"),
  })
});
