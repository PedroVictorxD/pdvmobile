class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.userName,
    required this.userEmail,
    required this.role,
  });

  final String accessToken;
  final String refreshToken;
  final String userName;
  final String userEmail;
  final String role;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AuthSession &&
            runtimeType == other.runtimeType &&
            accessToken == other.accessToken &&
            refreshToken == other.refreshToken &&
            userName == other.userName &&
            userEmail == other.userEmail &&
            role == other.role;
  }

  @override
  int get hashCode => Object.hash(
    accessToken,
    refreshToken,
    userName,
    userEmail,
    role,
  );
}
