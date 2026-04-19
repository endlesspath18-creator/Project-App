"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const serviceController_1 = require("./serviceController");
const authMiddleware_1 = require("../../middleware/authMiddleware");
const roleMiddleware_1 = require("../../middleware/roleMiddleware");
const validate_1 = require("../../middleware/validate");
const serviceSchema_1 = require("./serviceSchema");
require("express-async-errors");
const router = (0, express_1.Router)();
// Public routes
router.get("/", serviceController_1.getServices);
router.get("/:id", serviceController_1.getServiceById);
// Provider only routes
router.use(authMiddleware_1.protect);
router.use((0, roleMiddleware_1.requireRole)("PROVIDER"));
router.post("/", (0, validate_1.validate)(serviceSchema_1.createServiceSchema), serviceController_1.createService);
router.get("/my-services", serviceController_1.getMyServices);
router.put("/:id", (0, validate_1.validate)(serviceSchema_1.updateServiceSchema), serviceController_1.updateService);
router.delete("/:id", serviceController_1.deleteService);
exports.default = router;
