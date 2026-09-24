import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/profile.dart';
import '../../auth/auth_repository.dart';

final profileProvider = FutureProvider.autoDispose<Profile?>((ref) async {
  final logged = await ref.watch(apiClientProvider).isLoggedIn;
  if (!logged) return null;
  return ref.watch(authRepositoryProvider).profile();
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: async.when(
        data: (p) {
          if (p == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('No has iniciado sesión', style: TextStyle(color: AppColors.muted)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Entrar'),
                  ),
                ],
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.surface2,
                child: Text(
                  p.displayName.isNotEmpty ? p.displayName[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 28, color: AppColors.gold),
                ),
              ),
              const SizedBox(height: 12),
              Text(p.displayName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              Text(p.email ?? '', style: const TextStyle(color: AppColors.muted)),
              const SizedBox(height: 8),
              _row('Ciudad', p.city ?? '—'),
              _row('Teléfono', p.phone ?? '—'),
              _row('WhatsApp', p.whatsapp ?? '—'),
              _row('Verificación', p.verificationStatus),
              _row('Cuenta', p.accountStatus),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.directions_car),
                title: const Text('Mis anuncios'),
                onTap: () => context.push('/my-vehicles'),
              ),
              ListTile(
                leading: const Icon(Icons.favorite),
                title: const Text('Favoritos'),
                onTap: () => context.push('/favorites'),
              ),
              ListTile(
                leading: const Icon(Icons.handshake),
                title: const Text('Ofertas'),
                onTap: () => context.push('/offers'),
              ),
              ListTile(
                leading: const Icon(Icons.mail_outline),
                title: const Text('Contacto'),
                onTap: () => context.push('/contact'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () async {
                  await ref.read(authRepositoryProvider).signOut();
                  ref.invalidate(profileProvider);
                  if (context.mounted) context.go('/login');
                },
                child: const Text('Cerrar sesión'),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }

  Widget _row(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 110, child: Text(k, style: const TextStyle(color: AppColors.muted))),
          Expanded(child: Text(v, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
