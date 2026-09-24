import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/profile.dart';
import '../profile_repository.dart';
import 'profile_screen.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key, this.initial});
  final Profile? initial;

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _first;
  late final TextEditingController _last;
  late final TextEditingController _phone;
  late final TextEditingController _whatsapp;
  late final TextEditingController _city;
  late final TextEditingController _address;
  late final TextEditingController _email;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final p = widget.initial;
    _first = TextEditingController(text: p?.firstName ?? '');
    _last = TextEditingController(text: p?.lastName ?? '');
    _phone = TextEditingController(text: p?.phone ?? '');
    _whatsapp = TextEditingController(text: p?.whatsapp ?? '');
    _city = TextEditingController(text: p?.city ?? '');
    _address = TextEditingController(text: p?.address ?? '');
    _email = TextEditingController(text: p?.email ?? '');
  }

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _phone.dispose();
    _whatsapp.dispose();
    _city.dispose();
    _address.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_first.text.trim().isEmpty ||
        _last.text.trim().isEmpty ||
        _phone.text.trim().isEmpty ||
        _city.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nombre, apellido, teléfono y ciudad son obligatorios')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(profileRepositoryProvider).updateProfile({
        'firstName': _first.text.trim(),
        'lastName': _last.text.trim(),
        'phone': _phone.text.trim(),
        'whatsapp': _whatsapp.text.trim().isEmpty ? _phone.text.trim() : _whatsapp.text.trim(),
        'city': _city.text.trim(),
        'address': _address.text.trim(),
        'email': _email.text.trim(),
      });
      ref.invalidate(profileProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado')),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _first, decoration: const InputDecoration(labelText: 'Nombre *')),
          const SizedBox(height: 12),
          TextField(controller: _last, decoration: const InputDecoration(labelText: 'Apellido *')),
          const SizedBox(height: 12),
          TextField(controller: _phone, decoration: const InputDecoration(labelText: 'Teléfono *'), keyboardType: TextInputType.phone),
          const SizedBox(height: 12),
          TextField(controller: _whatsapp, decoration: const InputDecoration(labelText: 'WhatsApp'), keyboardType: TextInputType.phone),
          const SizedBox(height: 12),
          TextField(controller: _city, decoration: const InputDecoration(labelText: 'Ciudad *')),
          const SizedBox(height: 12),
          TextField(controller: _address, decoration: const InputDecoration(labelText: 'Dirección')),
          const SizedBox(height: 12),
          TextField(controller: _email, decoration: const InputDecoration(labelText: 'Correo'), keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loading ? null : _save,
            child: _loading
                ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                : const Text('Guardar'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => context.push('/verification'),
            child: const Text('Enviar verificación de cédula'),
          ),
        ],
      ),
    );
  }
}
