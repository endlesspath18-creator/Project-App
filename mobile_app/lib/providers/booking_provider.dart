import 'package:flutter/foundation.dart';
import '../core/api_client.dart';

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
      final response = await ApiClient.get('/bookings/me');
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
      final response = await ApiClient.get('/provider/requests');
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
      final response = await ApiClient.get('/provider/active-jobs');
      if (response.statusCode == 200) {
        _providerBookings = response.data['data'] as List<dynamic>;
      }
    } catch (e) {
      _setError('Failed to fetch active jobs: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Create a new booking
  Future<bool> createBooking({
    required String serviceId,
    required DateTime scheduledDate,
    required String address,
    String? notes,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await ApiClient.post('/bookings', {
        'serviceId': serviceId,
        'scheduledDate': scheduledDate.toIso8601String(),
        'address': address,
        'notes': notes,
      });

      if (response.statusCode == 201) {
        return true;
      } else {
        _setError(response.data['message'] ?? 'Failed to book service');
        return false;
      }
    } catch (e) {
      _setError('An error occurred during booking: $e');
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
      final endpoint = '/bookings/$bookingId/$action';
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
