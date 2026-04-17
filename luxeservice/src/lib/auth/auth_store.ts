import { create } from 'zustand';
import { User } from '../models/models';

interface AuthState {
  user: User | null;
  isAuthenticated: boolean;
  role: 'user' | 'provider' | null;
  login: (email: string, role: 'user' | 'provider') => void;
  logout: () => void;
}

export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  isAuthenticated: false,
  role: null,
  login: (email, role) => set({ 
    user: { id: 'u1', name: email.split('@')[0], email, role }, 
    isAuthenticated: true, 
    role 
  }),
  logout: () => set({ user: null, isAuthenticated: false, role: null }),
}));
