"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const providerController_1 = require("./providerController");
const authMiddleware_1 = require("../../middleware/authMiddleware");
const roleMiddleware_1 = require("../../middleware/roleMiddleware");
require("express-async-errors");
const router = (0, express_1.Router)();
// All provider routes are protected and require the PROVIDER role
router.use(authMiddleware_1.protect);
router.use((0, roleMiddleware_1.requireRole)("PROVIDER"));
router.get("/dashboard", providerController_1.getDashboardStats);
router.get("/requests", providerController_1.getIncomingRequests);
router.get("/active-jobs", providerController_1.getActiveJobs);
exports.default = router;
