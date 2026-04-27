import express, { Application, Request, Response } from "express";
import cors from "cors";
import { errorHandler } from "./middleware/errorMiddleware";
import { notFound } from "./middleware/notFound";

// Route imports
import authRoutes from "./modules/auth/authRoutes";
import serviceRoutes from "./modules/services/serviceRoutes";
import bookingRoutes from "./modules/bookings/bookingRoutes";
import paymentRoutes from "./modules/payments/paymentRoutes";
import reviewRoutes from "./modules/reviews/reviewRoutes";
import providerRoutes from "./modules/provider/providerRoutes";
import adminRoutes from "./modules/admin/adminRoutes";
import meRoutes from "./modules/me/meRoutes";


const app: Application = express();

// Global Middlewares
app.use(cors());
// Raw body needed for webhook signature verification
app.use("/api/bookings/webhook/razorpay", express.raw({ type: "application/json" }));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health Check
app.get("/health", (req: Request, res: Response) => {
  res.status(200).json({ status: "OK", message: "Marketplace Server is running" });
});

// Request Logger (Debug)
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
  next();
});

// API Routes
const API_PREFIX = "/api";
app.use(`${API_PREFIX}/auth`, authRoutes);
app.use(`${API_PREFIX}/services`, serviceRoutes);
app.use(`${API_PREFIX}/bookings`, bookingRoutes);
app.use(`${API_PREFIX}/payments`, paymentRoutes);
app.use(`${API_PREFIX}/reviews`, reviewRoutes);
app.use(`${API_PREFIX}/provider`, providerRoutes);
app.use(`${API_PREFIX}/admin`, adminRoutes);
app.use(`${API_PREFIX}/me`, meRoutes);


// Fallback Middlewares
app.use(notFound);
app.use(errorHandler);

export default app;
