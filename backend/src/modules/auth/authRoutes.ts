import { Router } from "express";
import { register, verifyOtp, login, getMe, logout, refresh, updateProfile, updatePassword } from "./authController";
import { protect } from "../../middleware/authMiddleware";
import { validate } from "../../middleware/validate";
import { registerSchema, loginSchema } from "./authSchema";
import "express-async-errors";

const router = Router();

router.post("/register", validate(registerSchema), register);
router.post("/verify-otp", verifyOtp);
router.post("/login", validate(loginSchema), login);
router.post("/logout", protect, logout);
router.get("/me", protect, getMe);
router.post("/refresh", refresh);
router.patch("/profile", protect, updateProfile);
router.patch("/password", protect, updatePassword);

export default router;
