"use client";

import { useEffect, useState } from "react";
import { api } from "@/lib/api";
import { 
  Table, 
  TableBody, 
  TableCell, 
  TableHead, 
  TableHeader, 
  TableRow 
} from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { 
  DropdownMenu, 
  DropdownMenuContent, 
  DropdownMenuItem, 
  DropdownMenuLabel, 
  DropdownMenuSeparator, 
  DropdownMenuTrigger 
} from "@/components/ui/dropdown-menu";
import { Switch } from "@/components/ui/switch";
import { 
  MoreHorizontal, 
  CheckCircle2, 
  XCircle, 
  ShieldAlert, 
  Key,
  Search,
  Loader2
} from "lucide-react";
import { toast } from "sonner";
import { Input } from "@/components/ui/input";

interface Provider {
  id: string;
  fullName: string;
  email: string;
  phone: string | null;
  isVerified: boolean;
  hasPaidPublishingFee: boolean;
  canPublishService: boolean;
  isActive: boolean;
  providerProfile: {
    businessName: string;
    rating: number;
  } | null;
}

export default function ProvidersPage() {
  const [providers, setProviders] = useState<Provider[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState("");

  const fetchProviders = async () => {
    try {
      const response = await api.get("/admin/providers");
      setProviders(response.data.data);
    } catch (error) {
      toast.error("Failed to fetch providers");
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchProviders();
  }, []);

  const handleVerify = async (id: string, currentStatus: boolean) => {
    try {
      await api.patch(`/admin/providers/${id}/verify`, { isVerified: !currentStatus });
      toast.success(`Provider ${!currentStatus ? "verified" : "unverified"} successfully`);
      fetchProviders();
    } catch (error) {
      toast.error("Failed to update verification status");
    }
  };

  const handleManualUnlock = async (id: string) => {
    try {
      await api.post(`/admin/providers/${id}/manual-unlock`);
      toast.success("Provider manually unlocked for publishing");
      fetchProviders();
    } catch (error) {
      toast.error("Failed to unlock provider");
    }
  };

  const filteredProviders = providers.filter(p => 
    p.fullName.toLowerCase().includes(searchQuery.toLowerCase()) ||
    p.providerProfile?.businessName.toLowerCase().includes(searchQuery.toLowerCase()) ||
    p.email.toLowerCase().includes(searchQuery.toLowerCase())
  );

  if (isLoading) {
    return (
      <div className="flex h-96 items-center justify-center">
        <Loader2 className="h-8 w-8 animate-spin text-zinc-300" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Providers Management</h1>
          <p className="text-zinc-500">Verify partners and manage publishing permissions.</p>
        </div>
      </div>

      <div className="flex items-center gap-4 bg-white p-4 rounded-xl border border-zinc-200">
        <Search className="h-4 w-4 text-zinc-400" />
        <Input 
          placeholder="Search by name, business or email..." 
          className="border-none shadow-none focus-visible:ring-0 px-0"
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
        />
      </div>

      <div className="bg-white rounded-xl border border-zinc-200 overflow-hidden">
        <Table>
          <TableHeader className="bg-zinc-50">
            <TableRow>
              <TableHead>Provider</TableHead>
              <TableHead>Business Name</TableHead>
              <TableHead>Verification</TableHead>
              <TableHead>Premium Status</TableHead>
              <TableHead>Permissions</TableHead>
              <TableHead className="text-right">Actions</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {filteredProviders.map((provider) => (
              <TableRow key={provider.id}>
                <TableCell>
                  <div className="flex flex-col">
                    <span className="font-medium text-zinc-900">{provider.fullName}</span>
                    <span className="text-xs text-zinc-500">{provider.email}</span>
                  </div>
                </TableCell>
                <TableCell className="text-zinc-600">
                  {provider.providerProfile?.businessName || "Not set"}
                </TableCell>
                <TableCell>
                  <div className="flex items-center gap-2">
                    <Switch 
                      checked={provider.isVerified}
                      onCheckedChange={() => handleVerify(provider.id, provider.isVerified)}
                    />
                    <Badge variant={provider.isVerified ? "default" : "secondary"} className="h-5">
                      {provider.isVerified ? "Verified" : "Pending"}
                    </Badge>
                  </div>
                </TableCell>
                <TableCell>
                  <Badge variant={provider.hasPaidPublishingFee ? "outline" : "secondary"} className={provider.hasPaidPublishingFee ? "border-emerald-200 text-emerald-700 bg-emerald-50" : ""}>
                    {provider.hasPaidPublishingFee ? "Paid" : "Unpaid"}
                  </Badge>
                </TableCell>
                <TableCell>
                   {provider.canPublishService ? (
                     <div className="flex items-center text-emerald-600 text-xs font-medium">
                       <CheckCircle2 className="h-3 w-3 mr-1" /> Active
                     </div>
                   ) : (
                     <div className="flex items-center text-zinc-400 text-xs font-medium">
                       <XCircle className="h-3 w-3 mr-1" /> Locked
                     </div>
                   )}
                </TableCell>
                <TableCell className="text-right">
                  <DropdownMenu>
                    <DropdownMenuTrigger asChild>
                      <Button variant="ghost" className="h-8 w-8 p-0">
                        <MoreHorizontal className="h-4 w-4" />
                      </Button>
                    </DropdownMenuTrigger>
                    <DropdownMenuContent align="end" className="w-48">
                      <DropdownMenuLabel>Actions</DropdownMenuLabel>
                      <DropdownMenuItem onClick={() => handleVerify(provider.id, provider.isVerified)}>
                        {provider.isVerified ? "Unverify Partner" : "Mark as Verified"}
                      </DropdownMenuItem>
                      <DropdownMenuSeparator />
                      <DropdownMenuItem 
                        className="text-emerald-600"
                        onClick={() => handleManualUnlock(provider.id)}
                        disabled={provider.canPublishService}
                      >
                        <Key className="h-4 w-4 mr-2" />
                        Manual Unlock
                      </DropdownMenuItem>
                      <DropdownMenuItem className="text-red-600">
                        <ShieldAlert className="h-4 w-4 mr-2" />
                        Suspend Account
                      </DropdownMenuItem>
                    </DropdownMenuContent>
                  </DropdownMenu>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
    </div>
  );
}
