import 'package:flutter/material.dart';
import 'package:pdvmobile/features/auth/application/login_use_case.dart';
import 'package:pdvmobile/features/auth/application/restore_session_use_case.dart';
import 'package:pdvmobile/features/auth/domain/entities/auth_session.dart';
import 'package:pdvmobile/features/auth/presentation/login_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({
    super.key,
    required this.loginUseCase,
    required this.restoreSessionUseCase,
    required this.authenticatedBuilder,
  });

  final LoginUseCase loginUseCase;
  final RestoreSessionUseCase restoreSessionUseCase;
  final Widget Function(BuildContext context, AuthSession session)
  authenticatedBuilder;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  AuthSession? _session;
  late final Future<AuthSession?> _restoreSessionFuture;

  @override
  void initState() {
    super.initState();
    _restoreSessionFuture = widget.restoreSessionUseCase();
  }

  @override
  Widget build(BuildContext context) {
    if (_session != null) {
      return widget.authenticatedBuilder(context, _session!);
    }

    return FutureBuilder<AuthSession?>(
      future: _restoreSessionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final restoredSession = snapshot.data;
        if (restoredSession != null) {
          _session = restoredSession;
          return widget.authenticatedBuilder(context, restoredSession);
        }

        return LoginPage(
          loginUseCase: widget.loginUseCase,
          onLoginSuccess: (session) {
            setState(() {
              _session = session;
            });
          },
        );
      },
    );
  }
}
