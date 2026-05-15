import 'package:flutter/material.dart';
import 'package:pdvmobile/features/stores/domain/entities/store_summary.dart';
import 'package:pdvmobile/features/stores/domain/repositories/store_repository.dart';
import 'package:pdvmobile/features/stores/presentation/store_selection_page.dart';

class StoreSelectionGate extends StatefulWidget {
  const StoreSelectionGate({
    super.key,
    required this.storeRepository,
    required this.onStoreSelected,
  });

  final StoreRepository storeRepository;
  final Widget Function(BuildContext context, StoreSummary store)
  onStoreSelected;

  @override
  State<StoreSelectionGate> createState() => _StoreSelectionGateState();
}

class _StoreSelectionGateState extends State<StoreSelectionGate> {
  StoreSummary? _selectedStore;
  late final Future<_StoreBootstrapData> _bootstrapFuture;

  @override
  void initState() {
    super.initState();
    _bootstrapFuture = _loadStores();
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedStore != null) {
      return widget.onStoreSelected(context, _selectedStore!);
    }

    return FutureBuilder<_StoreBootstrapData>(
      future: _bootstrapFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data;
        if (data == null) {
          return const Scaffold(
            body: Center(child: Text('Nao foi possivel carregar as lojas')),
          );
        }

        if (data.selectedStore != null) {
          _selectedStore = data.selectedStore;
          return widget.onStoreSelected(context, data.selectedStore!);
        }

        return StoreSelectionPage(
          stores: data.stores,
          onSelectStore: (store) async {
            await widget.storeRepository.saveSelectedStoreId(store.id);
            if (!mounted) {
              return;
            }

            setState(() {
              _selectedStore = store;
            });
          },
        );
      },
    );
  }

  Future<_StoreBootstrapData> _loadStores() async {
    final selectedStoreId = await widget.storeRepository.readSelectedStoreId();
    final stores = await widget.storeRepository.listStores();

    StoreSummary? selectedStore;
    if (selectedStoreId != null) {
      for (final store in stores) {
        if (store.id == selectedStoreId) {
          selectedStore = store;
          break;
        }
      }
    }

    return _StoreBootstrapData(
      stores: stores,
      selectedStore: selectedStore,
    );
  }
}

class _StoreBootstrapData {
  const _StoreBootstrapData({
    required this.stores,
    required this.selectedStore,
  });

  final List<StoreSummary> stores;
  final StoreSummary? selectedStore;
}
