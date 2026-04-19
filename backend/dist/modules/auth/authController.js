"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.completeSocialSignup = exports.googleLogin = exports.logout = exports.getMe = exports.login = exports.register = void 0;
const db_1 = require("../../config/db");
const hash_1 = require("../../utils/hash");
const jwt_1 = require("../../utils/jwt");
const response_1 = require("../../utils/response");
const google_auth_library_1 = require("google-auth-library");
const googleClientId = process.env.GOOGLE_CLIENT_ID || "";
const client = new google_auth_library_1.OAuth2Client(googleClientId);
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
    if (!user.passwordHash) {
        return (0, response_1.sendError)(res, 401, "This account is linked with Google. Please login using Google.");
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
            isRoleSet: true,
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
const googleLogin = async (req, res) => {
    const { idToken } = req.body;
    try {
        const ticket = await client.verifyIdToken({
            idToken,
            audience: googleClientId,
        });
        const payload = ticket.getPayload();
        if (!payload || !payload.email) {
            return (0, response_1.sendError)(res, 400, "Invalid ID Token");
        }
        const { email, name, sub: googleId } = payload;
        // Find or create user
        let user = await db_1.prisma.user.findUnique({
            where: { email },
            include: { providerProfile: true }
        });
        if (!user) {
            // Create new user (role selection mandatory next)
            user = await db_1.prisma.user.create({
                data: {
                    email,
                    fullName: name || "Google User",
                    googleId,
                    isRoleSet: false,
                    // role defaults to USER, but isRoleSet = false triggers onboarding
                },
                include: { providerProfile: true }
            });
        }
        else if (!user.googleId) {
            // Link Google ID if it's an existing email user
            user = await db_1.prisma.user.update({
                where: { id: user.id },
                data: { googleId },
                include: { providerProfile: true }
            });
        }
        const token = (0, jwt_1.generateToken)({ id: user.id, role: user.role });
        (0, response_1.sendResponse)(res, 200, "Google login successful", {
            token,
            user: {
                id: user.id,
                fullName: user.fullName,
                email: user.email,
                role: user.role,
                isRoleSet: user.isRoleSet,
                providerProfile: user.providerProfile,
            },
        });
    }
    catch (error) {
        console.error("Google login verification failed:", error);
        return res.status(401).json({ message: "Google authentication failed" });
    }
};
exports.googleLogin = googleLogin;
const completeSocialSignup = async (req, res) => {
    const userId = req.user?.id;
    const { role, businessName } = req.body;
    if (!userId) {
        return (0, response_1.sendError)(res, 401, "Not authenticated");
    }
    const user = await db_1.prisma.user.findUnique({ where: { id: userId } });
    if (!user) {
        return (0, response_1.sendError)(res, 404, "User not found");
    }
    if (user.isRoleSet) {
        return (0, response_1.sendError)(res, 400, "Role is already set and cannot be changed");
    }
    const result = await db_1.prisma.$transaction(async (tx) => {
        const updatedUser = await tx.user.update({
            where: { id: userId },
            data: {
                role,
                isRoleSet: true,
            },
        });
        if (role === "PROVIDER" && businessName) {
            await tx.providerProfile.create({
                data: {
                    userId,
                    businessName,
                },
            });
        }
        return updatedUser;
    });
    const token = (0, jwt_1.generateToken)({ id: result.id, role: result.role });
    (0, response_1.sendResponse)(res, 200, "Profile completed successfully", {
        token,
        user: {
            id: result.id,
            fullName: result.fullName,
            email: result.email,
            role: result.role,
            isRoleSet: true,
        },
    });
};
exports.completeSocialSignup = completeSocialSignup;
