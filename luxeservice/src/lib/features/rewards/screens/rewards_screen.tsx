import React, { useEffect, useState } from 'react';
import { motion } from 'motion/react';
import { Gift, TrendingUp, Zap } from 'lucide-react';
import { RewardRepository } from '../../../repositories/repositories';
import { Reward } from '../../../models/models';
import { RewardCard, GlassCard, SectionHeader } from '../../../core/widgets/reusable_widgets';

export const RewardsScreen = () => {
  const [rewards, setRewards] = useState<Reward[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    new RewardRepository().fetchAll().then(data => {
      setRewards(data);
      setLoading(false);
    });
  }, []);

  return (
    <div className="pb-24 pt-12">
      <div className="px-6 mb-8">
        <h2 className="text-3xl font-black text-primary tracking-tight">Rewards</h2>
        <p className="text-slate-500 font-bold text-sm">Exclusive perks for premium members</p>
      </div>

      <div className="px-6 mb-10">
        <div className="bg-primary text-white rounded-[40px] p-8 relative overflow-hidden">
           <div className="relative z-10">
              <div className="flex items-center gap-2 opacity-60 text-[10px] font-black uppercase tracking-widest mb-4">
                 <Zap size={14} className="fill-white" />
                 Points Balance
              </div>
              <h3 className="text-5xl font-black mb-2 tracking-tighter">1,250</h3>
              <p className="text-sm font-bold opacity-60">≈ $12.50 Credit available</p>
              
              <div className="mt-8 pt-8 border-t border-white/10 flex justify-between">
                 <div>
                    <p className="text-[8px] font-black uppercase opacity-40">NEXT TIER</p>
                    <p className="font-black">Gold Member</p>
                 </div>
                 <div className="text-right">
                    <p className="text-[8px] font-black uppercase opacity-40">PROGRESS</p>
                    <p className="font-black">75%</p>
                 </div>
              </div>
           </div>
           <div className="absolute top-0 right-0 w-48 h-48 bg-white/5 rounded-full -mr-20 -mt-20 blur-3xl" />
        </div>
      </div>

      <SectionHeader title="Active Perks" />
      <div className="px-6 space-y-4">
        {loading ? (
          [1,2].map(i => <div key={i} className="h-24 w-full bg-surface rounded-[32px] animate-pulse" />)
        ) : (
          rewards.map(reward => <RewardCard key={reward.id} reward={reward} />)
        )}
      </div>

      <div className="px-6 mt-12 mb-8">
        <GlassCard className="flex items-center gap-6 border-service-tech/20 bg-service-tech/5">
           <Gift className="text-service-tech" size={32} />
           <div>
              <h4 className="font-black text-primary">Refer & Earn</h4>
              <p className="text-xs font-bold text-slate-500 mt-1">Get $20 for every friend who books their first service.</p>
           </div>
        </GlassCard>
      </div>
    </div>
  );
};
