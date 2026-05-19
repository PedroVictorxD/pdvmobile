import 'package:flutter/material.dart';
import 'package:pdvmobile/app/theme/app_theme.dart';
import 'package:pdvmobile/core/env/app_config.dart';
import 'package:pdvmobile/features/auth/application/login_use_case.dart';
import 'package:pdvmobile/features/auth/application/restore_session_use_case.dart';
import 'package:pdvmobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:pdvmobile/features/auth/presentation/auth_gate.dart';
import 'package:pdvmobile/features/home/presentation/pdv_home_page.dart';
import 'package:pdvmobile/features/stores/domain/repositories/store_repository.dart';
import 'package:pdvmobile/features/stores/presentation/store_selection_gate.dart';
import 'package:pdvmobile/features/tables/domain/repositories/table_repository.dart';

class PdvMobileApp extends StatelessWidget {
  const PdvMobileApp({
    super.key,
    required this.config,
    required this.authRepository,
    required this.storeRepository,
    required this.tableRepository,
  });

  final AppConfig config;
  final AuthRepository authRepository;
  final StoreRepository storeRepository;
  final TableRepository tableRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: config.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: AuthGate(
        loginUseCase: LoginUseCase(authRepository),
        restoreSessionUseCase: RestoreSessionUseCase(authRepository),
        authenticatedBuilder: (context, session) => StoreSelectionGate(
          storeRepository: storeRepository,
          onStoreSelected: (context, store) => PdvHomePage(
            config: config,
            session: session,
            store: store,
            tableRepository: tableRepository,
          ),
        ),
      ),
    );
  }
}
