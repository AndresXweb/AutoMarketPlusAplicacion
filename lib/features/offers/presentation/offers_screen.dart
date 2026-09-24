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
                _OfferList(items: sent, isReceived: false),
                _OfferList(items: received, isReceived: true),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
        ),
      ),
    );
  }
}

class _OfferList extends ConsumerWidget {
  const _OfferList({required this.items, required this.isReceived});
  final List items;
  final bool isReceived;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return const Center(
        child: Text('No hay ofertas', style: TextStyle(color: AppColors.muted)),
      );
    }
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (_, i) {
        final o = Map<String, dynamic>.from(items[i] as Map);
        final title = (o['vehicleTitle'] ?? 'Vehículo').toString();
        final status = (o['status'] ?? '').toString();
        final amount = o['amount'];
        final id = o['id'] is int ? o['id'] as int : int.tryParse('${o['id']}') ?? 0;
        final open = status == 'pendiente' || status == 'contraoferta';

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            title: Text(title),
            subtitle: Text(
              '$status${amount != null ? ' · ${formatMoney(amount is num ? amount : num.tryParse('$amount') ?? 0)}' : ''}',
            ),
            trailing: open
                ? PopupMenuButton<String>(
                    onSelected: (action) async {
                      if (action == 'contraoferta') {
                        final result = await _counterDialog(context);
                        if (result == null) return;
                        try {
                          await ref.read(profileRepositoryProvider).respondOffer(
                                id,
                                'contraoferta',
                                amount: result.$1,
                                message: result.$2,
                              );
                          ref.invalidate(offersProvider);
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(content: Text('$e')));
                          }
                        }
                        return;
                      }
                      try {
                        await ref.read(profileRepositoryProvider).respondOffer(id, action);
                        ref.invalidate(offersProvider);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text('$e')));
                        }
                      }
                    },
                    itemBuilder: (_) => [
                      if (isReceived) ...[
                        const PopupMenuItem(value: 'aceptada', child: Text('Aceptar')),
                        const PopupMenuItem(value: 'rechazada', child: Text('Rechazar')),
                      ],
                      const PopupMenuItem(value: 'contraoferta', child: Text('Contraofertar')),
                      if (!isReceived)
                        const PopupMenuItem(value: 'rechazada', child: Text('Cancelar / rechazar')),
                    ],
                  )
                : null,
          ),
        );
      },
    );
  }

  Future<(double?, String)?> _counterDialog(BuildContext context) async {
    final amountCtrl = TextEditingController();
    final msgCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Contraoferta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Nuevo monto (opcional)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: msgCtrl,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Mensaje *'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Enviar')),
        ],
      ),
    );
    if (ok != true) return null;
    final msg = msgCtrl.text.trim();
    if (msg.length < 2) return null;
    final amount = double.tryParse(amountCtrl.text.replaceAll(RegExp(r'[^\d]'), ''));
    return (amount, msg);
  }
}
