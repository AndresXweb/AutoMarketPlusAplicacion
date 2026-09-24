# AutoMarket App (Flutter)

Cliente móvil del marketplace AutoMarketPlus.

## Requisitos

- Flutter 3.22+ / Dart 3.3+
- Android Studio
- Backend corriendo (rama `AdaptacionFlutterApp`)

## Abrir en Android Studio

1. **File → Open** → selecciona esta carpeta `automarket_app`
2. Espera que indexe y resuelva dependencias (o en terminal):

```bash
flutter pub get
```

3. Configura la **URL del backend** en `lib/core/api/api_config.dart`

4. Emulador Android:
   - Backend en tu PC → usa `http://10.0.2.2:8080`
   - Dispositivo físico → usa la IP de tu PC en la red (`http://192.168.x.x:8080`)

5. Run ▶

## Login de prueba

Usa un usuario ya registrado en el backend web  
(`POST /api/auth/sign-in/email`).

## Estructura

```
lib/
  core/api/          Dio + auth interceptor
  features/          Pantallas por módulo
  shared/models/     Modelos JSON
  main.dart
```
