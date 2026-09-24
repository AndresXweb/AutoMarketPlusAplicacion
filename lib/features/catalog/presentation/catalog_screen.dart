import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/vehicle.dart';
import '../../../shared/widgets/vehicle_card.dart';
import '../catalog_repository.dart';

final catalogFiltersProvider = StateProvider<CatalogFilters>((ref) => const CatalogFilters());

final catalogListProvider = FutureProvider.autoDispose<List<Vehicle>>((ref) {
  final filters = ref.watch(catalogFiltersProvider);
  return ref.watch(catalogRepositoryProvider).listVehicles(filters);
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

  void _openFilters() {
    final current = ref.read(catalogFiltersProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return _FiltersSheet(
          initial: current,
          onApply: (f) {
            ref.read(catalogFiltersProvider.notifier).state = f;
            Navigator.pop(ctx);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(catalogListProvider);
    final filters = ref.watch(catalogFiltersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo'),
        actions: [
          IconButton(icon: const Icon(Icons.tune), onPressed: _openFilters),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText: 'Buscar marca, línea, ciudad…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _search.clear();
                    ref.read(catalogFiltersProvider.notifier).state =
                        filters.copyWith(q: '');
                  },
                ),
              ),
              onSubmitted: (v) {
                ref.read(catalogFiltersProvider.notifier).state =
                    filters.copyWith(q: v.trim());
              },
            ),
          ),
          if (filters.listingType != null ||
              filters.brand != null ||
              filters.city != null ||
              filters.verifiedOnly)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Wrap(
                spacing: 6,
                children: [
                  if (filters.listingType != null)
                    Chip(
                      label: Text(filters.listingType!),
                      onDeleted: () {
                        ref.read(catalogFiltersProvider.notifier).state =
                            filters.copyWith(clearListing: true);
                      },
                    ),
                  if (filters.brand != null)
                    Chip(
                      label: Text(filters.brand!),
                      onDeleted: () {
                        ref.read(catalogFiltersProvider.notifier).state =
                            filters.copyWith(clearBrand: true);
                      },
                    ),
                  if (filters.city != null)
                    Chip(
                      label: Text(filters.city!),
                      onDeleted: () {
                        ref.read(catalogFiltersProvider.notifier).state =
                            filters.copyWith(clearCity: true);
                      },
                    ),
                  if (filters.verifiedOnly)
                    Chip(
                      label: const Text('Verificados'),
                      onDeleted: () {
                        ref.read(catalogFiltersProvider.notifier).state =
                            filters.copyWith(verifiedOnly: false);
                      },
                    ),
                ],
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
                        Center(
                          child: Text('Sin resultados', style: TextStyle(color: AppColors.muted)),
                        ),
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

class _FiltersSheet extends StatefulWidget {
  const _FiltersSheet({required this.initial, required this.onApply});
  final CatalogFilters initial;
  final ValueChanged<CatalogFilters> onApply;

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  late String? listingType;
  late final TextEditingController brand;
  late final TextEditingController city;
  late final TextEditingController minPrice;
  late final TextEditingController maxPrice;
  late bool verifiedOnly;

  @override
  void initState() {
    super.initState();
    listingType = widget.initial.listingType;
    brand = TextEditingController(text: widget.initial.brand ?? '');
    city = TextEditingController(text: widget.initial.city ?? '');
    minPrice = TextEditingController(
      text: widget.initial.minPrice?.toStringAsFixed(0) ?? '',
    );
    maxPrice = TextEditingController(
      text: widget.initial.maxPrice?.toStringAsFixed(0) ?? '',
    );
    verifiedOnly = widget.initial.verifiedOnly;
  }

  @override
  void dispose() {
    brand.dispose();
    city.dispose();
    minPrice.dispose();
    maxPrice.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Filtros', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              value: listingType,
              decoration: const InputDecoration(labelText: 'Tipo'),
              items: const [
                DropdownMenuItem(value: null, child: Text('Todos')),
                DropdownMenuItem(value: 'venta', child: Text('Venta')),
                DropdownMenuItem(value: 'permuta', child: Text('Permuta')),
                DropdownMenuItem(value: 'ambos', child: Text('Ambos')),
              ],
              onChanged: (v) => setState(() => listingType = v),
            ),
            const SizedBox(height: 12),
            TextField(controller: brand, decoration: const InputDecoration(labelText: 'Marca')),
            const SizedBox(height: 12),
            TextField(controller: city, decoration: const InputDecoration(labelText: 'Ciudad')),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: minPrice,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Precio mín'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: maxPrice,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Precio máx'),
                  ),
                ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Solo vendedores verificados'),
              value: verifiedOnly,
              onChanged: (v) => setState(() => verifiedOnly = v),
            ),
            ElevatedButton(
              onPressed: () {
                widget.onApply(
                  CatalogFilters(
                    q: widget.initial.q,
                    listingType: listingType,
                    brand: brand.text.trim().isEmpty ? null : brand.text.trim(),
                    city: city.text.trim().isEmpty ? null : city.text.trim(),
                    minPrice: double.tryParse(minPrice.text.replaceAll('.', '')),
                    maxPrice: double.tryParse(maxPrice.text.replaceAll('.', '')),
                    verifiedOnly: verifiedOnly,
                  ),
                );
              },
              child: const Text('Aplicar'),
            ),
          ],
        ),
      ),
    );
  }
}
