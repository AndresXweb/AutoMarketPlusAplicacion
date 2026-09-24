import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/format.dart';
import '../../../shared/models/vehicle.dart';
import '../../catalog/catalog_repository.dart';
import '../../profile/profile_repository.dart';

final vehicleDetailProvider =
    FutureProvider.autoDispose.family<Vehicle, int>((ref, id) {
  return ref.watch(catalogRepositoryProvider).getById(id);
});

class VehicleDetailScreen extends ConsumerStatefulWidget {
  const VehicleDetailScreen({super.key, required this.id});
  final int id;

  @override
  ConsumerState<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends ConsumerState<VehicleDetailScreen> {
  final _amount = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _toggleFav() async {
    final logged = await ref.read(apiClientProvider).isLoggedIn;
    if (!logged) {
      _toast('Inicia sesión para guardar favoritos');
      return;
    }
    setState(() => _busy = true);
    try {
      final fav = await ref.read(profileRepositoryProvider).toggleFavorite(widget.id);
      _toast(fav ? 'Añadido a favoritos' : 'Quitado de favoritos');
    } catch (e) {
      _toast('Error: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _offer() async {
    final logged = await ref.read(apiClientProvider).isLoggedIn;
    if (!logged) {
      _toast('Inicia sesión para ofertar');
      return;
    }
    final amount = double.tryParse(_amount.text.replaceAll('.', '').replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      _toast('Indica un monto válido');
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(profileRepositoryProvider).createOffer(
            vehicleId: widget.id,
            offerType: 'compra',
            amount: amount,
          );
      _toast('Oferta enviada');
      _amount.clear();
    } catch (e) {
      _toast('Error: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _toast(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(vehicleDetailProvider(widget.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle'),
        actions: [
          IconButton(
            onPressed: _busy ? null : _toggleFav,
            icon: const Icon(Icons.favorite_border),
          ),
        ],
      ),
      body: async.when(
        data: (v) => ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: v.imageUrl.startsWith('http')
                  ? CachedNetworkImage(imageUrl: v.imageUrl, fit: BoxFit.cover)
                  : Container(
                      color: AppColors.surface2,
                      child: const Icon(Icons.directions_car, size: 64, color: AppColors.muted),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(v.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(formatMoney(v.price), style: const TextStyle(color: AppColors.gold, fontSize: 24, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text('${v.year} · ${formatKm(v.mileage)} · ${v.city}', style: const TextStyle(color: AppColors.muted)),
                  const SizedBox(height: 4),
                  Text('${v.brand} ${v.model} · ${v.fuel} · ${v.transmission}', style: const TextStyle(color: AppColors.muted)),
                  if (v.sellerName != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Vendedor: ${v.sellerName}${v.sellerVerified ? ' ✓' : ''}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Text('Descripción', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 6),
                  Text(v.description.isEmpty ? 'Sin descripción' : v.description),
                  const SizedBox(height: 24),
                  const Text('Hacer oferta de compra', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _amount,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Monto (COP)',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _busy ? null : _offer,
                    child: const Text('Enviar oferta'),
                  ),
                ],
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e', style: const TextStyle(color: AppColors.danger))),
      ),
    );
  }
}
