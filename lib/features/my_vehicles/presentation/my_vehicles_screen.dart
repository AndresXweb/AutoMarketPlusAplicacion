import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/format.dart';
import '../../../shared/models/vehicle.dart';
import '../../profile/profile_repository.dart';

final myVehiclesProvider = FutureProvider.autoDispose<List<Vehicle>>((ref) {
  return ref.watch(profileRepositoryProvider).myVehicles();
});

class MyVehiclesScreen extends ConsumerWidget {
  const MyVehiclesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(myVehiclesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis anuncios')),
      body: async.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No tienes anuncios', style: TextStyle(color: AppColors.muted)));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myVehiclesProvider),
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (_, i) {
                final v = list[i];
                return ListTile(
                  title: Text(v.title),
                  subtitle: Text('${formatMoney(v.price)} · ${v.status}'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (action) async {
                      final repo = ref.read(profileRepositoryProvider);
                      try {
                        if (action == 'delete') {
                          await repo.deleteVehicle(v.id);
                        } else {
                          await repo.updateVehicleStatus(v.id, action);
                        }
                        ref.invalidate(myVehiclesProvider);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                        }
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'activo', child: Text('Activar')),
                      PopupMenuItem(value: 'pausado', child: Text('Pausar')),
                      PopupMenuItem(value: 'vendido', child: Text('Vendido')),
                      PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                    ],
                  ),
                  onTap: () => context.push('/vehicle/${v.id}'),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e', style: const TextStyle(color: AppColors.danger))),
      ),
    );
  }
}
