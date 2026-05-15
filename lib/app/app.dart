import 'package:flutter/material.dart';
import 'package:pdvmobile/app/theme/app_theme.dart';
import 'package:pdvmobile/core/env/app_config.dart';
import 'package:pdvmobile/features/auth/application/login_use_case.dart';
import 'package:pdvmobile/features/auth/application/restore_session_use_case.dart';
import 'package:pdvmobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:pdvmobile/features/auth/presentation/auth_gate.dart';
import 'package:pdvmobile/features/home/presentation/pdv_home_page.dart';

class PdvMobileApp extends StatelessWidget {
  const PdvMobileApp({
    super.key,
    required this.config,
    required this.authRepository,
  });

  final AppConfig config;
  final AuthRepository authRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: config.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: AuthGate(
        loginUseCase: LoginUseCase(authRepository),
        restoreSessionUseCase: RestoreSessionUseCase(authRepository),
        authenticatedBuilder: (context, session) => PdvHomePage(
          config: config,
          session: session,
        ),
      ),
    );
  }
}
