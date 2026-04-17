import React, { useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { motion } from 'motion/react';
import { ArrowLeft, Mail, Lock } from 'lucide-react';
import { PrimaryButton } from '../../core/widgets/reusable_widgets';
import { useAuthStore } from '../auth_store';

export const LoginScreen = () => {
  const { role } = useParams<{ role: 'user' | 'provider' }>();
  const navigate = useNavigate();
  const login = useAuthStore(state => state.login);
  const [email, setEmail] = useState('');

  const handleLogin = (e: React.FormEvent) => {
    e.preventDefault();
    if (email) {
      login(email, role || 'user');
      navigate('/home');
    }
  };

  return (
    <div className="min-h-screen bg-bg p-8">
      <button onClick={() => navigate(-1)} className="p-4 bg-surface border border-border rounded-2xl mb-12">
        <ArrowLeft size={20} />
      </button>

      <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }}>
        <h2 className="text-3xl font-black text-primary mb-2">Welcome Back</h2>
        <p className="text-slate-500 font-bold mb-10 text-sm">
          Login to your {role === 'provider' ? 'Partner' : 'Client'} account
        </p>

        <form onSubmit={handleLogin} className="space-y-6">
          <div className="space-y-2">
            <label className="text-[10px] font-black uppercase tracking-widest text-slate-400">Email Address</label>
            <div className="relative">
              <Mail size={18} className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-300" />
              <input 
                type="email" 
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="alex@luxeservice.com" 
                className="w-full bg-surface border border-border py-5 pl-12 pr-4 rounded-2xl outline-none focus:border-accent text-sm font-bold"
                required
              />
            </div>
          </div>

          <div className="space-y-2">
            <label className="text-[10px] font-black uppercase tracking-widest text-slate-400">Password</label>
            <div className="relative">
              <Lock size={18} className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-300" />
              <input 
                type="password" 
                placeholder="••••••••" 
                className="w-full bg-surface border border-border py-5 pl-12 pr-4 rounded-2xl outline-none focus:border-accent text-sm font-bold"
                required
              />
            </div>
          </div>

          <div className="pt-8">
            <PrimaryButton fullWidth type="submit">CONTINUE SECURELY</PrimaryButton>
          </div>
        </form>
      </motion.div>
    </div>
  );
};
