import { Router } from "express";
import * as paymentController from "./paymentController";
import { protect } from "../../middleware/authMiddleware";
import { requireRole } from "../../middleware/roleMiddleware";
import { validate } from "../../middleware/validate";
import { createOrderSchema, verifyPaymentSchema } from "./paymentSchema";
import "express-async-errors";

const router = Router();

router.use(protect);

// Booking Payments (For Users)
router.post("/create-order", requireRole("USER"), paymentController.createOrder);
router.post("/verify", requireRole("USER"), paymentController.verifyPayment);

// Provider Activation (For Providers)
router.post("/activation/create-order", requireRole("PROVIDER"), paymentController.createActivationOrder);
router.post("/activation/verify", requireRole("PROVIDER"), paymentController.verifyActivationPayment);

// Payment History (Both)
router.get("/history", paymentController.getPaymentHistory);

export default router;
