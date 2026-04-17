import React, { useState } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { useNavigate, useParams } from 'react-router-dom';
import { ArrowLeft, Check, Calendar as CalendarIcon, Clock, MapPin, CreditCard } from 'lucide-react';
import { PrimaryButton, GlassCard, cn } from '../../../core/widgets/reusable_widgets';

export const BookingFlow = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const [step, setStep] = useState(1);
  const [selectedDate, setSelectedDate] = useState('');
  const [selectedTime, setSelectedTime] = useState('');

  const nextStep = () => setStep(s => s + 1);
  const prevStep = () => step > 1 ? setStep(s => s - 1) : navigate(-1);

  const steps = [
    { title: 'Date & Time', icon: CalendarIcon },
    { title: 'Address', icon: MapPin },
    { title: 'Payment', icon: CreditCard },
    { title: 'Confirm', icon: Check },
  ];

  const renderStep = () => {
     switch(step) {
        case 1:
          return (
            <div className="space-y-8">
               <div className="space-y-4">
                  <h4 className="font-black text-primary uppercase text-xs tracking-widest">Select Date</h4>
                  <div className="flex gap-3 overflow-x-auto no-scrollbar">
                     {['18 Apr', '19 Apr', '20 Apr', '21 Apr', '22 Apr'].map(d => (
                       <button 
                         key={d}
                         onClick={() => setSelectedDate(d)}
                         className={cn(
                           "min-w-[100px] p-6 rounded-3xl border-2 transition-all text-center",
                           selectedDate === d ? "border-accent bg-accent/5" : "border-border bg-surface"
                         )}
                       >
                          <p className="text-[10px] font-black text-slate-400 uppercase">SAT</p>
                          <p className="text-xl font-black text-primary mt-1">{d.split(' ')[0]}</p>
                       </button>
                     ))}
                  </div>
               </div>
               <div className="space-y-4">
                  <h4 className="font-black text-primary uppercase text-xs tracking-widest">Select Time</h4>
                  <div className="grid grid-cols-3 gap-3">
                     {['09:00', '11:00', '13:30', '15:00', '17:30', '19:00'].map(t => (
                        <button 
                          key={t}
                          onClick={() => setSelectedTime(t)}
                          className={cn(
                            "py-4 rounded-2xl border-2 transition-all font-bold text-sm",
                            selectedTime === t ? "border-accent bg-accent/5 text-accent" : "border-border bg-surface text-slate-500"
                          )}
                        >
                          {t}
                        </button>
                     ))}
                  </div>
               </div>
            </div>
          );
        case 2:
          return (
            <div className="space-y-6">
               <h4 className="font-black text-primary uppercase text-xs tracking-widest">Service Location</h4>
               <GlassCard className="border-accent bg-accent/5 !p-6">
                  <div className="flex gap-4">
                     <MapPin className="text-accent" />
                     <div>
                        <h5 className="font-black text-primary">Home Address</h5>
                        <p className="text-xs font-bold text-slate-500 mt-1">402, High Street, Downtown North</p>
                     </div>
                  </div>
               </GlassCard>
               <button className="w-full py-4 border-2 border-dashed border-border rounded-2xl text-[10px] font-black text-slate-400 uppercase tracking-widest">
                  + Add New Address
               </button>
            </div>
          );
        case 3:
          return (
            <div className="space-y-6">
                <h4 className="font-black text-primary uppercase text-xs tracking-widest">Payment Method</h4>
                <div className="space-y-3">
                   {['Apple Pay', 'Credit Card (**** 9012)', 'Cash After Service'].map((method, idx) => (
                      <div key={method} className={cn(
                        "p-6 border-2 rounded-3xl flex items-center justify-between cursor-pointer transition-all",
                        idx === 0 ? "border-accent bg-accent/5" : "border-border bg-surface"
                      )}>
                         <span className="font-bold text-primary">{method}</span>
                         {idx === 0 && <div className="w-5 h-5 bg-accent rounded-full flex items-center justify-center text-white"><Check size={12} /></div>}
                      </div>
                   ))}
                </div>
            </div>
          );
        case 4:
          return (
             <div className="space-y-8">
                <div className="text-center py-8">
                   <div className="w-24 h-24 bg-service-fresh/10 text-service-fresh rounded-full flex items-center justify-center mx-auto mb-6">
                      <Check size={48} />
                   </div>
                   <h3 className="text-3xl font-black text-primary tracking-tighter">Review Details</h3>
                   <p className="text-slate-500 font-bold mt-2">Almost there! Final check.</p>
                </div>
                <GlassCard className="space-y-4">
                   <div className="flex justify-between border-b border-border pb-4">
                      <span className="text-slate-400 font-bold text-xs uppercase tracking-widest">Service</span>
                      <span className="font-black text-primary">Full AC Maintenance</span>
                   </div>
                   <div className="flex justify-between border-b border-border pb-4">
                      <span className="text-slate-400 font-bold text-xs uppercase tracking-widest">Date & Time</span>
                      <span className="font-black text-primary">18 Apr, 14:30</span>
                   </div>
                   <div className="flex justify-between">
                      <span className="text-slate-400 font-bold text-xs uppercase tracking-widest">Total Amount</span>
                      <span className="font-black text-accent text-xl">$85.00</span>
                   </div>
                </GlassCard>
             </div>
          );
     }
  };

  return (
    <div className="min-h-screen bg-bg flex flex-col">
       <header className="p-6 bg-surface border-b border-border flex items-center justify-between sticky top-0 z-50">
          <button onClick={prevStep} className="p-3 bg-bg border border-border rounded-xl">
             <ArrowLeft size={18} />
          </button>
          <div className="flex gap-2">
             {steps.map((_, idx) => (
               <div key={idx} className={cn(
                 "w-2 h-2 rounded-full transition-all duration-500",
                 step === idx + 1 ? "w-8 bg-accent" : (step > idx + 1 ? "bg-accent/40" : "bg-slate-200 dark:bg-white/10")
               )} />
             ))}
          </div>
          <div className="w-10" />
       </header>

       <main className="flex-1 p-8">
          <AnimatePresence mode="wait">
             <motion.div 
               key={step}
               initial={{ opacity: 0, x: 20 }}
               animate={{ opacity: 1, x: 0 }}
               exit={{ opacity: 0, x: -20 }}
             >
                {renderStep()}
             </motion.div>
          </AnimatePresence>
       </main>

       <footer className="p-8 bg-surface border-t border-border">
          <PrimaryButton 
            fullWidth 
            size="lg" 
            onClick={step === 4 ? () => navigate('/bookings') : nextStep}
          >
            {step === 4 ? 'CONFIRM BOOKING' : 'CONTINUE'}
          </PrimaryButton>
       </footer>
    </div>
  );
};
