import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'storage_service.dart';

// ─── Typed API Exceptions ──────────────────────────────────────────────────
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  const ApiException(this.message, {this.statusCode});
  @override
  String toString() => 'ApiException($statusCode): $message';
}

class NoInternetException extends ApiException {
  const NoInternetException() : super('No internet connection. Please check your network.');
}

class TimeoutException extends ApiException {
  const TimeoutException() : super('Request timed out. Please try again.');
}

class ServerException extends ApiException {
  const ServerException(super.message, {super.statusCode});
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException() : super('Session expired. Please log in again.', statusCode: 401);
}

// ─── API Client ─────────────────────────────────────────────────────────────
class ApiClient {
  static const Duration _timeout = Duration(seconds: 30);
  static const int _maxRetries = 2;

  // Print only in debug mode — never in release APK
  static void _log(String message) {
    if (kDebugMode) {
      debugPrint('[ApiClient] $message');
    }
  }

  static Future<Map<String, String>> _buildHeaders(String endpoint) async {
    final token = await StorageService.getToken();
    
    // Do not send Authorization header for public auth routes to avoid session collisions.
    final bool isPublicAuthRoute = endpoint.contains('/auth/login') || 
                                    endpoint.contains('/auth/register') || 
                                    endpoint.contains('/auth/google');

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && !isPublicAuthRoute) 'Authorization': 'Bearer $token',
    };
  }

  /// Classifies raw exceptions into typed [ApiException] subclasses.
  static ApiException _classify(Object e) {
    if (e is SocketException) return const NoInternetException();
    if (e is http.ClientException) return const NoInternetException();
    if (e is TimeoutException) return const TimeoutException();
    if (e is ApiException) return e;
    return ApiException('Unexpected error: $e');
  }

  /// Maps HTTP status codes to typed exceptions.
  static ApiException? _fromStatus(int code, Map<String, dynamic> body) {
    final msg = body['message'] as String? ?? body['error'] as String? ?? 'Unknown error';
    switch (code) {
      case 401: return const UnauthorizedException();
      case 403: return ApiException('Access denied.', statusCode: 403);
      case 404: return ApiException('Resource not found.', statusCode: 404);
      case 422: return ApiException(msg, statusCode: 422);
      case 429: return ApiException('Too many requests. Slow down.', statusCode: 429);
      case 500:
      case 502:
      case 503: return ServerException('Server error ($code). Please try again shortly.', statusCode: code);
      default: return null;
    }
  }

  /// Executes [request] with timeout + retry for 502/503 (Render cold start).
  static Future<http.Response> _executeWithRetry(
    Future<http.Response> Function() request, {
    int retries = _maxRetries,
  }) async {
    for (int attempt = 0; attempt <= retries; attempt++) {
      try {
        final response = await request().timeout(_timeout);
        // Retry on Render cold start codes
        if ((response.statusCode == 502 || response.statusCode == 503) && attempt < retries) {
          _log('Server returned ${response.statusCode}. Retrying (${attempt + 1}/$retries)...');
          await Future.delayed(Duration(seconds: 3 * (attempt + 1)));
          continue;
        }
        return response;
      } on SocketException {
        if (attempt == retries) throw const NoInternetException();
        await Future.delayed(const Duration(seconds: 2));
      } on http.ClientException {
        if (attempt == retries) throw const NoInternetException();
        await Future.delayed(const Duration(seconds: 2));
      } catch (e) {
        throw _classify(e);
      }
    }
    // Unreachable but satisfies compiler
    throw const TimeoutException();
  }

  // ─── Public Methods ────────────────────────────────────────────────────────

  static Future<ApiResponse> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
    _log('POST $url');
    try {
      final headers = await _buildHeaders(endpoint);
      final response = await _executeWithRetry(
        () => http.post(url, headers: headers, body: jsonEncode(body)),
      );
      return _parseResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw _classify(e);
    }
  }

  static Future<ApiResponse> get(String endpoint) async {
    final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
    _log('GET $url');
    try {
      final headers = await _buildHeaders(endpoint);
      final response = await _executeWithRetry(
        () => http.get(url, headers: headers),
      );
      return _parseResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw _classify(e);
    }
  }

  static Future<ApiResponse> patch(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
    _log('PATCH $url');
    try {
      final headers = await _buildHeaders(endpoint);
      final response = await _executeWithRetry(
        () => http.patch(url, headers: headers, body: jsonEncode(body)),
      );
      return _parseResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw _classify(e);
    }
  }

  static ApiResponse _parseResponse(http.Response response) {
    _log('Response ${response.statusCode}: ${response.body.length} bytes');
    late Map<String, dynamic> data;
    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw ServerException('Invalid response from server.', statusCode: response.statusCode);
    }

    final error = _fromStatus(response.statusCode, data);
    if (error != null) throw error;

    return ApiResponse(statusCode: response.statusCode, data: data);
  }
}

// ─── Response Wrapper ────────────────────────────────────────────────────────
class ApiResponse {
  final int statusCode;
  final Map<String, dynamic> data;
  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  const ApiResponse({required this.statusCode, required this.data});
}
