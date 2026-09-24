import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/format.dart';
import '../../profile/profile_repository.dart';

final offersProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) {
  return ref.watch(profileRepositoryProvider).offers();
});

class OffersScreen extends ConsumerWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(offersProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ofertas'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Enviadas'),
              Tab(text: 'Recibidas'),
            ],
          ),
        ),
        body: async.when(
          data: (data) {
            final sent = (data['sent'] as List? ?? []);
            final received = (data['received'] as List? ?? []);
            return TabBarView(
              children: [
                _list(context, ref, sent, isReceived: false),
                _list(context, ref, received, isReceived: true),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
        ),
      ),
    );
  }

  Widget _list(BuildContext context, WidgetRef ref, List items, {required bool isReceived}) {
    if (items.isEmpty) {
      return const Center(child: Text('No hay ofertas', style: TextStyle(color: AppColors.muted)));
    }
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (_, i) {
        final o = Map<String, dynamic>.from(items[i] as Map);
        final title = (o['vehicleTitle'] ?? 'Vehículo').toString();
        final status = (o['status'] ?? '').toString();
        final amount = o['amount'];
        final id = o['id'] is int ? o['id'] as int : int.tryParse('${o['id']}') ?? 0;

        return ListTile(
          title: Text(title),
          subtitle: Text(
            '$status${amount != null ? ' · ${formatMoney(amount is num ? amount : num.tryParse('$amount') ?? 0)}' : ''}',
          ),
          trailing: isReceived && (status == 'pendiente' || status == 'contraoferta')
              ? PopupMenuButton<String>(
                  onSelected: (action) async {
                    try {
                      await ref.read(profileRepositoryProvider).respondOffer(id, action);
                      ref.invalidate(offersProvider);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                      }
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'aceptada', child: Text('Aceptar')),
                    PopupMenuItem(value: 'rechazada', child: Text('Rechazar')),
                  ],
                )
              : null,
        );
      },
    );
  }
}
