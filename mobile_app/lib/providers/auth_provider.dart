
import 'package:flutter/material.dart';
import 'package:mobile_app/core/api_client.dart';
import 'package:mobile_app/core/constants.dart';
import 'package:mobile_app/core/storage_service.dart';
import 'package:mobile_app/data/user_model.dart';
import 'package:mobile_app/data/auth_response_model.dart';

class AuthProvider extends ChangeNotifier {
  final bool isFirebaseAvailable;
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  AuthProvider({this.isFirebaseAvailable = false});

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isProvider => _user?.role == 'PROVIDER';


  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  // ─── Session Check ─────────────────────────────────────────────────────────
  Future<bool> checkAuthStatus() async {
    _setLoading(true);
    _setError(null);
    try {
      final token = await StorageService.getToken();
      if (token == null || token.isEmpty) {
        _setLoading(false);
        return false;
      }

      final response = await ApiClient.get(AppConstants.verifyMeEndpoint);
      Map<String, dynamic> rawUser;
      if (response.data['data'] != null && response.data['data'] is Map<String, dynamic>) {
        rawUser = response.data['data'] as Map<String, dynamic>;
      } else {
        rawUser = response.data['user'] ?? response.data;
      }
      debugPrint('SESSION_RESTORE: Received raw user data: $rawUser');
      
      _user = UserModel.fromJson(rawUser);
      debugPrint('SESSION_RESTORE: Parsed user. isRoleSet: ${_user?.isRoleSet}');
      
      _setLoading(false);
      return true;
    } on UnauthorizedException {
      await StorageService.deleteToken();
      _setLoading(false);
      return false;
    } on ApiException catch (e) {
      // Do NOT delete token on generic network/server errors (500, 502, etc.)
      // returning false will still go to login/welcome, but token stays for retry.
      _setError(e.message);
      _setLoading(false);
      return false;
    }
  }

  // ─── Login ─────────────────────────────────────────────────────────────────
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await ApiClient.post(AppConstants.loginEndpoint, {
        'email': email,
        'password': password,
      });

      final authResponse = AuthResponse.fromJson(response.data);
      if (authResponse.token != null) {
        await StorageService.saveToken(authResponse.token!);
        _user = authResponse.user;
        _setLoading(false);
        return true;
      }

      _setError('Login failed: no token received from server.');
      _setLoading(false);
      return false;
    } on ApiException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    }
  }

  // ─── Register ──────────────────────────────────────────────────────────────
  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
    String? businessName,
    String? phone,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final body = <String, String>{
        'fullName': fullName,
        'email': email,
        'password': password,
        'role': role,
      };
      if (phone != null && phone.isNotEmpty) body['phone'] = phone;
      if (businessName != null && businessName.isNotEmpty) body['businessName'] = businessName;

      final response = await ApiClient.post(AppConstants.registerEndpoint, body);
      final authResponse = AuthResponse.fromJson(response.data);

      if (authResponse.token != null) {
        await StorageService.saveToken(authResponse.token!);
        _user = authResponse.user;
      }
      _setLoading(false);
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    }
  }


  // ─── Logout ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    await StorageService.deleteToken();
    _user = null;
    _error = null;
    notifyListeners();
  }
}

