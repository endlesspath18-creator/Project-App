import React from 'react';
import { useNavigate } from 'react-router-dom';
import { motion } from 'motion/react';
import { ArrowLeft, ChevronRight } from 'lucide-react';
import { GlassCard, SectionHeader } from '../../../core/widgets/reusable_widgets';

export const SupportScreen = () => {
  const navigate = useNavigate();
  return (
    <div className="min-h-screen bg-bg">
      <div className="p-6 pt-12">
        <button onClick={() => navigate(-1)} className="p-4 bg-surface border border-border rounded-2xl mb-12">
          <ArrowLeft size={20} />
        </button>
        <h2 className="text-3xl font-black text-primary mb-2">Help Center</h2>
        <p className="text-slate-500 font-bold mb-10 text-sm">How can we assist you today?</p>

        <div className="space-y-4">
           {[
             { title: 'Chat Support', desc: 'Usually responds in 5 mins', icon: '💬' },
             { title: 'Raise a Ticket', desc: 'For issues with ongoing jobs', icon: '🎫' },
             { title: 'Email Us', desc: 'support@luxeservice.com', icon: '✉️' },
           ].map((item, idx) => (
             <GlassCard key={idx} className="flex items-center gap-6 cursor-pointer hover:border-accent group transition-all">
                <div className="text-3xl">{item.icon}</div>
                <div>
                  <h4 className="font-black text-primary">{item.title}</h4>
                  <p className="text-xs font-bold text-slate-400 mt-1">{item.desc}</p>
                </div>
             </GlassCard>
           ))}
        </div>

        <SectionHeader title="Popular FAQs" className="mt-12" />
        <div className="space-y-3">
           {['Cancellation Policy', 'Payment Methods', 'Safety Standards'].map(q => (
             <div key={q} className="p-5 border border-border rounded-2xl text-sm font-bold text-primary flex justify-between items-center bg-surface">
               {q} <ChevronRight size={14} className="text-slate-300" />
             </div>
           ))}
        </div>
      </div>
    </div>
  );
};

export const ProfileScreen = () => {
    const { user, logout, role } = useAuthStore();
    const navigate = useNavigate();
    
    return (
      <div className="pb-24 pt-16 px-6">
         <div className="flex flex-col items-center mb-12">
           <div className="w-24 h-24 bg-surface border-4 border-border rounded-[32px] flex items-center justify-center text-4xl shadow-xl">
             {role === 'provider' ? '🏢' : '👤'}
           </div>
           <h3 className="text-2xl font-black text-primary mt-6">{user?.name}</h3>
           <p className="text-accent text-[10px] font-black uppercase tracking-[0.2em] mt-1">{role} ACCOUNT</p>
         </div>
  
         <div className="space-y-3">
           {role === 'provider' ? (
             ['Manage Services', 'Earnings Report', 'Business Details', 'Support'].map((item) => (
               <div key={item} 
                    onClick={() => item === 'Support' && navigate('/support')}
                    className="p-6 bg-surface border border-border rounded-[28px] flex justify-between items-center group cursor-pointer hover:bg-bg transition-all">
                 <span className="font-bold text-primary">{item}</span>
                 <span className="text-slate-300">→</span>
               </div>
             ))
           ) : (
             ['Subscription', 'Saved Cards', 'Address Book', 'Support', 'Privacy Settings'].map((item) => (
               <div key={item} 
                    onClick={() => item === 'Support' && navigate('/support')}
                    className="p-6 bg-surface border border-border rounded-[28px] flex justify-between items-center group cursor-pointer hover:bg-bg transition-all">
                 <span className="font-bold text-primary">{item}</span>
                 <span className="text-slate-300">→</span>
               </div>
             ))
           )}
         </div>
  
         <button 
           onClick={logout}
           className="w-full mt-12 py-6 bg-service-urgent/5 text-service-urgent font-black tracking-widest text-[10px] uppercase rounded-[28px] border border-service-urgent/20 hover:bg-service-urgent hover:text-white transition-all"
         >
           SIGN OUT ACCOUNT
         </button>
      </div>
    );
  };

import { useAuthStore } from '../../../auth/auth_store';
