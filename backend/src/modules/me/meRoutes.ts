import { Router } from "express";
import * as meController from "./meController";
import { protect } from "../../middleware/authMiddleware";
import { validate } from "../../middleware/validate";
import * as meSchema from "./meSchema";

const router = Router();

router.use(protect);

// Dashboard
router.get("/dashboard", meController.getDashboard);

// Bookings
router.get("/bookings", meController.getMyBookings);

// Favorites
router.get("/favorites", meController.getFavorites);
router.post("/favorites", validate(meSchema.addFavoriteSchema), meController.addFavorite);
router.delete("/favorites/:id", meController.removeFavorite);

// Payments
router.get("/payments", meController.getPayments);

// Notifications
router.get("/notifications", meController.getNotifications);
router.patch("/notifications/:id/read", meController.markNotificationRead);

// Profile
router.get("/profile", meController.getProfile);
router.patch("/profile", validate(meSchema.updateProfileSchema), meController.updateProfile);
router.post("/change-password", validate(meSchema.changePasswordSchema), meController.changePassword);
router.post("/logout-all", meController.logoutAllDevices);

// Support
router.post("/support/tickets", validate(meSchema.createSupportTicketSchema), meController.createSupportTicket);
router.get("/support/tickets", meController.getSupportTickets);

export default router;
