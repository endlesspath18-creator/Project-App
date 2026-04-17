import React, { useEffect, useState } from 'react';
import { motion } from 'motion/react';
import { useParams, useNavigate } from 'react-router-dom';
import { ArrowLeft, Star, Clock, Heart, ShieldCheck, CheckCircle2 } from 'lucide-react';
import { ServiceRepository } from '../../../repositories/repositories';
import { Service } from '../../../models/models';
import { PrimaryButton, GlassCard, SectionHeader } from '../../../core/widgets/reusable_widgets';

export const ServiceDetailScreen = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const [service, setService] = useState<Service | null>(null);
  const [activePackage, setActivePackage] = useState('Standard');

  useEffect(() => {
    const repo = new ServiceRepository();
    repo.fetchAllServices().then(data => {
      const found = data.find(s => s.id === id);
      if (found) setService(found);
    });
  }, [id]);

  if (!service) return <div className="p-8 text-center text-slate-400">Loading details...</div>;

  const packages = [
    { name: 'Basic', price: service.price * 0.8, desc: 'Essential maintenance' },
    { name: 'Standard', price: service.price, desc: 'Most popular choice' },
    { name: 'Premium', price: service.price * 1.5, desc: 'Complete deep overhaul' }
  ];

  return (
    <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} className="min-h-screen bg-bg">
      <div className="relative h-72 bg-surface flex items-center justify-center text-8xl">
        <button 
           onClick={() => navigate(-1)} 
           className="absolute top-12 left-6 p-4 bg-bg/50 backdrop-blur-md rounded-2xl border border-border text-primary z-20"
        >
          <ArrowLeft size={20} />
        </button>
        <button className="absolute top-12 right-6 p-4 bg-bg/50 backdrop-blur-md rounded-2xl border border-border text-slate-300 z-20">
          <Heart size={20} />
        </button>
        <div className="scale-150">{service.icon}</div>
      </div>

      <div className="px-6 -mt-10 relative z-10 bg-bg rounded-t-[40px] pt-10 pb-32 shadow-2xl shadow-black/5">
        <span className="text-[10px] font-black tracking-widest text-accent uppercase">{service.category}</span>
        <h2 className="text-4xl font-black text-primary tracking-tighter mt-2">{service.name}</h2>
        
        <div className="flex items-center gap-6 mt-6">
           <div className="flex items-center gap-2">
             <Star className="text-gold fill-gold" size={18} />
             <span className="font-bold text-primary">{service.rating}</span>
             <span className="text-slate-400 text-sm font-bold">({service.reviews} reviews)</span>
           </div>
        </div>

        <p className="mt-8 text-slate-500 font-bold leading-relaxed">{service.description}</p>

        <SectionHeader title="Select Package" className="mt-12" />
        <div className="flex gap-4 overflow-x-auto no-scrollbar pb-4">
           {packages.map((pkg) => (
             <button 
               key={pkg.name}
               onClick={() => setActivePackage(pkg.name)}
               className={cn(
                 "min-w-[160px] p-6 rounded-[32px] border-2 transition-all text-left",
                 activePackage === pkg.name ? "border-accent bg-accent/5" : "border-border bg-surface"
               )}
             >
                <h5 className="font-black text-primary">{pkg.name}</h5>
                <p className="text-[10px] font-bold text-slate-400 uppercase mt-1 mb-4">{pkg.desc}</p>
                <p className="text-2xl font-black text-primary">${Math.round(pkg.price)}</p>
             </button>
           ))}
        </div>

        <SectionHeader title="What's Included" className="mt-8" />
        <div className="space-y-4">
           {service.includes.map((item, idx) => (
             <div key={idx} className="flex gap-4 items-center">
                <div className="w-8 h-8 rounded-xl bg-service-fresh/10 text-service-fresh flex items-center justify-center">
                   <CheckCircle2 size={16} />
                </div>
                <span className="font-bold text-sm text-slate-500">{item}</span>
             </div>
           ))}
        </div>

        <div className="grid grid-cols-2 gap-4 mt-8 mb-8">
           <GlassCard className="!p-5">
              <Clock className="text-accent mb-3" size={20} />
              <p className="text-[8px] font-black text-slate-400 uppercase tracking-widest">DURATION</p>
              <p className="font-black text-primary">{service.duration}</p>
           </GlassCard>
           <GlassCard className="!p-5">
              <ShieldCheck className="text-service-fresh mb-3" size={20} />
              <p className="text-[8px] font-black text-slate-400 uppercase tracking-widest">WARRANTY</p>
              <p className="font-black text-primary">90 Days</p>
           </GlassCard>
        </div>

        <div className="fixed bottom-0 left-0 right-0 p-8 bg-gradient-to-t from-bg via-bg to-transparent z-50">
           <PrimaryButton fullWidth size="lg" onClick={() => navigate(`/book/${id}`)}>CONTINUE TO BOOK</PrimaryButton>
        </div>
      </div>
    </motion.div>
  );
};

import { cn } from '../../../core/widgets/reusable_widgets';
