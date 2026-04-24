import { PrismaClient } from "@prisma/client";
import bcrypt from "bcrypt";

const prisma = new PrismaClient();

async function main() {
  console.log("🚀 Starting database reset...");

  try {
    // Delete in correct order to avoid foreign key violations
    console.log("⏳ Deleting existing records...");
    await prisma.$transaction([
      prisma.review.deleteMany(),
      prisma.notification.deleteMany(),
      prisma.booking.deleteMany(),
      prisma.service.deleteMany(),
      prisma.providerProfile.deleteMany(),
      prisma.user.deleteMany(),
    ]);

    console.log("✅ All user, provider, and transaction data deleted.");

    // Seed Admin Account
    console.log("⏳ Seeding admin account...");
    const hashedPassword = await bcrypt.hash("Admin@123", 10);

    await prisma.user.create({
      data: {
        fullName: "EndlessPath Admin",
        email: "endlesspath18@gmail.com",
        passwordHash: hashedPassword,
        role: "ADMIN",
        isActive: true,
        isRoleSet: true,
      },
    });

    console.log("--------------------------------------------------");
    console.log("👑 Admin account created successfully!");
    console.log("📧 Email: endlesspath18@gmail.com");
    console.log("🔑 Password: Admin@123");
    console.log("--------------------------------------------------");
    console.log("✨ Database is now clean and ready for fresh registration.");
  } catch (error) {
    console.error("❌ Reset failed:", error);
  } finally {
    await prisma.$disconnect();
  }
}

main();
