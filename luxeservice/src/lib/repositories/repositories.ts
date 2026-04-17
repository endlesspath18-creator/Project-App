import { MockService } from '../services/mock_service';
import { Service, Booking, Professional, Reward } from '../models/models';

export class ServiceRepository {
  async fetchAllServices(): Promise<Service[]> {
    return MockService.getServices();
  }

  async fetchByCategory(categoryId: string): Promise<Service[]> {
    const all = await MockService.getServices();
    return all.filter(s => s.category === categoryId);
  }
}

export class BookingRepository {
  async fetchUserBookings(): Promise<Booking[]> {
    return MockService.getBookings();
  }
}

export class ProfessionalRepository {
  async fetchAll(): Promise<Professional[]> {
    return MockService.getProfessionals();
  }
}

export class RewardRepository {
  async fetchAll(): Promise<Reward[]> {
    return MockService.getRewards();
  }
}
