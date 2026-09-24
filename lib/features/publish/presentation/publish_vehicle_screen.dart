import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../profile/profile_repository.dart';
import '../../my_vehicles/presentation/my_vehicles_screen.dart';

/// Valores alineados con vehicleInput del backend (market.ts).
class PublishVehicleScreen extends ConsumerStatefulWidget {
  const PublishVehicleScreen({super.key});

  @override
  ConsumerState<PublishVehicleScreen> createState() =>
      _PublishVehicleScreenState();
}

class _PublishVehicleScreenState extends ConsumerState<PublishVehicleScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _brand = TextEditingController();
  final _model = TextEditingController();
  final _year = TextEditingController();
  final _mileage = TextEditingController();
  final _price = TextEditingController();
  final _city = TextEditingController();
  final _description = TextEditingController();

  String _condition = 'usado';
  String _fuel = 'gasolina';
  String _transmission = 'manual';
  String _bodyType = 'sedan';
  String _listingType = 'venta';
  bool _taxesCurrent = true;
  bool _finesCurrent = true;
  bool _loading = false;
  final List<String> _imagesDataUrl = [];

  @override
  void dispose() {
    _title.dispose();
    _brand.dispose();
    _model.dispose();
    _year.dispose();
    _mileage.dispose();
    _price.dispose();
    _city.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(imageQuality: 70, maxWidth: 1400);
    if (files.isEmpty) return;
    for (final f in files.take(6 - _imagesDataUrl.length)) {
      final bytes = await f.readAsBytes();
      final b64 = base64Encode(bytes);
      final mime = f.mimeType ?? 'image/jpeg';
      _imagesDataUrl.add('data:$mime;base64,$b64');
    }
    setState(() {});
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    if (_imagesDataUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sube al menos una foto')),
      );
      return;
    }
    if (_description.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La descripción debe tener al menos 10 caracteres'),
        ),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(profileRepositoryProvider).createVehicle({
        'title': _title.text.trim(),
        'brand': _brand.text.trim(),
        'model': _model.text.trim(),
        'year': int.parse(_year.text.trim()),
        'mileage': int.parse(_mileage.text.trim().replaceAll('.', '')),
        'price': double.parse(
          _price.text.trim().replaceAll('.', '').replaceAll(',', ''),
        ),
        'condition': _condition,
        'fuel': _fuel,
        'transmission': _transmission,
        'bodyType': _bodyType,
        'city': _city.text.trim(),
        'description': _description.text.trim(),
        'images': _imagesDataUrl,
        'listingType': _listingType,
        'taxesCurrent': _taxesCurrent,
        'finesCurrent': _finesCurrent,
        'showWhatsapp': true,
        'acceptLowerOffers': true,
      });
      if (!mounted) return;
      ref.invalidate(myVehiclesProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Anuncio enviado. Si no estás verificado, queda en revisión.',
          ),
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Publicar vehículo')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Fotos (máx. 6)',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._imagesDataUrl.asMap().entries.map((e) {
                  final bytes = base64Decode(e.value.split(',').last);
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          bytes,
                          width: 88,
                          height: 88,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.white,
                          ),
                          onPressed: () =>
                              setState(() => _imagesDataUrl.removeAt(e.key)),
                        ),
                      ),
                    ],
                  );
                }),
                if (_imagesDataUrl.length < 6)
                  OutlinedButton.icon(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.add_a_photo),
                    label: const Text('Agregar'),
                  ),
              ],
            ),
            if (kIsWeb)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  'En web se usa el selector de archivos del navegador.',
                  style: TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ),
            const SizedBox(height: 16),
            _field(_title, 'Título del anuncio'),
            _field(_brand, 'Marca'),
            _field(_model, 'Línea / modelo'),
            _field(_year, 'Año', keyboard: TextInputType.number),
            _field(_mileage, 'Kilometraje', keyboard: TextInputType.number),
            _field(_price, 'Precio (COP)', keyboard: TextInputType.number),
            _field(_city, 'Ciudad'),
            _field(
              _description,
              'Descripción (mín. 10 caracteres)',
              maxLines: 4,
            ),
            const SizedBox(height: 8),
            _dropdown(
              'Tipo de anuncio',
              _listingType,
              const ['venta', 'permuta', 'ambos'],
              (v) => setState(() => _listingType = v!),
            ),
            _dropdown(
              'Condición',
              _condition,
              const ['nuevo', 'seminuevo', 'usado'],
              (v) => setState(() => _condition = v!),
            ),
            _dropdown(
              'Combustible',
              _fuel,
              const ['gasolina', 'diesel', 'hibrido', 'electrico'],
              (v) => setState(() => _fuel = v!),
            ),
            _dropdown(
              'Transmisión',
              _transmission,
              const ['manual', 'automatica'],
              (v) => setState(() => _transmission = v!),
            ),
            _dropdown(
              'Carrocería',
              _bodyType,
              const ['sedan', 'suv', 'pickup', 'hatchback', 'van', 'coupe'],
              (v) => setState(() => _bodyType = v!),
            ),
            SwitchListTile(
              title: const Text('Impuestos al día'),
              value: _taxesCurrent,
              onChanged: (v) => setState(() => _taxesCurrent = v),
            ),
            SwitchListTile(
              title: const Text('Comparendos al día'),
              value: _finesCurrent,
              onChanged: (v) => setState(() => _finesCurrent = v),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Text('Publicar'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String label, {
    TextInputType? keyboard,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        keyboardType: keyboard,
        maxLines: maxLines,
        validator: (v) =>
            (v == null || v.trim().isEmpty) ? 'Requerido' : null,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Widget _dropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(labelText: label),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
