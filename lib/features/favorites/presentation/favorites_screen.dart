import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/vehicle.dart';
import '../../../shared/widgets/vehicle_card.dart';
import '../../profile/profile_repository.dart';

final favoritesProvider = FutureProvider.autoDispose<List<Vehicle>>((ref) {
  return ref.watch(profileRepositoryProvider).favorites();
});

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: async.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('Sin favoritos', style: TextStyle(color: AppColors.muted)));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(favoritesProvider),
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (_, i) {
                final v = list[i];
                return VehicleCard(
                  vehicle: v,
                  onTap: () => context.push('/vehicle/${v.id}'),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}
