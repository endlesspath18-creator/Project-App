import app from "./app";
import { env } from "./config/env";
import { prisma } from "./config/db";

const startServer = async () => {
  try {
    // Attempt database connection
    await prisma.$connect();
    console.log("✅ Database connection established.");

    const PORT = env.PORT || 5000;
    app.listen(PORT, () => {
      console.log(`🚀 Server is running on port ${PORT}`);
    });
  } catch (error) {
    console.error("❌ Failed to start the server due to database connection error:");
    console.error(error);
    process.exit(1);
  }
};

// Handle unhandled rejections
process.on("unhandledRejection", (err: Error) => {
  console.log("UNHANDLED REJECTION! 💥 Shutting down...");
  console.log(err.name, err.message);
  process.exit(1);
});

startServer();
