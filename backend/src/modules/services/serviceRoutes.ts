import { Router } from "express";
import {
  getServices,
  getServiceById,
  createService,
  updateService,
  deleteService,
  getMyServices
} from "./serviceController";
import { protect } from "../../middleware/authMiddleware";
import { requireRole } from "../../middleware/roleMiddleware";
import { validate } from "../../middleware/validate";
import { createServiceSchema, updateServiceSchema } from "./serviceSchema";
import "express-async-errors";

const router = Router();

// Public routes
router.get("/", getServices);
router.get("/:id", getServiceById);

// Provider only routes
router.use(protect);
router.use(requireRole("PROVIDER"));

router.post("/", validate(createServiceSchema), createService);
router.get("/my-services", getMyServices);
router.put("/:id", validate(updateServiceSchema), updateService);
router.delete("/:id", deleteService);

export default router;
