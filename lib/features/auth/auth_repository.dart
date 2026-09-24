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
      data: {
        'email': email,
        'password': password,
      },
      options: Options(
        headers: {
          'Origin': 'http://localhost:8080',
        },
        validateStatus: (s) => s != null && s < 500,
      ),
    );

    if (res.statusCode == 401 || res.statusCode == 403) {
      final msg = _errorMessage(res.data) ??
          'Correo o contraseña incorrectos (o origen no permitido).';
      throw Exception(msg);
    }
    if (res.statusCode != null && res.statusCode! >= 400) {
      throw Exception(_errorMessage(res.data) ?? 'Error al iniciar sesión (${res.statusCode})');
    }

    final token = _extractToken(res.data, res.headers);
    if (token == null || token.isEmpty) {
      throw Exception(
        'Login OK pero no llegó token. Respuesta: ${res.data}',
      );
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
      data: {
        'email': email,
        'password': password,
        'name': name,
      },
      options: Options(
        headers: {'Origin': 'http://localhost:8080'},
        validateStatus: (s) => s != null && s < 500,
      ),
    );

    if (res.statusCode != null && res.statusCode! >= 400) {
      throw Exception(
        _errorMessage(res.data) ?? 'No se pudo registrar (${res.statusCode})',
      );
    }

    final token = _extractToken(res.data, res.headers);
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

  String? _extractToken(dynamic data, Headers headers) {
    if (data is Map) {
      final session = data['session'];
      if (session is Map) {
        if (session['token'] != null) return session['token'].toString();
        if (session['sessionToken'] != null) return session['sessionToken'].toString();
      }
      if (data['token'] != null) return data['token'].toString();
      final nested = data['data'];
      if (nested is Map) {
        final s = nested['session'];
        if (s is Map && s['token'] != null) return s['token'].toString();
      }
    }

    final setCookie = headers['set-cookie'];
    if (setCookie != null) {
      for (final c in setCookie) {
        final m = RegExp(r'(?:session_token|__Host-grok-auth\.session_token)=([^;]+)').firstMatch(c);
        if (m != null) return Uri.decodeComponent(m.group(1)!);
      }
    }
    return null;
  }

  String? _errorMessage(dynamic data) {
    if (data is Map) {
      if (data['message'] != null) return data['message'].toString();
      if (data['error'] != null) {
        final e = data['error'];
        if (e is Map && e['message'] != null) return e['message'].toString();
        return e.toString();
      }
    }
    if (data is String && data.isNotEmpty) return data;
    return null;
  }

  String messageFromError(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      final msg = _errorMessage(data);
      if (msg != null) return msg;
      if (e.response?.statusCode == 401) return 'Correo o contraseña incorrectos';
      if (e.response?.statusCode == 403) {
        return 'Origen no permitido. Añade el puerto de Flutter a trustedOrigins del backend.';
      }
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return 'Sin conexión al servidor. Revisa api_config.dart y npm run dev.';
      }
      return e.message ?? 'Error de red';
    }
    return e.toString().replaceFirst('Exception: ', '');
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(apiClientProvider));
});
