import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../shared/models/profile.dart';

class AuthRepository {
  AuthRepository(this._api);
  final ApiClient _api;

  Future<void> signIn({required String email, required String password}) async {
    final res = await _api.dio.post(
      '/api/auth/sign-in/email',
      data: {'email': email, 'password': password},
    );
    final token = _extractToken(res.data);
    if (token == null || token.isEmpty) {
      throw Exception('No se recibió token de sesión. Revisa la respuesta del login.');
    }
    await _api.saveToken(token);
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final res = await _api.dio.post(
      '/api/auth/sign-up/email',
      data: {'email': email, 'password': password, 'name': name},
    );
    final token = _extractToken(res.data);
    if (token != null && token.isNotEmpty) {
      await _api.saveToken(token);
    }
  }

  Future<void> signOut() async {
    try {
      await _api.dio.post('/api/auth/sign-out');
    } catch (_) {}
    await _api.clearToken();
  }

  Future<Profile?> me() async {
    final res = await _api.dio.get('/api/me');
    final data = res.data as Map<String, dynamic>;
    final profile = data['profile'];
    if (profile is Map<String, dynamic>) {
      return Profile.fromJson(profile);
    }
    return null;
  }

  Future<Profile?> profile() async {
    final res = await _api.dio.get('/api/profile');
    return Profile.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  String? _extractToken(dynamic data) {
    if (data is! Map) return null;
    // Better Auth suele devolver session.token
    final session = data['session'];
    if (session is Map && session['token'] != null) {
      return session['token'].toString();
    }
    if (data['token'] != null) return data['token'].toString();
    return null;
  }

  String messageFromError(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['error'] != null) return data['error'].toString();
      if (data is Map && data['message'] != null) return data['message'].toString();
      if (e.response?.statusCode == 401) return 'Correo o contraseña incorrectos';
      if (e.type == DioExceptionType.connectionError) {
        return 'Sin conexión al servidor. Revisa la URL en api_config.dart';
      }
      return e.message ?? 'Error de red';
    }
    return e.toString();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(apiClientProvider));
});
