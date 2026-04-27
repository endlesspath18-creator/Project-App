"use client";

import { useEffect, useState } from "react";
import { api } from "@/lib/api";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { 
  Users, 
  Briefcase, 
  CalendarDays, 
  IndianRupee, 
  TrendingUp,
  Loader2
} from "lucide-react";
import { motion } from "framer-motion";

interface Stats {
  totalUsers: number;
  totalProviders: number;
  totalBookings: number;
  totalServices: number;
  bookingRevenue: number;
  bookingCommission: number;
  activationRevenue: number;
  totalPlatformEarnings: number;
}

export default function AdminDashboardPage() {
  const [stats, setStats] = useState<Stats | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    async function fetchStats() {
      try {
        const response = await api.get("/admin/stats");
        setStats(response.data.data);
      } catch (error) {
        console.error("Failed to fetch stats", error);
      } finally {
        setIsLoading(false);
      }
    }
    fetchStats();
  }, []);

  if (isLoading) {
    return (
      <div className="flex h-96 items-center justify-center">
        <Loader2 className="h-8 w-8 animate-spin text-zinc-300" />
      </div>
    );
  }

  const cards = [
    { title: "Total Users", value: stats?.totalUsers, icon: Users, color: "text-blue-600" },
    { title: "Total Providers", value: stats?.totalProviders, icon: Briefcase, color: "text-purple-600" },
    { title: "Total Bookings", value: stats?.totalBookings, icon: CalendarDays, color: "text-orange-600" },
    { title: "Platform Earnings", value: `₹${stats?.totalPlatformEarnings}`, icon: IndianRupee, color: "text-emerald-600" },
  ];

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-3xl font-bold tracking-tight">Dashboard Overview</h1>
        <p className="text-zinc-500">Real-time metrics and platform health.</p>
      </div>

      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        {cards.map((card, i) => (
          <motion.div
            key={card.title}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: i * 0.1 }}
          >
            <Card className="border-zinc-200">
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">{card.title}</CardTitle>
                <card.icon className={`h-4 w-4 ${card.color}`} />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">{card.value}</div>
                <p className="text-xs text-zinc-400 mt-1">
                  <span className="text-emerald-500 inline-flex items-center">
                    <TrendingUp className="h-3 w-3 mr-1" /> +4.5%
                  </span>{" "}
                  from last month
                </p>
              </CardContent>
            </Card>
          </motion.div>
        ))}
      </div>

      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-7">
        <Card className="lg:col-span-4 border-zinc-200">
          <CardHeader>
            <CardTitle>Revenue Analytics</CardTitle>
          </CardHeader>
          <CardContent className="h-80 flex items-center justify-center bg-zinc-50 rounded-md border border-dashed border-zinc-200 m-4">
            <p className="text-zinc-400 text-sm">Revenue chart implementation pending integration with Recharts.</p>
          </CardContent>
        </Card>
        
        <Card className="lg:col-span-3 border-zinc-200">
          <CardHeader>
            <CardTitle>Financial Breakdown</CardTitle>
          </CardHeader>
          <CardContent className="space-y-6">
             <div className="flex items-center justify-between">
                <span className="text-sm text-zinc-500">Booking Commission</span>
                <span className="font-semibold text-zinc-900">₹{stats?.bookingCommission}</span>
             </div>
             <div className="flex items-center justify-between">
                <span className="text-sm text-zinc-500">Provider Activations</span>
                <span className="font-semibold text-zinc-900">₹{stats?.activationRevenue}</span>
             </div>
             <div className="pt-4 border-t flex items-center justify-between font-bold">
                <span>Total Net Profit</span>
                <span className="text-emerald-600">₹{stats?.totalPlatformEarnings}</span>
             </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
