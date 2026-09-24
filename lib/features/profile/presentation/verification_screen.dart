import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../profile_repository.dart';
import 'profile_screen.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  const VerificationScreen({super.key});

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  final _docType = TextEditingController(text: 'CC');
  final _docNumber = TextEditingController();
  String? _front;
  String? _back;
  bool _loading = false;

  @override
  void dispose() {
    _docType.dispose();
    _docNumber.dispose();
    super.dispose();
  }

  Future<String?> _pick() async {
    final f = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 55, maxWidth: 1000);
    if (f == null) return null;
    final bytes = await f.readAsBytes();
    final mime = f.mimeType ?? 'image/jpeg';
    return 'data:$mime;base64,${base64Encode(bytes)}';
  }

  Future<void> _submit() async {
    if (_front == null || _back == null || _docNumber.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa cédula frente, reverso y número')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(profileRepositoryProvider).submitVerification(
            idFrontUrl: _front!,
            idBackUrl: _back!,
            documentType: _docType.text.trim(),
            documentNumber: _docNumber.text.trim(),
          );
      ref.invalidate(profileProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Documentos enviados. Quedan en revisión.')),
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
      appBar: AppBar(title: const Text('Verificación')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Sube fotos claras de tu documento (frente y reverso).',
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          TextField(controller: _docType, decoration: const InputDecoration(labelText: 'Tipo (CC, CE…)')),
          const SizedBox(height: 12),
          TextField(controller: _docNumber, decoration: const InputDecoration(labelText: 'Número de documento')),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final d = await _pick();
                    if (d != null) setState(() => _front = d);
                  },
                  child: Text(_front == null ? 'Frente' : 'Frente ✓'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final d = await _pick();
                    if (d != null) setState(() => _back = d);
                  },
                  child: Text(_back == null ? 'Reverso' : 'Reverso ✓'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                : const Text('Enviar a revisión'),
          ),
        ],
      ),
    );
  }
}
