import { Request, Response } from "express";
import { prisma } from "../../config/db";
import { sendResponse, sendError } from "../../utils/response";

export const getServices = async (req: Request, res: Response) => {
  const { category, providerId, searchQuery } = req.query;

  const whereClause: any = { 
    isActive: true,
  };

  // If fetching for the general marketplace (no providerId), only show AVAILABLE services
  if (!providerId) {
    whereClause.status = "AVAILABLE";
  } else {
    whereClause.providerId = String(providerId);
  }

  if (category) whereClause.category = String(category);
  
  if (searchQuery) {
    whereClause.OR = [
      { title: { contains: String(searchQuery), mode: "insensitive" } },
      { description: { contains: String(searchQuery), mode: "insensitive" } },
    ];
  }

  const services = await prisma.service.findMany({
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

  sendResponse(res, 200, "Services fetched successfully", services);
};

export const getServiceById = async (req: Request, res: Response) => {
  const { id } = req.params;

  const service = await prisma.service.findUnique({
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

  if (!service) return sendError(res, 404, "Service not found");

  sendResponse(res, 200, "Service fetched successfully", service);
};

export const createService = async (req: Request, res: Response) => {
  const providerId = req.user!.id;
  const { title, category, description, price, durationMinutes, images } = req.body;

  const newService = await prisma.service.create({
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

  sendResponse(res, 201, "Service created successfully", newService);
};

export const updateService = async (req: Request, res: Response) => {
  const providerId = req.user!.id;
  const { id } = req.params;
  const updateData = req.body;

  const service = await prisma.service.findUnique({ where: { id } });

  if (!service) return sendError(res, 404, "Service not found");
  if (service.providerId !== providerId) return sendError(res, 403, "Not authorized to update this service");

  const updatedService = await prisma.service.update({
    where: { id },
    data: updateData,
  });

  sendResponse(res, 200, "Service updated successfully", updatedService);
};

export const getMyServices = async (req: Request, res: Response) => {
  const providerId = req.user!.id;

  const services = await prisma.service.findMany({
    where: { providerId },
    orderBy: { createdAt: "desc" },
  });

  sendResponse(res, 200, "Provider services fetched", services);
};

export const deleteService = async (req: Request, res: Response) => {
  const providerId = req.user!.id;
  const { id } = req.params;

  const service = await prisma.service.findUnique({ where: { id } });

  if (!service) return sendError(res, 404, "Service not found");
  if (service.providerId !== providerId) return sendError(res, 403, "Not authorized to delete this service");

  await prisma.service.delete({ where: { id } });

  sendResponse(res, 200, "Service deleted successfully");
};
