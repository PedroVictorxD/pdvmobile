import 'package:flutter/widgets.dart';
import 'package:pdvmobile/app/app.dart';
import 'package:pdvmobile/core/env/app_config.dart';
import 'package:pdvmobile/features/auth/data/repositories/demo_auth_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final config = AppConfig.fromEnvironment();
  runApp(
    PdvMobileApp(
      config: config,
      authRepository: DemoAuthRepository(),
    ),
  );
}
