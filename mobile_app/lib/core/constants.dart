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
  static const String paymentsVerify = '/bookings/confirm-payment';
  
  // Me Endpoints
  static const String meDashboard = '/me/dashboard';
  static const String meBookings = '/me/bookings';
  static const String meFavorites = '/me/favorites';
  static const String mePayments = '/me/payments';
  static const String meNotifications = '/me/notifications';
  static const String meProfile = '/me/profile';
  static const String meChangePassword = '/me/change-password';
  static const String meLogoutAll = '/me/logout-all';
  static const String meSupport = '/me/support/tickets';

  // Admin Endpoints
  static const String adminStats = '/admin/dashboard/stats';
  static const String adminFinance = '/admin/finance/summary';
  static const String adminProviders = '/admin/providers';


  // Booking Actions
  static String cancelBooking(String id) => '/bookings/$id/cancel';
  static String rescheduleBooking(String id) => '/bookings/$id/reschedule';
  static String retryPayment(String id) => '/bookings/$id/retry-payment';
}

