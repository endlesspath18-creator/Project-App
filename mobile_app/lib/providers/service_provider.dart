import 'package:flutter/material.dart';
import 'package:mobile_app/core/api_client.dart';
import 'package:mobile_app/core/constants.dart';
import 'package:mobile_app/data/service_model.dart';

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
  Future<void> fetchAllServices({String? category, String? query, bool force = false}) async {
    if (_isLoading) return;
    if (!force && _services.isNotEmpty && category == null && query == null) return;

    _setLoading(true);
    _error = null;
    try {
      final queryParams = <String, String>{};
      if (category != null && category != 'All') queryParams['category'] = category;
      if (query != null && query.isNotEmpty) queryParams['searchQuery'] = query;

      final uri = Uri(path: AppConstants.servicesEndpoint, queryParameters: queryParams.isNotEmpty ? queryParams : null).toString();
      
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
  Future<void> fetchProviderServices({bool force = false}) async {
    if (_isLoading) return;
    if (!force && _providerServices.isNotEmpty) return;

    _setLoading(true);
    _error = null;
    try {
      final response = await ApiClient.get(AppConstants.providerServicesEndpoint);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        _providerServices = data.map((s) => ServiceModel.fromJson(s as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      if (e.toString().contains('403')) {
        debugPrint('GUARD: Blocked unauthorized fetchProviderServices');
      } else {
        _error = 'Failed to load your services: $e';
      }
    } finally {
      _setLoading(false);
    }
  }

  final List<String> _favoriteIds = [];
  List<String> get favoriteIds => _favoriteIds;

  bool isFavorite(String serviceId) => _favoriteIds.contains(serviceId);

  void toggleFavorite(String serviceId) {
    if (_favoriteIds.contains(serviceId)) {
      _favoriteIds.remove(serviceId);
    } else {
      _favoriteIds.add(serviceId);
    }
    notifyListeners();
  }

  List<ServiceModel> get favoriteServices => _services.where((s) => _favoriteIds.contains(s.id)).toList();

  // ─── Add New Service ───────────────────────────────────────────────────────
  Future<bool> addService(ServiceModel service) async {
    _setLoading(true);
    debugPrint('ADD_SERVICE: Sending POST to ${AppConstants.servicesEndpoint}');
    try {
      final response = await ApiClient.post(AppConstants.servicesEndpoint, service.toJson());
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
