import { Router } from "express";
import * as adminController from "./adminController";
import { protect, adminOnly } from "../../middleware/authMiddleware";

const router = Router();

// Apply auth and admin protection to all routes in this module
router.use(protect);
router.use(adminOnly);

router.get("/stats", adminController.getDashboardStats);
router.get("/users", adminController.getAllUsers);
router.get("/providers", adminController.getAllProviders);
router.patch("/users/:id/toggle-status", adminController.toggleUserStatus);
router.get("/bookings", adminController.getAllBookings);

export default router;
