import 'package:flutter/foundation.dart';
import 'package:mobile_app/core/api_client.dart';

class DashboardStats {
  final double totalEarnings;
  final int completedJobs;
  final double todayEarnings;
  final List<dynamic> upcomingBookings;
  final List<dynamic> recentReviews;
  final bool isOnline;

  DashboardStats({
    required this.totalEarnings,
    required this.completedJobs,
    required this.todayEarnings,
    required this.upcomingBookings,
    required this.recentReviews,
    required this.isOnline,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    // Highly defensive parsing to prevent 'type Null is not a subtype of double'
    return DashboardStats(
      totalEarnings: double.tryParse(json['totalEarnings']?.toString() ?? '0') ?? 0.0,
      completedJobs: int.tryParse(json['completedJobs']?.toString() ?? '0') ?? 0,
      todayEarnings: double.tryParse(json['todayEarnings']?.toString() ?? '0') ?? 0.0,
      upcomingBookings: json['upcomingBookings'] as List? ?? [],
      recentReviews: json['recentReviews'] as List? ?? [],
      isOnline: json['isOnline'] == true,
    );
  }
}

class DashboardProvider with ChangeNotifier {
  DashboardStats? _stats;
  bool _isLoading = false;
  String? _error;

  DashboardStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchStats({bool force = false}) async {
    if (_isLoading) return;
    if (!force && _stats != null) return;

    _setLoading(true);
    _error = null;
    try {
      // Corrected endpoint path based on new backend structure
      // Prefixed with bookings to match app.use('/api/bookings', bookingRoutes)
      final response = await ApiClient.get('/bookings/provider/dashboard');
      if (response.statusCode == 200) {
        if (response.data['data'] != null) {
          _stats = DashboardStats.fromJson(response.data['data']);
        }
        notifyListeners();
      }
    } catch (e) {
      if (e.toString().contains('403')) {
        debugPrint('GUARD: Blocked unauthorized fetchStats');
      } else {
        _error = 'Failed to load dashboard: $e';
        debugPrint('Dashboard Error Detail: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleOnline() async {
    if (_stats == null) return;
    
    _setLoading(true);
    try {
      // Note: Backend profile availability toggle endpoint is /api/provider/availability
      await ApiClient.patch('/provider/availability', {});
      await fetchStats(force: true); 
    } catch (e) {
      _error = 'Failed to toggle status: $e';
    } finally {
      _setLoading(false);
    }
  }
}
