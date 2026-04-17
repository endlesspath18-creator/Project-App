import React from 'react';
import { useNavigate } from 'react-router-dom';
import { motion } from 'motion/react';
import { User, Briefcase, ChevronRight } from 'lucide-react';
import { GlassCard } from '../../core/widgets/reusable_widgets';

export const LoginSelectionScreen = () => {
  const navigate = useNavigate();

  return (
    <div className="min-h-screen bg-bg p-8 flex flex-col justify-center">
      <motion.div 
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="text-center mb-12"
      >
        <h1 className="text-4xl font-black tracking-tighter mb-4 text-primary">LuxeService</h1>
        <p className="text-slate-500 font-bold">Premium Marketplace for Elite Services</p>
      </motion.div>

      <div className="space-y-4">
        {[
          { role: 'user', icon: User, title: 'I am a Client', desc: 'I want to book services' },
          { role: 'provider', icon: Briefcase, title: 'I am a Partner', desc: 'I want to provide services' },
        ].map((item, idx) => (
          <motion.div
            key={item.role}
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: idx * 0.1 }}
            onClick={() => navigate(`/login/${item.role}`)}
          >
            <GlassCard className="flex items-center gap-6 p-8 cursor-pointer hover:border-accent group transition-all">
              <div className="p-4 bg-accent/10 rounded-2xl group-hover:bg-accent group-hover:text-white transition-colors">
                <item.icon size={32} />
              </div>
              <div className="flex-1">
                <h3 className="text-lg font-black text-primary">{item.title}</h3>
                <p className="text-xs font-bold text-slate-500 uppercase tracking-widest mt-1">{item.desc}</p>
              </div>
              <ChevronRight className="text-slate-300" />
            </GlassCard>
          </motion.div>
        ))}
      </div>
    </div>
  );
};
