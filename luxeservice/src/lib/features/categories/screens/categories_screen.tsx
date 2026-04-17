import React from 'react';
import { motion } from 'motion/react';
import { Search, SlidersHorizontal, ChevronRight } from 'lucide-react';
import { CATEGORIES } from '../../../core/app_constants';
import { useNavigate } from 'react-router-dom';

export const CategoriesScreen = () => {
  const navigate = useNavigate();

  return (
    <div className="pb-24 pt-12">
      <div className="px-6 mb-8 flex justify-between items-center">
        <h2 className="text-3xl font-black text-primary tracking-tight">Browse</h2>
        <button className="p-3 bg-surface border border-border rounded-xl text-slate-400">
          <SlidersHorizontal size={20} />
        </button>
      </div>

      <div className="px-6 mb-8">
        <div className="relative group">
          <Search size={18} className="absolute left-5 top-1/2 -translate-y-1/2 text-slate-400" />
          <input 
            type="text" 
            placeholder="Search categories..."
            className="w-full bg-surface border border-border py-4 pl-14 pr-4 rounded-2xl text-sm font-bold outline-none focus:border-accent"
          />
        </div>
      </div>

      <div className="px-6 grid grid-cols-2 gap-4">
        {CATEGORIES.map((cat, idx) => (
          <motion.div
            key={cat.id}
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: idx * 0.05 }}
            onClick={() => navigate(`/services?category=${cat.id}`)}
            className="aspect-square bg-surface border border-border rounded-[40px] flex flex-col items-center justify-center p-6 cursor-pointer hover:border-accent group transition-all"
          >
            <div className="text-4xl mb-4 group-hover:scale-110 transition-transform">{cat.icon}</div>
            <h4 className="text-xs font-black text-primary uppercase tracking-widest text-center">{cat.name}</h4>
          </motion.div>
        ))}
      </div>
    </div>
  );
};
