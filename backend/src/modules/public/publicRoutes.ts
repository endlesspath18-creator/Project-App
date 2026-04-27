import { Router } from "express";
import { getBanners } from "../admin/bannerController";
import { prisma } from "../../config/db";
import { sendResponse, sendError } from "../../utils/response";

const router = Router();

router.get("/banners", getBanners);

// Fetch Real Top Rated Providers
router.get("/top-providers", async (req, res) => {
  try {
    const providers = await prisma.user.findMany({
      where: { 
        role: "PROVIDER",
        providerProfile: { isNot: null }
      },
      include: { 
        providerProfile: true 
      },
      orderBy: {
        providerProfile: {
          rating: "desc"
        }
      },
      take: 10
    });
    sendResponse(res, 200, "Top providers fetched", providers);
  } catch (error: any) {
    sendError(res, 500, error.message);
  }
});

export default router;
