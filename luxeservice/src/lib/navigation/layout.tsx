import React from 'react';
import { Outlet, useNavigate, useLocation } from 'react-router-dom';
import { motion, AnimatePresence } from 'motion/react';
import { Home, Grid, Calendar, Award, Settings } from 'lucide-react';
import { cn } from '../core/widgets/reusable_widgets';

export const Layout = () => {
  const navigate = useNavigate();
  const location = useLocation();

  const tabs = [
    { id: 'home', path: '/home', icon: Home, label: 'Home' },
    { id: 'categories', path: '/categories', icon: Grid, label: 'Explore' },
    { id: 'bookings', path: '/bookings', icon: Calendar, label: 'Work' },
    { id: 'rewards', path: '/rewards', icon: Award, label: 'Perks' },
    { id: 'settings', path: '/profile', icon: Settings, label: 'Settings' },
  ];

  const currentTab = tabs.find(t => t.path === location.pathname)?.id || 'home';

  return (
    <div className="h-screen bg-bg text-primary font-sans max-w-md mx-auto relative overflow-hidden flex flex-col border-x border-border shadow-2xl">
      <main className="flex-1 overflow-y-auto no-scrollbar scroll-smooth bg-bg">
        <AnimatePresence mode="wait">
          <motion.div
            key={location.pathname}
            initial={{ opacity: 0, y: 10, scale: 0.98 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, y: -10, scale: 1.02 }}
            transition={{ type: "spring", duration: 0.5, bounce: 0.3 }}
            className="min-h-full"
          >
            <Outlet />
          </motion.div>
        </AnimatePresence>
      </main>

      {/* Flying Navigation Bar */}
      <div className="absolute bottom-10 left-1/2 -translate-x-1/2 w-[90%] z-50">
        <nav className="h-20 bg-white/90 backdrop-blur-2xl border border-white/40 rounded-[32px] px-4 flex justify-between items-center shadow-heavy">
          {tabs.map(tab => {
            const isActive = currentTab === tab.id;
            return (
              <button 
                key={tab.id}
                onClick={() => navigate(tab.path)}
                className="relative flex flex-col items-center justify-center w-16 h-full outline-none transition-all"
              >
                {/* Active Indicator Pill */}
                {isActive && (
                  <motion.div 
                    layoutId="flyingIndicator"
                    transition={{ type: "spring", stiffness: 400, damping: 30 }}
                    className="absolute inset-x-1 inset-y-2 bg-accent/5 rounded-2xl z-0"
                  />
                )}
                
                <div className={cn(
                  "relative z-10 transition-all duration-300",
                  isActive ? "text-accent scale-110 -translate-y-1" : "text-subtle"
                )}>
                  <tab.icon size={22} strokeWidth={isActive ? 2.5 : 2} />
                </div>
                
                <motion.span 
                  className={cn(
                    "text-[8px] font-black uppercase tracking-widest mt-1 relative z-10 transition-all",
                    isActive ? "text-accent opacity-100" : "text-subtle opacity-60"
                  )}
                  animate={{ y: isActive ? 0 : 2, opacity: isActive ? 1 : 0.6 }}
                >
                  {tab.label}
                </motion.span>

                {isActive && (
                  <motion.div 
                    layoutId="dot"
                    className="w-1.5 h-1.5 bg-accent rounded-full absolute -top-1"
                    transition={{ type: "spring", stiffness: 450, damping: 35 }}
                  />
                )}
              </button>
            );
          })}
        </nav>
      </div>
    </div>
  );
};
