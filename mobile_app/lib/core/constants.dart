class AppConstants {
  static const String baseUrl = 'https://endlesspath-backend.onrender.com/api';
  
  static const String appName = 'EndlessPath Services';

  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String verifyMeEndpoint = '/auth/me';
  static const String servicesEndpoint = '/services';
  static const String providerServicesEndpoint = '/services/my';
  
  // Bookings Endpoints
  static const String userBookings = '/bookings/my';
  static const String providerBookings = '/bookings/provider';
  static const String createBooking = '/bookings';
  static const String paymentsCreateOrder = '/payments/create-order';
  static const String paymentsVerify = '/payments/verify';
  
  // Admin Endpoints
  static const String adminStats = '/admin/stats';
  static const String adminUsers = '/admin/users';
  static const String adminProviders = '/admin/providers';
  static const String adminBookings = '/admin/bookings';
}
