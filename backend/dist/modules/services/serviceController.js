"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.deleteService = exports.getMyServices = exports.updateService = exports.createService = exports.getServiceById = exports.getServices = void 0;
const db_1 = require("../../config/db");
const response_1 = require("../../utils/response");
const getServices = async (req, res) => {
    const { category, providerId, searchQuery } = req.query;
    const whereClause = {
        isActive: true,
    };
    // If fetching for the general marketplace (no providerId), only show AVAILABLE services
    if (!providerId) {
        whereClause.status = "AVAILABLE";
    }
    else {
        whereClause.providerId = String(providerId);
    }
    if (category)
        whereClause.category = String(category);
    if (searchQuery) {
        whereClause.OR = [
            { title: { contains: String(searchQuery), mode: "insensitive" } },
            { description: { contains: String(searchQuery), mode: "insensitive" } },
        ];
    }
    const services = await db_1.prisma.service.findMany({
        where: whereClause,
        include: {
            provider: {
                select: {
                    id: true,
                    fullName: true,
                    providerProfile: {
                        select: {
                            businessName: true,
                            rating: true,
                            isOnline: true,
                        }
                    }
                }
            }
        },
        orderBy: { createdAt: "desc" },
    });
    (0, response_1.sendResponse)(res, 200, "Services fetched successfully", services);
};
exports.getServices = getServices;
const getServiceById = async (req, res) => {
    const { id } = req.params;
    const service = await db_1.prisma.service.findUnique({
        where: { id },
        include: {
            provider: {
                select: {
                    id: true,
                    fullName: true,
                    providerProfile: true,
                }
            }
        }
    });
    if (!service)
        return (0, response_1.sendError)(res, 404, "Service not found");
    (0, response_1.sendResponse)(res, 200, "Service fetched successfully", service);
};
exports.getServiceById = getServiceById;
const createService = async (req, res) => {
    const providerId = req.user.id;
    const { title, category, description, price, durationMinutes, images } = req.body;
    const newService = await db_1.prisma.service.create({
        data: {
            providerId,
            title,
            category,
            description,
            price,
            durationMinutes,
            images: images || [],
            status: "AVAILABLE"
        }
    });
    (0, response_1.sendResponse)(res, 201, "Service created successfully", newService);
};
exports.createService = createService;
const updateService = async (req, res) => {
    const providerId = req.user.id;
    const { id } = req.params;
    const updateData = req.body;
    const service = await db_1.prisma.service.findUnique({ where: { id } });
    if (!service)
        return (0, response_1.sendError)(res, 404, "Service not found");
    if (service.providerId !== providerId)
        return (0, response_1.sendError)(res, 403, "Not authorized to update this service");
    const updatedService = await db_1.prisma.service.update({
        where: { id },
        data: updateData,
    });
    (0, response_1.sendResponse)(res, 200, "Service updated successfully", updatedService);
};
exports.updateService = updateService;
const getMyServices = async (req, res) => {
    const providerId = req.user.id;
    const services = await db_1.prisma.service.findMany({
        where: { providerId },
        orderBy: { createdAt: "desc" },
    });
    (0, response_1.sendResponse)(res, 200, "Provider services fetched", services);
};
exports.getMyServices = getMyServices;
const deleteService = async (req, res) => {
    const providerId = req.user.id;
    const { id } = req.params;
    const service = await db_1.prisma.service.findUnique({ where: { id } });
    if (!service)
        return (0, response_1.sendError)(res, 404, "Service not found");
    if (service.providerId !== providerId)
        return (0, response_1.sendError)(res, 403, "Not authorized to delete this service");
    await db_1.prisma.service.delete({ where: { id } });
    (0, response_1.sendResponse)(res, 200, "Service deleted successfully");
};
exports.deleteService = deleteService;
