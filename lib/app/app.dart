import 'package:flutter/material.dart';
import 'package:pdvmobile/app/theme/app_theme.dart';
import 'package:pdvmobile/core/env/app_config.dart';
import 'package:pdvmobile/features/home/presentation/pdv_home_page.dart';

class PdvMobileApp extends StatelessWidget {
  const PdvMobileApp({super.key, required this.config});

  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: config.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: PdvHomePage(config: config),
    );
  }
}
