export interface User {
  id: string;
  name: string;
  email: string;
  role: 'user' | 'provider';
  avatarUrl?: string;
}

export interface Service {
  id: string;
  name: string;
  category: string;
  price: number;
  priceUnit: string;
  rating: number;
  reviews: number;
  description: string;
  icon: string;
  duration: string;
  includes: string[];
  isBestseller?: boolean;
}

export interface Professional {
  id: string;
  name: string;
  experience: string;
  rating: number;
  jobsCompleted: number;
  skills: string[];
  initials: string;
  verified: boolean;
}

export interface Reward {
  id: string;
  title: string;
  description: string;
  points: number;
  expiryDate: string;
  icon: string;
}

export interface Coupon {
  id: string;
  code: string;
  discount: string;
  description: string;
}

export interface Booking {
  id: string;
  serviceId: string;
  userId: string;
  providerId: string;
  status: 'pending' | 'ongoing' | 'completed' | 'cancelled' | 'tracking';
  date: string;
  time: string;
  totalPrice: number;
  address?: string;
  steps?: TimelineStep[];
}

export interface TimelineStep {
  label: string;
  status: 'completed' | 'ongoing' | 'pending';
  timestamp?: string;
}
