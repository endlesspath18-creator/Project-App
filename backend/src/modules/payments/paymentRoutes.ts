import { Router } from "express";
import { createOrder, verifyPayment, getPaymentHistory } from "./paymentController";
import { protect } from "../../middleware/authMiddleware";
import { requireRole } from "../../middleware/roleMiddleware";
import { validate } from "../../middleware/validate";
import { createOrderSchema, verifyPaymentSchema } from "./paymentSchema";
import "express-async-errors";

const router = Router();

router.use(protect);
router.use(requireRole("USER"));

router.post("/create-order", validate(createOrderSchema), createOrder);
router.post("/verify", validate(verifyPaymentSchema), verifyPayment);
router.get("/history", getPaymentHistory);

export default router;
