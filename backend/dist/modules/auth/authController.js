"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.logout = exports.getMe = exports.login = exports.register = void 0;
const db_1 = require("../../config/db");
const hash_1 = require("../../utils/hash");
const jwt_1 = require("../../utils/jwt");
const response_1 = require("../../utils/response");
const register = async (req, res) => {
    const { fullName, email, phone, password, role, businessName } = req.body;
    // Check if user already exists
    const userExists = await db_1.prisma.user.findUnique({
        where: { email },
    });
    if (userExists) {
        return (0, response_1.sendError)(res, 400, "User already exists with this email");
    }
    // Hash password
    const passwordHash = await (0, hash_1.hashPassword)(password);
    // Use transaction to ensure both user and profile are created together if provider
    const result = await db_1.prisma.$transaction(async (tx) => {
        const user = await tx.user.create({
            data: {
                fullName,
                email,
                phone,
                passwordHash,
                role,
            },
        });
        if (role === "PROVIDER" && businessName) {
            await tx.providerProfile.create({
                data: {
                    userId: user.id,
                    businessName,
                },
            });
        }
        return user;
    });
    const token = (0, jwt_1.generateToken)({ id: result.id, role: result.role });
    (0, response_1.sendResponse)(res, 201, "User registered successfully", {
        token,
        user: {
            id: result.id,
            fullName: result.fullName,
            email: result.email,
            role: result.role,
        },
    });
};
exports.register = register;
const login = async (req, res) => {
    const { email, password } = req.body;
    const user = await db_1.prisma.user.findUnique({
        where: { email },
        include: {
            providerProfile: true,
        },
    });
    if (!user || !user.isActive) {
        return (0, response_1.sendError)(res, 401, "Invalid credentials or inactive account");
    }
    const isMatch = await (0, hash_1.verifyPassword)(password, user.passwordHash);
    if (!isMatch) {
        return (0, response_1.sendError)(res, 401, "Invalid credentials");
    }
    const token = (0, jwt_1.generateToken)({ id: user.id, role: user.role });
    (0, response_1.sendResponse)(res, 200, "Login successful", {
        token,
        user: {
            id: user.id,
            fullName: user.fullName,
            email: user.email,
            role: user.role,
            providerProfile: user.providerProfile,
        },
    });
};
exports.login = login;
const getMe = async (req, res) => {
    const userId = req.user?.id;
    if (!userId) {
        return (0, response_1.sendError)(res, 401, "User not found");
    }
    const user = await db_1.prisma.user.findUnique({
        where: { id: userId },
        select: {
            id: true,
            fullName: true,
            email: true,
            phone: true,
            role: true,
            isActive: true,
            createdAt: true,
            providerProfile: true, // Auto includes if they are provider
        },
    });
    if (!user) {
        return (0, response_1.sendError)(res, 404, "User not found");
    }
    (0, response_1.sendResponse)(res, 200, "User profile retrieved", user);
};
exports.getMe = getMe;
const logout = async (req, res) => {
    // Since we use JWTs, logout is typically handled client-side by dropping the token.
    // Placeholder structure for token blacklisting if needed in future
    (0, response_1.sendResponse)(res, 200, "Logged out successfully (Please clear token on client)");
};
exports.logout = logout;
