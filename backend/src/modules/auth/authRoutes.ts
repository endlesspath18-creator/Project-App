import { Router } from "express";
import { register, login, getMe, logout } from "./authController";
import { protect } from "../../middleware/authMiddleware";
import { validate } from "../../middleware/validate";
import { registerSchema, loginSchema } from "./authSchema";
import "express-async-errors";

const router = Router();

router.post("/register", validate(registerSchema), register);
router.post("/login", validate(loginSchema), login);
router.post("/logout", protect, logout);
router.get("/me", protect, getMe);

export default router;
