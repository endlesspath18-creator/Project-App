import { Request, Response } from "express";
import { prisma } from "../../config/db";
import { sendResponse, sendError } from "../../utils/response";

export const getBanners = async (req: Request, res: Response) => {
  try {
    const banners = await prisma.banner.findMany({
      where: { isActive: true },
      orderBy: { createdAt: "desc" }
    });
    sendResponse(res, 200, "Banners fetched", banners);
  } catch (error: any) {
    sendError(res, 500, error.message);
  }
};

export const createBanner = async (req: Request, res: Response) => {
  try {
    const { imageUrl, link } = req.body;
    if (!imageUrl) return sendError(res, 400, "Image URL is required");

    const banner = await prisma.banner.create({
      data: { imageUrl, link }
    });
    sendResponse(res, 201, "Banner created", banner);
  } catch (error: any) {
    sendError(res, 500, error.message);
  }
};

export const deleteBanner = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    await prisma.banner.delete({ where: { id } });
    sendResponse(res, 200, "Banner deleted");
  } catch (error: any) {
    sendError(res, 500, error.message);
  }
};
