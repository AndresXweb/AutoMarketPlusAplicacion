import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/format.dart';
import '../../../shared/models/vehicle.dart';
import '../../../shared/widgets/app_image.dart';
import '../../catalog/catalog_repository.dart';
import '../../profile/profile_repository.dart';
import '../../my_vehicles/presentation/my_vehicles_screen.dart';

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
  final _message = TextEditingController();
  String _offerType = 'compra';
  int? _swapVehicleId;
  bool _busy = false;

  @override
  void dispose() {
    _amount.dispose();
    _message.dispose();
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
    setState(() => _busy = true);
    try {
      if (_offerType == 'compra') {
        final raw = _amount.text.replaceAll(RegExp(r'[^\d]'), '');
        final amount = double.tryParse(raw);
        if (amount == null || amount <= 0) {
          _toast('Indica un monto válido');
          setState(() => _busy = false);
          return;
        }
        await ref.read(profileRepositoryProvider).createOffer(
              vehicleId: widget.id,
              offerType: 'compra',
              amount: amount,
              message: _message.text.trim().isEmpty ? null : _message.text.trim(),
            );
      } else {
        if (_swapVehicleId == null) {
          _toast('Elige uno de tus vehículos para permutar');
          setState(() => _busy = false);
          return;
        }
        await ref.read(profileRepositoryProvider).createOffer(
              vehicleId: widget.id,
              offerType: 'permuta',
              swapVehicleId: _swapVehicleId,
              message: _message.text.trim().isEmpty ? null : _message.text.trim(),
            );
      }
      _toast('Oferta enviada');
      _amount.clear();
      _message.clear();
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
    final myVehicles = ref.watch(myVehiclesProvider);

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
        data: (v) {
          final allowsBuy = v.listingType != 'permuta';
          final allowsSwap = v.listingType != 'venta';
          return ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              AspectRatio(
                aspectRatio: 16 / 10,
                child: AppImage(src: v.imageUrl),
              ),
              if (v.images.length > 1)
                SizedBox(
                  height: 72,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                    itemCount: v.images.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) => ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 96,
                        height: 64,
                        child: AppImage(src: v.images[i]),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(v.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Text(
                      formatMoney(v.price),
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${v.year} · ${formatKm(v.mileage)} · ${v.city}',
                      style: const TextStyle(color: AppColors.muted),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${v.brand} ${v.model} · ${v.fuel} · ${v.transmission}',
                      style: const TextStyle(color: AppColors.muted),
                    ),
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
                    const Text('Hacer oferta', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: [
                        if (allowsBuy)
                          const ButtonSegment(value: 'compra', label: Text('Compra')),
                        if (allowsSwap)
                          const ButtonSegment(value: 'permuta', label: Text('Permuta')),
                      ],
                      selected: {
                        allowsBuy && !allowsSwap
                            ? 'compra'
                            : (!allowsBuy && allowsSwap ? 'permuta' : _offerType)
                      },
                      onSelectionChanged: (s) {
                        setState(() => _offerType = s.first);
                      },
                    ),
                    const SizedBox(height: 12),
                    if (_offerType == 'compra' && allowsBuy)
                      TextField(
                        controller: _amount,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Monto (COP)',
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                      ),
                    if (_offerType == 'permuta' && allowsSwap) ...[
                      myVehicles.when(
                        data: (list) {
                          final active = list.where((x) => x.status == 'activo').toList();
                          if (active.isEmpty) {
                            return const Text(
                              'No tienes vehículos activos para permutar.',
                              style: TextStyle(color: AppColors.muted),
                            );
                          }
                          return DropdownButtonFormField<int>(
                            value: _swapVehicleId,
                            decoration: const InputDecoration(labelText: 'Tu vehículo'),
                            items: active
                                .map(
                                  (x) => DropdownMenuItem(
                                    value: x.id,
                                    child: Text(x.title, overflow: TextOverflow.ellipsis),
                                  ),
                                )
                                .toList(),
                            onChanged: (id) => setState(() => _swapVehicleId = id),
                          );
                        },
                        loading: () => const LinearProgressIndicator(),
                        error: (_, __) => const Text('No se pudieron cargar tus vehículos'),
                      ),
                    ],
                    const SizedBox(height: 12),
                    TextField(
                      controller: _message,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Mensaje (opcional)'),
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
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('$e', style: const TextStyle(color: AppColors.danger)),
        ),
      ),
    );
  }
}
