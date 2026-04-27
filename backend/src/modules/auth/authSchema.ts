import { z } from "zod";

export const registerSchema = z.object({
  body: z.object({
    fullName: z.string().min(2, "Full name must be at least 2 characters"),
    email: z.string().email("Invalid email address"),
    phone: z.string().optional(),
    password: z.string().min(6, "Password must be at least 6 characters"),
    role: z.enum(["USER", "PROVIDER"]),
    businessName: z.string().optional(),
    bankAccountName: z.string().optional(),
    bankAccountNumber: z.string().optional(),
    bankIFSC: z.string().optional(),
    bankName: z.string().optional(),
  }).refine((data) => {
    if (data.role === "PROVIDER") {
       if (!data.businessName || data.businessName.trim() === "") return false;
       // Make bank details required for providers during registration as requested
       if (!data.bankAccountName || !data.bankAccountNumber || !data.bankIFSC || !data.bankName) return false;
    }
    return true;
  }, {
    message: "Business name and complete bank details are required for Providers",
    path: ["role"]
  })
});

export const loginSchema = z.object({
  body: z.object({
    email: z.string().min(1, "Email or Phone is required"),
    password: z.string().min(1, "Password is required"),
  })
});

