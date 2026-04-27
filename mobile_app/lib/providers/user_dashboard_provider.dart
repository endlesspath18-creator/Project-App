import 'package:flutter/foundation.dart';
import 'package:mobile_app/core/api_client.dart';

class UserDashboardStats {
  final List<dynamic> activeBookings;
  final int completedCount;
  final double totalSpent;
  final dynamic nextJob;

  UserDashboardStats({
    required this.activeBookings,
    required this.completedCount,
    required this.totalSpent,
    this.nextJob,
  });

  factory UserDashboardStats.fromJson(Map<String, dynamic> json) {
    return UserDashboardStats(
      activeBookings: json['activeBookings'] ?? [],
      completedCount: json['completedCount'] ?? 0,
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
      nextJob: json['nextJob'],
    );
  }
}

class UserDashboardProvider with ChangeNotifier {
  UserDashboardStats? _stats;
  List<dynamic> _banners = [];
  List<dynamic> _topProviders = [];
  bool _isLoading = false;
  String? _error;

  UserDashboardStats? get stats => _stats;
  List<dynamic> get banners => _banners;
  List<dynamic> get topProviders => _topProviders;
  bool get isLoading => _isLoading;
  String? get error => _error;


  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchDashboard({bool force = false}) async {
    if (_isLoading) return;
    if (!force && _stats != null) return;

    _setLoading(true);
    _error = null;
    try {
      // Fetch stats
      final statsResponse = await ApiClient.get('/bookings/user/dashboard');
      if (statsResponse.statusCode == 200) {
        _stats = UserDashboardStats.fromJson(statsResponse.data['data']);
      }

      // Fetch Banners (Scrolling pics)
      final bannersResponse = await ApiClient.get('/public/banners');
      if (bannersResponse.statusCode == 200) {
        _banners = bannersResponse.data['data'] ?? [];
      }

      // Fetch Top Providers
      final topProvidersResponse = await ApiClient.get('/public/top-providers');
      if (topProvidersResponse.statusCode == 200) {
        _topProviders = topProvidersResponse.data['data'] ?? [];
      }

      notifyListeners();

    } catch (e) {
      _error = 'Failed to load user dashboard: $e';
      debugPrint('User Dashboard Error: $e');
    } finally {
      _setLoading(false);
    }
  }
}
