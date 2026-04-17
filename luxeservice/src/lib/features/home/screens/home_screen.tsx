import React, { useEffect, useState } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { Search, SlidersHorizontal, ArrowRight, Zap, Trophy, Flame } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { CATEGORIES } from '../../../core/app_constants';
import { useAuthStore } from '../../../auth/auth_store';
import { PrimaryButton, SectionHeader, ServiceCard, OfferBanner, Shimmer } from '../../../core/widgets/reusable_widgets';
import { ServiceRepository, ProfessionalRepository } from '../../../repositories/repositories';
import { Service, Professional } from '../../../models/models';

export const HomeScreen = () => {
  const user = useAuthStore(state => state.user);
  const [services, setServices] = useState<Service[]>([]);
  const [pros, setPros] = useState<Professional[]>([]);
  const [loading, setLoading] = useState(true);
  const [isSearchFocused, setIsSearchFocused] = useState(false);
  const navigate = useNavigate();

  useEffect(() => {
    const sRepo = new ServiceRepository();
    const pRepo = new ProfessionalRepository();
    Promise.all([sRepo.fetchAllServices(), pRepo.fetchAll()]).then(([sData, pData]) => {
      setTimeout(() => {
        setServices(sData);
        setPros(pData);
        setLoading(false);
      }, 800);
    });
  }, []);

  return (
    <div className="pb-32 min-h-screen bg-bg">
      {/* Animated Greeting Header */}
      <header className="px-8 pt-16 pb-8 relative z-10">
        <motion.div
          initial={{ opacity: 0, x: -20 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ duration: 0.6, ease: [0.19, 1, 0.22, 1] }}
        >
          <div className="flex items-center gap-2 mb-2">
            <span className="w-2 h-2 bg-service-fresh rounded-full animate-pulse" />
            <p className="text-subtle font-black text-[10px] tracking-[0.3em] uppercase">Status: Premium Member</p>
          </div>
          <h1 className="text-4xl font-black tracking-tight text-primary leading-none">
            Welcome back,<br /> 
            <span className="text-accent underline decoration-accent/20 underline-offset-8">{user?.name || 'Guest'}</span>
          </h1>
        </motion.div>
      </header>

      {/* Modern Search Experience */}
      <motion.div 
        layout
        className="px-8 mb-10 transition-all duration-500"
      >
        <div className={cn(
          "relative group transition-all duration-500 border-2 rounded-[32px] overflow-hidden",
          isSearchFocused ? "border-accent ring-8 ring-accent/5 bg-surface scale-[1.02]" : "border-border bg-surface"
        )}>
          <Search size={22} className={cn(
            "absolute left-6 top-1/2 -translate-y-1/2 transition-colors duration-300",
            isSearchFocused ? "text-accent" : "text-subtle"
          )} />
          <input 
            type="text" 
            placeholder="Search premium services..."
            onFocus={() => setIsSearchFocused(true)}
            onBlur={() => setIsSearchFocused(false)}
            className="w-full py-6 pl-16 pr-16 text-md font-bold text-primary placeholder:text-subtle/50 bg-transparent outline-none"
          />
          <button className="absolute right-4 top-1/2 -translate-y-1/2 p-4 bg-bg rounded-2xl text-subtle hover:text-accent transition-colors">
            <SlidersHorizontal size={20} />
          </button>
        </div>
      </motion.div>

      {/* Quick Category Grid */}
      <section className="px-8 mb-12">
        <div className="grid grid-cols-4 gap-4">
          {CATEGORIES.slice(0, 4).map((cat, idx) => (
            <motion.div
              key={cat.id}
              initial={{ opacity: 0, scale: 0.8 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ delay: idx * 0.1, type: "spring" }}
              whileTap={{ scale: 0.9 }}
              onClick={() => navigate(`/services?category=${cat.id}`)}
              className="flex flex-col items-center group cursor-pointer"
            >
              <div className="w-full aspect-square bg-surface border border-border rounded-[28px] flex items-center justify-center text-3xl group-hover:shadow-heavy group-hover:border-accent transition-all mb-3">
                {cat.icon}
              </div>
              <span className="text-[9px] font-black text-primary uppercase tracking-widest text-center">{cat.name}</span>
            </motion.div>
          ))}
        </div>
      </section>

      {/* Hero Offers Section */}
      <div className="px-8 mb-12 flex overflow-x-auto gap-4 no-scrollbar scroll-smooth">
        <OfferBanner 
          title="Summer Fresh" 
          desc="Full AC servicing with 100% deep clean guarantee."
          code="SUMMER40"
          icon="❄️"
          className="min-w-[300px]"
        />
        <OfferBanner 
          title="Deep Clean" 
          desc="Professional home sanitation for a healthy space."
          code="CLEAN25"
          color="bg-primary"
          icon="🧼"
          className="min-w-[300px]"
        />
      </div>

      {/* Featured Services */}
      <SectionHeader title="Staff Favorites" actionLabel="Explore All" onAction={() => navigate('/services')} />
      <div className="px-8 space-y-8">
        {loading ? (
          [1,2].map(i => <Shimmer key={i} className="h-64 w-full" />)
        ) : (
          services.slice(0, 3).map((service, idx) => (
            <motion.div
              key={service.id}
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: idx * 0.15 }}
            >
              <ServiceCard service={service} onClick={() => navigate(`/service/${service.id}`)} />
            </motion.div>
          ))
        )}
      </div>

      {/* Emergency Quick Action */}
      <div className="px-8 mt-16">
        <motion.div 
           whileTap={{ scale: 0.98 }}
           onClick={() => navigate('/services?category=emerg')}
           className="bg-primary p-10 rounded-[44px] relative overflow-hidden group cursor-pointer"
        >
           <div className="relative z-10 text-white">
              <div className="flex items-center gap-2 mb-4">
                 <Flame className="text-service-urgent fill-service-urgent" size={24} />
                 <span className="text-[10px] font-black uppercase tracking-[0.3em]">Urgent Requests</span>
              </div>
              <h3 className="text-3xl font-black tracking-tight mb-2">Emergency Hub</h3>
              <p className="text-sm font-medium opacity-60 mb-8 max-w-[200px]">Get a qualified technician at your door in under 15 mins.</p>
              <div className="flex items-center gap-2 font-black text-xs group-hover:gap-4 transition-all">
                 VIEW OPTIONS <ArrowRight size={16} />
              </div>
           </div>
           <div className="absolute top-0 right-0 w-64 h-64 bg-accent/20 rounded-full -mr-32 -mt-32 blur-3xl opacity-50" />
           <div className="absolute bottom-0 right-10 text-[120px] opacity-10 select-none group-hover:scale-110 transition-transform">🚨</div>
        </motion.div>
      </div>

      {/* Trending Professionals */}
      <SectionHeader title="Top Performers" className="mt-20 mb-8" />
      <div className="px-8 flex overflow-x-auto gap-4 no-scrollbar pb-12">
        {pros.map((pro, idx) => (
          <motion.div 
            key={pro.id}
            initial={{ opacity: 0, scale: 0.9 }}
            whileInView={{ opacity: 1, scale: 1 }}
            viewport={{ once: true }}
            transition={{ delay: idx * 0.1 }}
            className="min-w-[220px] bg-surface p-8 border border-border rounded-card text-center group"
          >
             <div className="w-20 h-20 bg-bg rounded-3xl mx-auto mb-6 flex items-center justify-center text-2xl font-black text-subtle group-hover:bg-accent group-hover:text-surface transition-colors duration-500">
                {pro.initials}
             </div>
             <h5 className="font-black text-xl text-primary">{pro.name}</h5>
             <p className="text-[10px] font-black text-accent uppercase tracking-widest mt-2 px-3 py-1 bg-accent/5 rounded-lg inline-block">
                {pro.experience} Experience
             </p>
             <div className="flex justify-center items-center gap-2 mt-6">
                <Star size={16} className="text-gold fill-gold" />
                <span className="text-sm font-black text-primary">{pro.rating}</span>
                <span className="text-xs font-bold text-subtle">Rating</span>
             </div>
          </motion.div>
        ))}
      </div>
    </div>
  );
};

import { cn } from '../../../core/widgets/reusable_widgets';
