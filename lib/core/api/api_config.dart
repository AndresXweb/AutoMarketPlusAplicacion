/// Configuración del backend AutoMarketPlus.
///
/// Emulador Android → 10.0.2.2 apunta al localhost de tu PC
/// Dispositivo físico → cambia por la IP de tu máquina (ej. 192.168.1.8)
/// iOS simulador → localhost funciona
class ApiConfig {
  /// Cambia SOLO esta línea según cómo pruebes:
  static const String baseUrl = "http://localhost:8080";

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
