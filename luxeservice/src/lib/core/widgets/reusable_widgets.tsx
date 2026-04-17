import React from 'react';
import { motion } from 'motion/react';
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';
import { Star, Clock, Heart, ShieldCheck, ChevronRight, Zap } from 'lucide-react';
import { Service, Reward } from '../../models/models';

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'outline' | 'ghost';
  size?: 'sm' | 'md' | 'lg';
  fullWidth?: boolean;
}

export const PrimaryButton: React.FC<ButtonProps> = ({ 
  children, 
  variant = 'primary', 
  size = 'md', 
  fullWidth, 
  className,
  ...props 
}) => {
  const variants = {
    primary: 'bg-primary text-surface hover:shadow-heavy',
    secondary: 'bg-accent text-white hover:shadow-heavy',
    outline: 'bg-transparent border-2 border-primary text-primary hover:bg-primary hover:text-surface',
    ghost: 'bg-transparent text-primary hover:bg-border'
  };

  const sizes = {
    sm: 'px-6 py-2.5 text-xs font-black',
    md: 'px-8 py-4 text-sm font-black',
    lg: 'px-10 py-6 text-lg font-black'
  };

  return (
    <motion.button
      whileHover={{ scale: 1.02 }}
      whileTap={{ scale: 0.95 }}
      transition={{ type: "spring", stiffness: 400, damping: 10 }}
      className={cn(
        "rounded-[24px] flex items-center justify-center uppercase tracking-widest transition-all duration-300 disabled:opacity-50 disabled:grayscale",
        variants[variant],
        sizes[size],
        fullWidth && "w-full",
        className
      )}
      {...props}
    >
      <motion.span
        initial={{ y: 0 }}
        whileTap={{ y: 2 }}
        className="flex items-center gap-2"
      >
        {children}
      </motion.span>
    </motion.button>
  );
};

export const GlassCard: React.FC<React.HTMLAttributes<HTMLDivElement>> = ({ children, className, ...props }) => (
  <motion.div 
    whileHover={{ y: -2 }}
    className={cn("glass-card rounded-card p-6 shadow-premium transition-all duration-500", className)} 
    {...props}
  >
    {children}
  </motion.div>
);

export const SectionHeader: React.FC<{ 
  title: string; 
  actionLabel?: string; 
  onAction?: () => void;
  className?: string;
}> = ({ title, actionLabel, onAction, className }) => (
  <div className={cn("px-8 flex justify-between items-center mb-8", className)}>
    <h3 className="text-2xl font-black tracking-tight text-primary">{title}</h3>
    {actionLabel && (
      <button 
        onClick={onAction} 
        className="text-[10px] font-black tracking-[0.2em] text-subtle uppercase hover:text-accent transition-colors"
      >
        {actionLabel}
      </button>
    )}
  </div>
);

export const ServiceCard: React.FC<{ 
  service: Service; 
  onClick?: () => void;
  className?: string;
}> = ({ service, onClick, className }) => (
  <motion.div 
    layout
    initial={{ opacity: 0, y: 20 }}
    animate={{ opacity: 1, y: 0 }}
    whileTap={{ scale: 0.96 }}
    onClick={onClick}
    className={cn(
      "group relative bg-surface border border-border rounded-card overflow-hidden shadow-premium hover:shadow-heavy transition-all cursor-pointer",
      className
    )}
  >
    <div className="relative h-56 flex items-center justify-center text-7xl bg-bg/40">
       <motion.span 
         whileHover={{ scale: 1.1, rotate: 5 }}
         transition={{ type: "spring", stiffness: 300 }}
       >
         {service.icon}
       </motion.span>
       {service.isBestseller && (
         <div className="absolute top-6 left-6 px-4 py-2 bg-primary text-surface rounded-2xl text-[8px] font-black uppercase tracking-widest shadow-xl">
            Bestseller
         </div>
       )}
       <motion.button 
         whileTap={{ scale: 0.8 }}
         className="absolute top-6 right-6 p-4 bg-white/80 backdrop-blur-md rounded-2xl text-slate-300 hover:text-service-urgent border border-border"
       >
         <Heart size={20} />
       </motion.button>
    </div>
    <div className="p-8">
       <div className="flex justify-between items-start mb-4">
         <div className="flex-1">
            <span className="text-[10px] font-black text-accent uppercase tracking-widest">{service.category}</span>
            <h4 className="text-2xl font-black text-primary mt-2 truncate">{service.name}</h4>
         </div>
         <div className="text-right ml-4">
            <span className="text-2xl font-black text-primary">${service.price}</span>
            <span className="text-[8px] font-bold text-subtle uppercase tracking-widest block">{service.priceUnit}</span>
         </div>
       </div>
       <div className="flex items-center gap-6 mt-6 pt-6 border-t border-border">
          <div className="flex items-center gap-1.5">
             <Star size={16} className="text-gold fill-gold" />
             <span className="text-sm font-black text-primary">{service.rating}</span>
             <span className="text-xs font-medium text-subtle">({service.reviews})</span>
          </div>
          <div className="flex items-center gap-1.5 text-subtle">
             <Clock size={16} />
             <span className="text-sm font-bold">{service.duration}</span>
          </div>
       </div>
    </div>
  </motion.div>
);

