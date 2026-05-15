import 'package:pdvmobile/features/auth/domain/entities/auth_session.dart';

class AuthSessionModel extends AuthSession {
  const AuthSessionModel({
    required super.accessToken,
    required super.refreshToken,
    required super.userName,
    required super.userEmail,
    required super.role,
  });

  factory AuthSessionModel.fromLoginJson(Map<String, dynamic> json) {
    return AuthSessionModel(
      accessToken: json['token'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      userName: json['name'] as String? ?? '',
      userEmail: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
    );
  }

  factory AuthSessionModel.fromStorageMap(Map<String, dynamic> map) {
    return AuthSessionModel(
      accessToken: map['accessToken'] as String? ?? '',
      refreshToken: map['refreshToken'] as String? ?? '',
      userName: map['userName'] as String? ?? '',
      userEmail: map['userEmail'] as String? ?? '',
      role: map['role'] as String? ?? '',
    );
  }

  Map<String, dynamic> toStorageMap() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'userName': userName,
      'userEmail': userEmail,
      'role': role,
    };
  }
}
