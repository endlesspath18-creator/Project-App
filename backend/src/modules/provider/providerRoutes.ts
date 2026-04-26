import { Router } from "express";
import { 
  getDashboardStats, 
  getIncomingRequests, 
  getActiveJobs,
  updateProviderProfile,
  toggleAvailability
} from "./providerController";
import { protect } from "../../middleware/authMiddleware";
import { requireRole } from "../../middleware/roleMiddleware";
import "express-async-errors";

const router = Router();

// All provider routes are protected and require the PROVIDER role
router.use(protect);
router.use(requireRole("PROVIDER"));

router.get("/dashboard", getDashboardStats);
router.get("/requests", getIncomingRequests);
router.get("/active-jobs", getActiveJobs);
router.patch("/profile", updateProviderProfile);
router.patch("/availability", toggleAvailability);

export default router;
