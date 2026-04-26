import { prisma } from "../config/db";

/**
 * Automatically expires bookings that have exceeded their slot-hold duration.
 * This frees up the provider's calendar if a user abandons a payment or 
 * if a provider fails to respond to a request in time.
 */
export const startExpiryCron = () => {
  console.log("[CronService] Starting Auto-Expiry Job (Every 2 mins)...");
  
  setInterval(async () => {
    try {
      const now = new Date();
      
      // Find all bookings where hold has expired and status is not yet final
      const staleBookings = await prisma.booking.findMany({
        where: {
          status: { in: ["REQUESTED", "PROVIDER_ACCEPTED", "PAYMENT_PENDING", "PAYMENT_FAILED"] },
          holdExpiresAt: { lt: now }
        }
      });

      if (staleBookings.length > 0) {
        await prisma.$transaction(async (tx) => {
          for (const booking of staleBookings) {
            await tx.booking.update({
              where: { id: booking.id },
              data: { status: "EXPIRED" }
            });

            await tx.bookingEvent.create({
              data: {
                bookingId: booking.id,
                fromStatus: booking.status,
                toStatus: "EXPIRED",
                actorId: "SYSTEM_CRON",
                meta: { reason: "HOLD_TIMEOUT" }
              }
            });
          }
        });
        console.log(`[CronService] Expired ${staleBookings.length} stale bookings.`);
      }
    } catch (error) {
      console.error("[CronService] Expiry Job Error:", error);
    }
  }, 2 * 60 * 1000); // Check every 2 minutes
};
