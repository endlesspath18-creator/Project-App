import 'package:flutter/foundation.dart';
import 'package:mobile_app/core/api_client.dart';

enum BookingViewType { user, provider }

class BookingProvider with ChangeNotifier {
  List<dynamic> _userBookings = [];
  List<dynamic> _providerBookings = [];
  List<dynamic> _incomingRequests = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get userBookings => _userBookings;
  List<dynamic> get providerBookings => _providerBookings;
  List<dynamic> get incomingRequests => _incomingRequests;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  // Fetch bookings for regular users
  Future<void> fetchUserBookings() async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await ApiClient.get('/api/bookings/my');
      if (response.statusCode == 200) {
        _userBookings = response.data['data'] as List<dynamic>;
      }
    } catch (e) {
      _setError('Failed to fetch your bookings: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Fetch bookings for providers
  Future<void> fetchProviderRequests() async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await ApiClient.get('/api/bookings/provider');
      if (response.statusCode == 200) {
        _incomingRequests = response.data['data'] as List<dynamic>;
      }
    } catch (e) {
      _setError('Failed to fetch incoming requests: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchActiveJobs() async {
    _setLoading(true);
    _setError(null);
    try {
      // Backend getProviderBookings returns all, we filter local if needed or just use separate
      final response = await ApiClient.get('/api/bookings/provider');
      if (response.statusCode == 200) {
        _providerBookings = response.data['data'] as List<dynamic>;
      }
    } catch (e) {
      _setError('Failed to fetch active jobs: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Create a new booking (COD or fallback)
  Future<bool> createBooking({
    required String serviceId,
    required DateTime scheduledDate,
    required String address,
    String? notes,
    String paymentMethod = 'COD',
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await ApiClient.post('/api/bookings', {
        'serviceId': serviceId,
        'scheduledDate': scheduledDate.toIso8601String(),
        'address': address,
        'notes': notes,
        'paymentMethod': paymentMethod,
      });

      if (response.statusCode == 201) return true;
      _setError(response.data['message'] ?? 'Failed to book service');
      return false;
    } catch (e) {
      _setError('$e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Razorpay: Step 1 - Create Order
  Future<Map<String, dynamic>?> createPaymentOrder(String serviceId) async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await ApiClient.post('/api/payments/create-order', {
        'serviceId': serviceId,
      });

      if (response.statusCode == 201) {
        return response.data['data']; // Contains orderId, amount, key
      }
      _setError(response.data['message'] ?? 'Failed to create payment order');
      return null;
    } catch (e) {
      _setError('Payment Init Error: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Razorpay: Step 2 - Verify and Finalize Booking
  Future<bool> verifyAndConfirmBooking({
    required String orderId,
    required String paymentId,
    required String signature,
    required Map<String, dynamic> bookingData,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await ApiClient.post('/api/payments/verify', {
        'razorpay_order_id': orderId,
        'razorpay_payment_id': paymentId,
        'razorpay_signature': signature,
        'bookingData': bookingData,
      });

      if (response.statusCode == 201) return true;
      _setError(response.data['message'] ?? 'Payment verification failed');
      return false;
    } catch (e) {
      _setError('Verification Error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update status (Accept, Reject, Start, Complete)
  Future<bool> updateStatus(String bookingId, String action) async {
    _setLoading(true);
    _setError(null);
    try {
      // Endpoint mapping: accept, reject, start, complete
      final endpoint = '/api/bookings/$bookingId/$action';
      final response = await ApiClient.patch(endpoint, {});

      if (response.statusCode == 200) {
        await fetchProviderRequests(); // Sync lists
        await fetchActiveJobs();
        return true;
      } else {
        _setError(response.data['message'] ?? 'Action failed');
        return false;
      }
    } catch (e) {
      _setError('Failed to update status: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
