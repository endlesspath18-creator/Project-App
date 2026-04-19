"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const errorMiddleware_1 = require("./middleware/errorMiddleware");
const notFound_1 = require("./middleware/notFound");
// Route imports
const authRoutes_1 = __importDefault(require("./modules/auth/authRoutes"));
const serviceRoutes_1 = __importDefault(require("./modules/services/serviceRoutes"));
const bookingRoutes_1 = __importDefault(require("./modules/bookings/bookingRoutes"));
const paymentRoutes_1 = __importDefault(require("./modules/payments/paymentRoutes"));
const reviewRoutes_1 = __importDefault(require("./modules/reviews/reviewRoutes"));
const providerRoutes_1 = __importDefault(require("./modules/provider/providerRoutes"));
const app = (0, express_1.default)();
// Global Middlewares
app.use((0, cors_1.default)());
app.use(express_1.default.json());
app.use(express_1.default.urlencoded({ extended: true }));
// Health Check
app.get("/health", (req, res) => {
    res.status(200).json({ status: "OK", message: "Marketplace Server is running" });
});
// API Routes
const API_PREFIX = "/api";
app.use(`${API_PREFIX}/auth`, authRoutes_1.default);
app.use(`${API_PREFIX}/services`, serviceRoutes_1.default);
app.use(`${API_PREFIX}/bookings`, bookingRoutes_1.default);
app.use(`${API_PREFIX}/payments`, paymentRoutes_1.default);
app.use(`${API_PREFIX}/reviews`, reviewRoutes_1.default);
app.use(`${API_PREFIX}/provider`, providerRoutes_1.default);
// Fallback Middlewares
app.use(notFound_1.notFound);
app.use(errorMiddleware_1.errorHandler);
exports.default = app;
