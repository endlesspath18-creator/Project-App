import 'package:flutter/material.dart';
import 'package:mobile_app/core/api_client.dart';
import 'package:mobile_app/core/constants.dart';

class UserAccountProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? _dashboardData;
  List<dynamic> _bookings = [];
  List<dynamic> _favorites = [];
  List<dynamic> _payments = [];
  List<dynamic> _notifications = [];
  List<dynamic> _tickets = [];
  Map<String, dynamic>? _profile;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Map<String, dynamic>? get dashboardData => _dashboardData;
  List<dynamic> get bookings => _bookings;
  List<dynamic> get favorites => _favorites;
  List<dynamic> get payments => _payments;
  List<dynamic> get notifications => _notifications;
  List<dynamic> get tickets => _tickets;
  Map<String, dynamic>? get profile => _profile;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  Future<void> fetchDashboard() async {
    _setLoading(true);
    try {
      final response = await ApiClient.get(AppConstants.meDashboard);
      _dashboardData = response.data['data'];
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchBookings({String? status}) async {
    _setLoading(true);
    try {
      final url = status != null ? '${AppConstants.meBookings}?status=$status' : AppConstants.meBookings;
      final response = await ApiClient.get(url);
      _bookings = response.data['data'] ?? [];
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchFavorites() async {
    _setLoading(true);
    try {
      final response = await ApiClient.get(AppConstants.meFavorites);
      _favorites = response.data['data'] ?? [];
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchPayments() async {
    _setLoading(true);
    try {
      final response = await ApiClient.get(AppConstants.mePayments);
      _payments = response.data['data'] ?? [];
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchNotifications() async {
    _setLoading(true);
    try {
      final response = await ApiClient.get(AppConstants.meNotifications);
      _notifications = response.data['data'] ?? [];
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchTickets() async {
    _setLoading(true);
    try {
      final response = await ApiClient.get(AppConstants.meSupport);
      _tickets = response.data['data'] ?? [];
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchProfile() async {
    _setLoading(true);
    try {
      final response = await ApiClient.get(AppConstants.meProfile);
      _profile = response.data['data'];
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> cancelBooking(String id, String reason) async {
    try {
      await ApiClient.patch(AppConstants.cancelBooking(id), {'reason': reason});
      await fetchBookings();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> rescheduleBooking(String id, String date, String slot) async {
    try {
      await ApiClient.patch(AppConstants.rescheduleBooking(id), {
        'scheduledDate': date,
        'slot': slot,
      });
      await fetchBookings();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<Map<String, dynamic>?> retryPayment(String id) async {
    try {
      final response = await ApiClient.post(AppConstants.retryPayment(id), {});
      return response.data['data'];
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  Future<bool> createTicket(String subject, String description, {String? category, String? bookingId}) async {
    try {
      await ApiClient.post(AppConstants.meSupport, {
        'subject': subject,
        'description': description,
        'category': category,
        'bookingId': bookingId,
      });
      await fetchTickets();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> logoutAllDevices() async {
    try {
      await ApiClient.post(AppConstants.meLogoutAll, {});
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> removeFavorite(String id) async {
    try {
      await ApiClient.delete('${AppConstants.meFavorites}/$id');
      await fetchFavorites();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> markNotificationRead(String id) async {


    try {
      await ApiClient.patch('${AppConstants.meNotifications}/$id/read', {});
      await fetchNotifications();
      return true;
    } catch (e) {
      return false;
    }
  }
}
