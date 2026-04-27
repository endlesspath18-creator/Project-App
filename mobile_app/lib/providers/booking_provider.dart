import 'package:flutter/foundation.dart';
import 'package:mobile_app/core/api_client.dart';
import 'package:mobile_app/core/constants.dart';

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

  List<dynamic> get pendingRequests => _incomingRequests.where((b) => b['status'] == 'PENDING').toList();
  List<dynamic> get activeJobsList => _providerBookings.where((b) => b['status'] == 'ACCEPTED' || b['status'] == 'IN_PROGRESS').toList();
  List<dynamic> get jobHistoryList => _providerBookings.where((b) => b['status'] == 'COMPLETED' || b['status'] == 'CANCELLED' || b['status'] == 'REJECTED').toList();

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
  Future<void> fetchUserBookings({bool force = false}) async {
    if (_isLoading) return;
    if (!force && _userBookings.isNotEmpty) return;
    
    _setLoading(true);
    _setError(null);
    try {
      final response = await ApiClient.get(AppConstants.userBookings);
      if (response.statusCode == 200) {
        _userBookings = response.data['data'] as List<dynamic>;
      }
    } catch (e) {
      if (e.toString().contains('403')) {
        debugPrint('GUARD: Blocked unauthorized fetchUserBookings');
      } else {
        _setError('Failed to fetch your bookings: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  // Fetch bookings for providers
  Future<void> fetchProviderRequests({bool force = false}) async {
    if (_isLoading) return;
    if (!force && _incomingRequests.isNotEmpty) return;

    _setLoading(true);
    _setError(null);
    try {
      final response = await ApiClient.get(AppConstants.providerBookings);
      if (response.statusCode == 200) {
        _incomingRequests = response.data['data'] as List<dynamic>;
      }
    } catch (e) {
      if (e.toString().contains('403')) {
        debugPrint('GUARD: Blocked unauthorized fetchProviderRequests');
      } else {
        _setError('Failed to fetch incoming requests: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchActiveJobs({bool force = false}) async {
    if (_isLoading) return;
    if (!force && _providerBookings.isNotEmpty) return;

    _setLoading(true);
    _setError(null);
    try {
      final response = await ApiClient.get(AppConstants.providerBookings);
      if (response.statusCode == 200) {
        _providerBookings = response.data['data'] as List<dynamic>;
      }
    } catch (e) {
       if (e.toString().contains('403')) {
        debugPrint('GUARD: Blocked unauthorized fetchActiveJobs');
      } else {
        _setError('Failed to fetch active jobs: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  // Create a new booking
  Future<Map<String, dynamic>?> createBooking({
    required String serviceId,
    required DateTime scheduledDate,
    required String address,
    required String slot,
    String? notes,
    String paymentMethod = 'COD',
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await ApiClient.post(AppConstants.createBooking, {
        'serviceId': serviceId,
        'scheduledDate': scheduledDate.toUtc().toIso8601String(),
        'slot': slot,
        'address': address,
        'notes': notes,
        'paymentMethod': paymentMethod,
      });

      if (response.statusCode == 201) return response.data['data'];
      _setError(response.data['message'] ?? 'Failed to book service');
      return null;
    } catch (e) {
      _setError('$e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Note: createPaymentOrder is now integrated into createBooking

  // Razorpay Verification
  Future<bool> verifyAndConfirmBooking({
    required String orderId,
    required String paymentId,
    required String signature,
    required String bookingId,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await ApiClient.post(AppConstants.paymentsVerify, {
        'razorpayOrderId': orderId,
        'razorpayPaymentId': paymentId,
        'razorpaySignature': signature,
        'bookingId': bookingId,
      });
      return response.statusCode == 200;
    } catch (e) {
      _setError('Verification Error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Handle cancelled or failed payment
  Future<void> markPaymentFailed(String bookingId, String reason) async {
    try {
      await ApiClient.post('/bookings/payment-failure', {
        'bookingId': bookingId,
        'reason': reason,
      });
    } catch (e) {
      debugPrint('Failed to notify backend about payment failure: $e');
    }
  }


  // Update status (Accept, Reject, Start, Complete)
  Future<bool> updateStatus(String bookingId, String action) async {
    _setLoading(true);
    _setError(null);
    try {
      final endpoint = '/bookings/$bookingId/$action';
      final response = await ApiClient.patch(endpoint, {});

      if (response.statusCode == 200) {
        await fetchProviderRequests();
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
