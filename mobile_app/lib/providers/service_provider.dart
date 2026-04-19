import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../data/service_model.dart';

class ServiceProvider extends ChangeNotifier {
  List<ServiceModel> _services = [];
  List<ServiceModel> _providerServices = [];
  bool _isLoading = false;
  String? _error;

  List<ServiceModel> get services => _services;
  List<ServiceModel> get providerServices => _providerServices;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // ─── Fetch All Services (Marketplace) ──────────────────────────────────────
  Future<void> fetchAllServices({String? category, String? query}) async {
    _setLoading(true);
    _error = null;
    try {
      final queryParams = <String, String>{};
      if (category != null && category != 'All') queryParams['category'] = category;
      if (query != null && query.isNotEmpty) queryParams['searchQuery'] = query;

      final uri = Uri(path: '/services', queryParameters: queryParams.isNotEmpty ? queryParams : null).toString();
      
      final response = await ApiClient.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        _services = data.map((s) => ServiceModel.fromJson(s as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      _error = 'Failed to load services: $e';
    } finally {
      _setLoading(false);
    }
  }

  // ─── Fetch Provider specific services ──────────────────────────────────────
  Future<void> fetchProviderServices() async {
    _setLoading(true);
    _error = null;
    try {
      final response = await ApiClient.get('/services/my-services');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        _providerServices = data.map((s) => ServiceModel.fromJson(s as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      _error = 'Failed to load your services: $e';
    } finally {
      _setLoading(false);
    }
  }

  // ─── Add New Service ───────────────────────────────────────────────────────
  Future<bool> addService(ServiceModel service) async {
    _setLoading(true);
    try {
      final response = await ApiClient.post('/services', service.toJson());
      if (response.statusCode == 201) {
        await fetchProviderServices(); // Refresh local provider list
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error adding service: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
