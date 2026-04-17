import React from 'react';
import { motion } from 'motion/react';
import { useNavigate } from 'react-router-dom';
import { ArrowLeft, ShieldCheck } from 'lucide-react';
import { GlassCard, cn } from '../../../core/widgets/reusable_widgets';

export const LiveTrackingScreen = () => {
  const navigate = useNavigate();
  const steps = [
    { label: 'Confirmed', status: 'completed', time: '10:00 AM' },
    { label: 'Professional Assigned', status: 'completed', time: '10:15 AM' },
    { label: 'On the Way', status: 'ongoing', time: 'Estimated 2:45 PM' },
    { label: 'Arrived', status: 'pending' },
    { label: 'Work Started', status: 'pending' },
    { label: 'Completed', status: 'pending' },
  ];

  return (
    <div className="min-h-screen bg-bg pb-12">
      <div className="p-6 bg-surface border-b border-border flex items-center gap-4 sticky top-0 z-50">
        <button onClick={() => navigate(-1)} className="p-3 bg-bg border border-border rounded-xl">
           <ArrowLeft size={18} />
        </button>
        <h3 className="font-black text-primary uppercase tracking-widest text-xs">Live Tracking</h3>
      </div>

      <div className="p-8">
         <div className="relative">
            {steps.map((step, idx) => (
              <div key={idx} className="flex gap-6 pb-10 last:pb-0 relative group">
                {idx !== steps.length - 1 && (
                  <div className={`absolute left-[13px] top-7 w-[2px] h-[calc(100%-28px)] ${step.status === 'completed' ? 'bg-accent' : 'bg-slate-200 dark:bg-white/10'}`} />
                )}
                
                <div className={cn(
                  "w-7 h-7 rounded-full flex items-center justify-center z-10",
                  step.status === 'completed' ? "bg-accent text-white shadow-lg shadow-accent/30" : 
                  step.status === 'ongoing' ? "bg-accent/20 text-accent border-2 border-accent animate-pulse" : 
                  "bg-slate-200 dark:bg-white/10 text-slate-400"
                )}>
                  {step.status === 'completed' ? <ShieldCheck size={14} /> : <div className="w-2 h-2 rounded-full bg-current" />}
                </div>

                <div className="flex-1 pt-0.5">
                   <h4 className={cn(
                     "font-black text-sm uppercase tracking-wide",
                     step.status === 'pending' ? "text-slate-400" : "text-primary"
                   )}>
                     {step.label}
                   </h4>
                   {step.time && <p className="text-[10px] font-bold text-slate-500 mt-1">{step.time}</p>}
                </div>
              </div>
            ))}
         </div>
      </div>

      <div className="px-6 mt-12">
         <GlassCard className="flex items-center gap-6">
            <div className="w-16 h-16 bg-surface rounded-2xl flex items-center justify-center text-3xl shadow-sm border border-border">RF</div>
            <div className="flex-1">
               <h4 className="font-black text-primary">Robert Fox</h4>
               <p className="text-xs font-bold text-slate-500 mt-0.5">HVAC Expert • 4.9 ★</p>
               <div className="flex gap-4 mt-3">
                  <button className="text-[10px] font-black text-accent uppercase tracking-widest">Call Pro</button>
                  <button className="text-[10px] font-black text-accent uppercase tracking-widest">Chat</button>
               </div>
            </div>
         </GlassCard>
      </div>
    </div>
  );
};