export const OfferBanner: React.FC<{ 
  title: string; 
  desc: string; 
  code: string;
  icon?: string;
  color?: string;
}> = ({ title, desc, code, icon = "🎁", color = "bg-accent" }) => (
  <motion.div 
    whileHover={{ scale: 1.01 }}
    className={cn("p-8 rounded-card text-white relative overflow-hidden", color)}
  >
    <div className="relative z-10 flex justify-between items-center">
      <div className="max-w-[70%]">
        <h4 className="text-2xl font-black tracking-tight leading-none mb-2">{title}</h4>
        <p className="text-xs font-medium opacity-80 mb-4">{desc}</p>
        <div className="inline-flex px-4 py-2 bg-white/20 backdrop-blur-md rounded-xl text-[10px] font-black uppercase tracking-widest">
          {code}
        </div>
      </div>
      <div className="text-6xl opacity-30 select-none">{icon}</div>
    </div>
    <div className="absolute top-0 right-0 w-32 h-32 bg-white/10 rounded-full -mr-16 -mt-16 blur-2xl" />
  </motion.div>
);

export const RewardCard: React.FC<{ reward: Reward }> = ({ reward }) => (
  <motion.div
    whileTap={{ scale: 0.98 }}
    className="p-1 group bg-surface border border-border rounded-card hover:border-accent transition-all cursor-pointer"
  >
    <div className="p-7 flex items-center gap-6">
      <div className="w-16 h-16 bg-bg rounded-3xl flex items-center justify-center text-3xl group-hover:scale-110 transition-transform duration-500">
         {reward.icon}
      </div>
      <div className="flex-1">
         <h4 className="text-lg font-black text-primary">{reward.title}</h4>
         <p className="text-xs font-medium text-subtle mt-1">{reward.description}</p>
         <div className="flex items-center gap-3 mt-4">
            <span className="text-[9px] font-black text-service-fresh bg-service-fresh/10 px-2 py-1 rounded-lg uppercase tracking-wider">
               Earn {reward.points} PTS
            </span>
         </div>
      </div>
      <ChevronRight className="text-border group-hover:text-accent transition-colors" size={24} />
    </div>
  </motion.div>
);

export const EmptyState: React.FC<{ icon: string, title: string, desc: string }> = ({ icon, title, desc }) => (
  <motion.div 
    initial={{ opacity: 0 }}
    animate={{ opacity: 1 }}
    className="flex flex-col items-center justify-center p-12 text-center"
  >
     <div className="text-7xl mb-8 grayscale opacity-10">{icon}</div>
     <h4 className="text-2xl font-black text-primary mb-3">{title}</h4>
     <p className="text-sm font-medium text-subtle max-w-[240px] leading-relaxed">{desc}</p>
  </motion.div>
);

export const Shimmer: React.FC<{ className?: string }> = ({ className }) => (
  <div className={cn("shimmer bg-slate-100 rounded-[28px]", className)} />
);
