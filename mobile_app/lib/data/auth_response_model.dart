import 'user_model.dart';

class AuthResponse {
  final UserModel? user;
  final String? token;
  final String? message;
  final bool success;

  AuthResponse({
    this.user,
    this.token,
    this.message,
    required this.success,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Extract token from possible locations in the response.
    String? extractedToken;
    if (json['token'] != null) {
      extractedToken = json['token'] as String?;
    } else if (json['accessToken'] != null) {
      extractedToken = json['accessToken'] as String?;
    } else if (json['data'] != null && json['data'] is Map<String, dynamic>) {
      final dataMap = json['data'] as Map<String, dynamic>;
      extractedToken = dataMap['token'] ?? dataMap['accessToken'];
    }

    // Extract user from possible locations in the response.
    UserModel? extractedUser;
    if (json['user'] != null) {
      extractedUser = UserModel.fromJson(json['user']);
    } else if (json['data'] != null && json['data'] is Map<String, dynamic>) {
      final dataMap = json['data'] as Map<String, dynamic>;
      if (dataMap['user'] != null) {
        extractedUser = UserModel.fromJson(dataMap['user']);
      }
    }

    return AuthResponse(
      user: extractedUser,
      token: extractedToken,
      message: json['message'],
      success: json['success'] ?? (extractedToken != null),
    );
  }
}
