import 'package:flutter/foundation.dart';
import 'package:mobile_app/core/api_client.dart';

class DashboardStats {
  final double earnings;
  final int completedJobs;
  final int pendingRequests;
  final int activeJobs;
  final double rating;
  final bool isOnline;

  DashboardStats({
    required this.earnings,
    required this.completedJobs,
    required this.pendingRequests,
    required this.activeJobs,
    required this.rating,
    required this.isOnline,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      earnings: (json['earnings'] as num?)?.toDouble() ?? 0.0,
      completedJobs: json['completedJobs'] ?? 0,
      pendingRequests: json['pendingRequests'] ?? 0,
      activeJobs: json['activeJobs'] ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      isOnline: json['isOnline'] ?? true,
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

  Future<void> fetchStats() async {
    _setLoading(true);
    _error = null;
    try {
      final response = await ApiClient.get('/api/provider/dashboard');
      if (response.statusCode == 200) {
        _stats = DashboardStats.fromJson(response.data['data']);
      }
    } catch (e) {
      _error = 'Failed to load dashboard: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Support for Online/Offline toggle (UI requirement)
  Future<void> toggleOnline() async {
    // Current profile update endpoint not yet tailored for boolean toggle, 
    // but we can prepare the provider state. 
    // We will assume 'providerProfile' update handles this or add endpoint later.
    if (_stats == null) return;
    
    _setLoading(true);
    try {
      // Placeholder for actual API call
      // await ApiClient.put('/provider/profile', {'isOnline': !_stats!.isOnline});
      await fetchStats(); 
    } catch (e) {
      _error = 'Failed to toggle status: $e';
    } finally {
      _setLoading(false);
    }
  }
}
