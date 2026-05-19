import 'package:flutter/material.dart';
import 'package:pdvmobile/core/env/app_config.dart';
import 'package:pdvmobile/features/auth/domain/entities/auth_session.dart';
import 'package:pdvmobile/features/stores/domain/entities/store_summary.dart';
import 'package:pdvmobile/features/tables/domain/repositories/table_repository.dart';
import 'package:pdvmobile/features/tables/presentation/tables_dashboard_page.dart';

class PdvHomePage extends StatelessWidget {
  const PdvHomePage({
    super.key,
    required this.config,
    required this.session,
    required this.store,
    required this.tableRepository,
  });

  final AppConfig config;
  final AuthSession session;
  final StoreSummary store;
  final TableRepository tableRepository;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TablesDashboardPage(
      session: session,
      store: store,
      tableRepository: tableRepository,
      environmentBadge: config.isProduction
          ? null
          : DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Text(
                  key: const Key('environment-badge'),
                  config.environmentLabel,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
    );
  }
}
