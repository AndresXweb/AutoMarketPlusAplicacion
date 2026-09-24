import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/vehicle.dart';
import '../../../shared/widgets/vehicle_card.dart';
import '../../catalog/catalog_repository.dart';

final featuredProvider = FutureProvider<List<Vehicle>>((ref) {
  return ref.watch(catalogRepositoryProvider).featured();
});

final statsProvider = FutureProvider<Map<String, dynamic>>((ref) {
  return ref.watch(catalogRepositoryProvider).stats();
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featured = ref.watch(featuredProvider);
    final stats = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AutoMarket'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.go('/catalog'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(featuredProvider);
          ref.invalidate(statsProvider);
        },
        child: ListView(
          children: [
            stats.when(
              data: (s) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    _stat('Activos', '${s['active'] ?? 0}'),
                    _stat('Venta', '${s['sale'] ?? 0}'),
                    _stat('Permuta', '${s['swap'] ?? 0}'),
                    _stat('Ciudades', '${s['cities'] ?? 0}'),
                  ],
                ),
              ),
              loading: () => const SizedBox(height: 48),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                'Destacados',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
            featured.when(
              data: (list) {
                if (list.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('No hay anuncios activos aún.', style: TextStyle(color: AppColors.muted)),
                  );
                }
                return Column(
                  children: list
                      .map(
                        (v) => VehicleCard(
                          vehicle: v,
                          onTap: () => context.push('/vehicle/${v.id}'),
                        ),
                      )
                      .toList(),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Error al cargar: $e\n\nRevisa api_config.dart y que el backend esté en marcha.',
                  style: const TextStyle(color: AppColors.danger),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.gold, fontSize: 18)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
