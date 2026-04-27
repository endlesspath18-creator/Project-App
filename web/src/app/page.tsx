"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";
import { useAuthStore } from "@/store/authStore";
import { Loader2 } from "lucide-react";

export default function RootPage() {
  const router = useRouter();
  const { user } = useAuthStore();

  useEffect(() => {
    if (!user) {
      router.push("/login");
    } else {
      if (user.role === "ADMIN") {
        router.push("/admin");
      } else if (user.role === "PROVIDER") {
        router.push("/provider");
      } else {
        router.push("/dashboard");
      }
    }
  }, [user, router]);

  return (
    <div className="h-screen flex items-center justify-center bg-zinc-950">
      <div className="flex flex-col items-center gap-4">
        <Loader2 className="h-10 w-10 animate-spin text-zinc-600" />
        <p className="text-zinc-500 font-medium animate-pulse">Initializing Dashboard...</p>
      </div>
    </div>
  );
}
