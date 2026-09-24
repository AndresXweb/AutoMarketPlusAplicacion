import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/vehicle.dart';
import '../../../shared/widgets/vehicle_card.dart';
import '../catalog_repository.dart';

final catalogQueryProvider = StateProvider<String>((ref) => '');

final catalogListProvider = FutureProvider.autoDispose<List<Vehicle>>((ref) {
  final q = ref.watch(catalogQueryProvider);
  return ref.watch(catalogRepositoryProvider).listVehicles(q: q);
});

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(catalogListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Catálogo')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText: 'Buscar marca, línea, ciudad…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _search.clear();
                    ref.read(catalogQueryProvider.notifier).state = '';
                  },
                ),
              ),
              onSubmitted: (v) {
                ref.read(catalogQueryProvider.notifier).state = v.trim();
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(catalogListProvider),
              child: list.when(
                data: (items) {
                  if (items.isEmpty) {
                    return ListView(
                      children: const [
                        SizedBox(height: 80),
                        Center(child: Text('Sin resultados', style: TextStyle(color: AppColors.muted))),
                      ],
                    );
                  }
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final v = items[i];
                      return VehicleCard(
                        vehicle: v,
                        onTap: () => context.push('/vehicle/${v.id}'),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('$e', style: const TextStyle(color: AppColors.danger)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
