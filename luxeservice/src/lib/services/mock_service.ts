import { Service, Booking, User, Professional, Reward, Coupon } from '../models/models';
import { API_SIMULATION_DELAY } from '../core/app_constants';

export class MockService {
  static async getServices(): Promise<Service[]> {
    await new Promise(r => setTimeout(r, API_SIMULATION_DELAY));
    return [
      {
        id: '1',
        name: 'Full AC Maintenance',
        category: 'ac',
        price: 85,
        priceUnit: 'session',
        rating: 4.9,
        reviews: 128,
        description: 'Elite AC deep cleaning and gas top-up with 90-day warranty.',
        icon: '❄️',
        duration: '60 mins',
        includes: ['Filter Cleaning', 'Gas Level Check', 'Coil Cleaning'],
        isBestseller: true
      },
      {
        id: '2',
        name: 'Deep Home Cleaning',
        category: 'clean',
        price: 120,
        priceUnit: 'service',
        rating: 4.8,
        reviews: 245,
        description: 'Comprehensive cleaning for all rooms with industrial-grade equipment.',
        icon: '✨',
        duration: '4 hours',
        includes: ['Kitchen Sanitization', 'Floor Scrubbing', 'Window Cleaning'],
        isBestseller: true
      },
      {
        id: '3',
        name: 'Modern Wall Painting',
        category: 'paint',
        price: 350,
        priceUnit: 'room',
        rating: 4.7,
        reviews: 89,
        description: 'Premium emulsion painting with site cleanup included.',
        icon: '🎨',
        duration: '2 days',
        includes: ['Surface Priming', 'Two-coat Finish', 'Full Cleanup']
      },
      {
        id: '4',
        name: 'Emergency Plumbing',
        category: 'plumb',
        price: 45,
        priceUnit: 'visit',
        rating: 5.0,
        reviews: 67,
        description: 'Instant response for leaks, bursts, or drain blockages.',
        icon: '🚰',
        duration: '30-90 mins',
        includes: ['Initial Inspection', 'Minor Leak Fixes'],
      },
      {
        id: '5',
        name: 'CCTV Installation',
        category: 'cctv',
        price: 299,
        priceUnit: 'system',
        rating: 4.9,
        reviews: 42,
        description: 'Full installation of 4 camera system with mobile access.',
        icon: '📹',
        duration: '5 hours',
        includes: ['Wiring', 'NVR Setup', 'App Configuration']
      }
    ];
  }

  static async getProfessionals(): Promise<Professional[]> {
    return [
      { id: 'pro-1', name: 'Robert Fox', experience: '8 Years', rating: 4.9, jobsCompleted: 1240, skills: ['AC Expert', 'HVAC'], initials: 'RF', verified: true },
      { id: 'pro-2', name: 'Jane Cooper', experience: '5 Years', rating: 4.8, jobsCompleted: 850, skills: ['Plumbing', 'Sanitary'], initials: 'JC', verified: true },
    ];
  }

  static async getRewards(): Promise<Reward[]> {
    return [
      { id: 'rew-1', title: 'Loyalty Bonus', description: 'Earned for booking 5 services in a month.', points: 500, expiryDate: '2026-12-31', icon: '🏆' },
      { id: 'rew-2', title: 'Referral Bonus', description: 'Invite a friend and earn credits.', points: 250, expiryDate: '2027-01-15', icon: '🤝' },
    ];
  }

  static async getBookings(): Promise<Booking[]> {
    await new Promise(r => setTimeout(r, API_SIMULATION_DELAY));
    return [
      {
        id: 'LS-92842',
        serviceId: '1',
        userId: 'user-1',
        providerId: 'prov-1',
        status: 'ongoing',
        date: '2026-04-18',
        time: '14:30',
        totalPrice: 85,
        steps: [
          { label: 'Confirmed', status: 'completed', timestamp: '10:00 AM' },
          { label: 'Pro Assigned', status: 'completed', timestamp: '10:15 AM' },
          { label: 'On the Way', status: 'ongoing' },
          { label: 'Arrived', status: 'pending' },
          { label: 'Completed', status: 'pending' },
        ]
      }
    ];
  }
}
