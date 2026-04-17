import React from 'react';
import { useNavigate } from 'react-router-dom';
import { motion } from 'motion/react';
import { Calendar } from 'lucide-react';
import { GlassCard, EmptyState, SectionHeader } from '../../../core/widgets/reusable_widgets';

export const BookingsScreen = () => {
  const navigate = useNavigate();
  return (
    <div className="pb-24 pt-12">
      <div className="px-6 mb-8 flex justify-between items-center">
        <div>
          <h2 className="text-3xl font-black text-primary tracking-tight">Active Work</h2>
          <p className="text-slate-500 font-bold text-sm">Real-time status of your requests</p>
        </div>
        <button className="p-3 bg-surface border border-border rounded-xl text-slate-400">
          <Calendar size={20} />
        </button>
      </div>

      <div className="px-6 space-y-6">
        <GlassCard 
          className="border-accent/20 bg-accent/5 cursor-pointer"
          onClick={() => navigate('/track/LS-92842')}
        >
          <div className="flex justify-between items-start mb-6">
             <div>
                <span className="px-3 py-1 bg-accent text-white rounded-lg text-[8px] font-black uppercase tracking-widest">Ongoing</span>
                <h4 className="text-xl font-black text-primary mt-3">Full AC Maintenance</h4>
                <p className="text-xs font-bold text-slate-500">ID: LS-92842 • Today, 14:30</p>
             </div>
             <div className="text-right">
                <div className="w-12 h-12 bg-white rounded-2xl flex items-center justify-center text-2xl shadow-sm">❄️</div>
             </div>
          </div>
          <div className="flex items-center gap-3">
             <div className="flex-1 h-1.5 bg-slate-200 dark:bg-white/10 rounded-full overflow-hidden">
                <motion.div 
                  initial={{ width: 0 }}
                  animate={{ width: '60%' }}
                  className="h-full bg-accent"
                />
             </div>
             <span className="text-[10px] font-black text-accent">ON THE WAY</span>
          </div>
        </GlassCard>

        <SectionHeader title="History" actionLabel="Full History" />
        <EmptyState 
           icon="📜" 
           title="No completed bookings yet" 
           desc="Your history will appear here once you complete your first service." 
        />
      </div>
    </div>
  );
};
