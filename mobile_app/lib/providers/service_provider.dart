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
  Future<void> fetchAllServices() async {
    _setLoading(true);
    _error = null;
    try {
      final response = await ApiClient.get('/api/services');
      if (response.isSuccess) {
        final List<dynamic> data = response.data['services'] ?? [];
        _services = data.map((s) => ServiceModel.fromJson(s as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching services: $e. Using mock data.');
      // MOCK FALLBACK
      _services = _getMockServices();
    } finally {
      _setLoading(false);
    }
  }

  // ─── Fetch Provider specific services ──────────────────────────────────────
  Future<void> fetchProviderServices() async {
    _setLoading(true);
    _error = null;
    try {
      final response = await ApiClient.get('/api/services/my-services');
      if (response.isSuccess) {
        final List<dynamic> data = response.data['services'] ?? [];
        _providerServices = data.map((s) => ServiceModel.fromJson(s as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching provider services: $e.');
      _providerServices = _services.where((s) => s.providerId == 'mock-id').toList();
    } finally {
      _setLoading(false);
    }
  }

  // ─── Add New Service ───────────────────────────────────────────────────────
  Future<bool> addService(ServiceModel service) async {
    _setLoading(true);
    try {
      final response = await ApiClient.post('/api/services', service.toJson());
      if (response.isSuccess) {
        await fetchAllServices(); // Refresh local list
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error adding service: $e. Simulating local success.');
      // Simulate local success for demo if backend is missing
      _services.insert(0, service);
      _providerServices.insert(0, service);
      notifyListeners();
      return true;
    } finally {
      _setLoading(false);
    }
  }

  List<ServiceModel> _getMockServices() {
    return [
      ServiceModel(
        id: '1',
        title: 'Premium AC Deep Clean',
        category: 'AC Repair',
        description: 'Full jet wash and gas check for optimum cooling.',
        price: 1499,
        duration: '2 Hours',
        providerId: 'p1',
        providerName: 'Cooling Masters',
      ),
      ServiceModel(
        id: '2',
        title: 'Full Home Sanitization',
        category: 'Cleaning',
        description: 'Hospital-grade sanitization for your entire home.',
        price: 2999,
        duration: '4 Hours',
        providerId: 'p2',
        providerName: 'Cleanly Pro',
      ),
      ServiceModel(
        id: '3',
        title: 'Bathroom Leakage Fix',
        category: 'Plumbing',
        description: 'Professional fix for all your plumbing issues.',
        price: 499,
        duration: '1 Hour',
        providerId: 'p3',
        providerName: 'Relay Plumbers',
      ),
      ServiceModel(
        id: '4',
        title: 'Emergency Wiring Repair',
        category: 'Electrical',
        description: 'Complete inspection and fix of faulty wiring.',
        price: 899,
        duration: '1.5 Hours',
        providerId: 'p4',
        providerName: 'Sparky Experts',
      ),
    ];
  }
}
