"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { cn } from "@/lib/utils";
import {
  LayoutDashboard,
  Users,
  Briefcase,
  CalendarDays,
  ShieldCheck,
  Settings,
  CreditCard,
  LogOut,
} from "lucide-react";
import { useAuthStore } from "@/store/authStore";

const adminNavItems = [
  { name: "Dashboard", href: "/admin", icon: LayoutDashboard },
  { name: "Users", href: "/admin/users", icon: Users },
  { name: "Providers", href: "/admin/providers", icon: Briefcase },
  { name: "Bookings", href: "/admin/bookings", icon: CalendarDays },
  { name: "Finance", href: "/admin/finance", icon: CreditCard },
  { name: "Audit Logs", href: "/admin/logs", icon: ShieldCheck },
  { name: "Settings", href: "/admin/settings", icon: Settings },
];

export function Sidebar() {
  const pathname = usePathname();
  const logout = useAuthStore((state) => state.logout);

  return (
    <div className="flex h-full w-64 flex-col border-r bg-white">
      <div className="flex h-16 items-center px-6">
        <Link href="/admin" className="flex items-center gap-2 font-bold text-xl">
          <div className="bg-zinc-900 text-white p-1.5 rounded-lg">
            <ShieldCheck className="h-5 w-5" />
          </div>
          <span>EndlessPath</span>
        </Link>
      </div>

      <div className="flex-1 overflow-y-auto px-4 py-4">
        <nav className="space-y-1">
          {adminNavItems.map((item) => {
            const isActive = pathname === item.href;
            return (
              <Link
                key={item.name}
                href={item.href}
                className={cn(
                  "flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium transition-colors",
                  isActive
                    ? "bg-zinc-100 text-zinc-900"
                    : "text-zinc-500 hover:bg-zinc-50 hover:text-zinc-900"
                )}
              >
                <item.icon className={cn("h-4 w-4", isActive ? "text-zinc-900" : "text-zinc-400")} />
                {item.name}
              </Link>
            );
          })}
        </nav>
      </div>

      <div className="border-t p-4">
        <button
          onClick={logout}
          className="flex w-full items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium text-red-600 hover:bg-red-50 transition-colors"
        >
          <LogOut className="h-4 w-4" />
          Logout
        </button>
      </div>
    </div>
  );
}
