class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.userName,
    required this.userEmail,
  });

  final String accessToken;
  final String userName;
  final String userEmail;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AuthSession &&
            runtimeType == other.runtimeType &&
            accessToken == other.accessToken &&
            userName == other.userName &&
            userEmail == other.userEmail;
  }

  @override
  int get hashCode => Object.hash(accessToken, userName, userEmail);
}
