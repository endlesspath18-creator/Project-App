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
  bool _isInitialized = false;
  String? _error;

  AuthProvider({this.isFirebaseAvailable = false});

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isProvider => _user?.role == 'PROVIDER';
  bool get isAdmin => _user?.role == 'ADMIN';

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  // ─── Session Check ─────────────────────────────────────────────────────────
  Future<void> checkAuthStatus() async {
    _setError(null);
    try {
      final token = await StorageService.getToken();
      if (token == null || token.isEmpty) {
        _isInitialized = true;
        notifyListeners();
        return;
      }

      final response = await ApiClient.get(AppConstants.verifyMeEndpoint);
      Map<String, dynamic> rawUser;
      if (response.data['data'] != null && response.data['data'] is Map<String, dynamic>) {
        rawUser = response.data['data'] as Map<String, dynamic>;
      } else {
        rawUser = response.data['user'] ?? response.data;
      }
      
      _user = UserModel.fromJson(rawUser);
    } catch (e) {
      debugPrint('AUTH_CHECK_ERROR: $e');
      if (e is UnauthorizedException) {
        await StorageService.deleteTokens();
      }
    } finally {
      _isInitialized = true;
      notifyListeners();
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
        if (authResponse.refreshToken != null) {
          await StorageService.saveRefreshToken(authResponse.refreshToken!);
        }
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
  Future<Map<String, dynamic>?> register({
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
      _setLoading(false);
      
      // Return the data which might contain debug OTP
      return response.data['data'];
    } on ApiException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return null;
    }
  }

  // ─── Verify OTP ────────────────────────────────────────────────────────────
  Future<bool> verifyOtp(String email, String otp) async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await ApiClient.post(AppConstants.verifyOtpEndpoint, {
        'email': email,
        'otp': otp,
      });

      final authResponse = AuthResponse.fromJson(response.data);
      if (authResponse.token != null) {
        await StorageService.saveToken(authResponse.token!);
        if (authResponse.refreshToken != null) {
          await StorageService.saveRefreshToken(authResponse.refreshToken!);
        }
        _user = authResponse.user;
        _setLoading(false);
        return true;
      }

      _setError('Verification failed: no token received.');
      _setLoading(false);
      return false;
    } on ApiException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    }
  }

  // ─── Refresh User Data ──────────────────────────────────────────────────
  Future<void> refreshUser() async {
    try {
      final response = await ApiClient.get(AppConstants.verifyMeEndpoint);
      Map<String, dynamic> rawUser;
      if (response.data['data'] != null && response.data['data'] is Map<String, dynamic>) {
        rawUser = response.data['data'] as Map<String, dynamic>;
      } else {
        rawUser = response.data['user'] ?? response.data;
      }
      _user = UserModel.fromJson(rawUser);
      notifyListeners();
    } catch (e) {
      debugPrint('REFRESH_USER_ERROR: $e');
    }
  }

  // ─── Toggle Availability (Provider) ─────────────────────────────────────────
  Future<bool> toggleAvailability() async {
    try {
      final response = await ApiClient.patch('/provider/availability', {});
      if (response.statusCode == 200) {
        await refreshUser();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('TOGGLE_AVAILABILITY_ERROR: $e');
      return false;
    }
  }

  // ─── Update Profile (Generic) ──────────────────────────────────────────────
  Future<bool> updateProfile({String? fullName, String? phone, String? businessName}) async {
    _setLoading(true);
    try {
      if (fullName != null || phone != null) {
        await ApiClient.patch(AppConstants.meProfile, {
          'fullName': fullName,
          'phone': phone,
        });
      }

      if (isProvider && businessName != null) {
        await ApiClient.patch('/provider/profile', {
          'businessName': businessName,
        });
      }

      await refreshUser();
      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint('UPDATE_PROFILE_ERROR: $e');
      _setError('Failed to update profile');
      _setLoading(false);
      return false;
    }
  }

  // ─── Logout ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      final refreshToken = await StorageService.getRefreshToken();
      await ApiClient.post(AppConstants.logoutEndpoint, {
        'refreshToken': refreshToken,
      });
    } catch (e) {
      debugPrint('SERVER_LOGOUT_ERROR: $e');
    } finally {
      await StorageService.deleteTokens();
      _user = null;
      _error = null;
      notifyListeners();
    }
  }
}
