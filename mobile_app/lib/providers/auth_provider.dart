import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../core/constants.dart';
import '../core/storage_service.dart';
import '../data/user_model.dart';
import '../data/auth_response_model.dart';

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

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Lazily initialize FirebaseAuth only if it's available and needed.
  firebase_auth.FirebaseAuth? get _auth {
    if (!isFirebaseAvailable) return null;
    try {
      return firebase_auth.FirebaseAuth.instance;
    } catch (e) {
      debugPrint('Error accessing FirebaseAuth: $e');
      return null;
    }
  }

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
      final rawUser = response.data['user'] ?? response.data;
      _user = UserModel.fromJson(rawUser as Map<String, dynamic>);
      _setLoading(false);
      return true;
    } on UnauthorizedException {
      await StorageService.deleteToken();
      _setLoading(false);
      return false;
    } on ApiException catch (e) {
      await StorageService.deleteToken();
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

  // ─── Google Sign-In ────────────────────────────────────────────────────────
  Future<bool> signInWithGoogle() async {
    debugPrint('STEP 0: Clearing any stale sessions and forcing account chooser');
    try {
      await _googleSignIn.signOut();
      await _googleSignIn.disconnect();
    } catch (e) {
      debugPrint('STEP 0b: No previous session to disconnect: $e');
    }
    await StorageService.deleteToken();
    
    debugPrint('STEP 1: Google login started');
    _setLoading(true);
    _setError(null);

    try {
      // 1. Trigger Google Sign-In Flow
      debugPrint('STEP 2: Opening Google account picker (Forcing chooser)');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint('STEP 2b: User cancelled account selection');
        _setLoading(false);
        return false;
      }
      debugPrint('STEP 3: Account selected: ${googleUser.email}');

      // 2. Get Google Auth Credentials (ID Token)
      debugPrint('STEP 4: Fetching authentication tokens');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        debugPrint('STEP 4b: Failed to retrieve ID Token');
        _setError('Could not retrieve Google ID Token.');
        _setLoading(false);
        return false;
      }
      debugPrint('STEP 5: ID Token retrieved successfully');

      // 3. Send ID Token to Backend
      debugPrint('STEP 6: Sending ID Token to backend: ${AppConstants.googleLoginEndpoint}');
      final response = await ApiClient.post(AppConstants.googleLoginEndpoint, {
        'idToken': idToken,
      });
      debugPrint('STEP 7: Backend response received: ${response.statusCode}');

      final authResponse = AuthResponse.fromJson(response.data);
      if (authResponse.token != null) {
        debugPrint('STEP 8: backend JWT received, saving session');
        await StorageService.saveToken(authResponse.token!);
        _user = authResponse.user;
        
        debugPrint('STEP 9: User state updated. User exist: ${_user != null}, isRoleSet: ${_user?.isRoleSet}');
        _setLoading(false);
        
        // Return true only if user is fully logged in and role is set
        return _user != null && _user!.isRoleSet;
      }

      debugPrint('STEP 8b: Backend login failed - no token');
      _setError('Google login failed: no token received from server.');
      _setLoading(false);
      return false;
    } catch (e) {
      debugPrint('STEP ERROR: Google Sign-In Error: $e');
      _setError('An error occurred during Google Sign-In: $e');
      _setLoading(false);
      return false;
    }
  }

  // ─── Complete Social Signup ────────────────────────────────────────────────
  Future<bool> completeSocialSignup({
    required String role,
    String? businessName,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final body = {
        'role': role,
        'businessName': businessName,
      };

      final response = await ApiClient.post(AppConstants.socialSignupEndpoint, body);
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
    try {
      await _googleSignIn.signOut();
      if (isFirebaseAvailable && _auth != null) {
        await _auth!.signOut();
      }
    } catch (e) {
      debugPrint('Error during sign out: $e');
    }
    
    await StorageService.deleteToken();
    _user = null;
    _error = null;
    notifyListeners();
  }
}

