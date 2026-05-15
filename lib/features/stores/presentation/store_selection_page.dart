import 'package:flutter/material.dart';
import 'package:pdvmobile/features/stores/domain/entities/store_summary.dart';

class StoreSelectionPage extends StatelessWidget {
  const StoreSelectionPage({
    super.key,
    required this.stores,
    required this.onSelectStore,
  });

  final List<StoreSummary> stores;
  final ValueChanged<StoreSummary> onSelectStore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Selecionar loja')),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemBuilder: (context, index) {
          final store = stores[index];

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Modo de mesa: ${store.tableMode}'),
                  const SizedBox(height: 8),
                  Text(
                    store.isOpen ? 'Loja aberta' : 'Loja fechada',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => onSelectStore(store),
                      child: const Text('Entrar nesta loja'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, _) => const SizedBox(height: 16),
        itemCount: stores.length,
      ),
    );
  }
}
