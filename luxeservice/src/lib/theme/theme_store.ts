import { create } from 'zustand';

interface ThemeState {
  isDarkMode: boolean;
}

export const useThemeStore = create<ThemeState>(() => ({
  isDarkMode: false, // Premium Light Theme ONLY
}));

// Initialize theme
if (typeof window !== 'undefined') {
  document.documentElement.classList.remove('dark');
}
