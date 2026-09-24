import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Muestra imágenes del backend:
/// - http(s)://...  → red
/// - data:image/... → base64 en memoria
class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    required this.src,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  final String src;
  final BoxFit fit;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    if (src.isEmpty) return _placeholder();

    if (src.startsWith('data:image')) {
      try {
        final base64 = src.split(',').last;
        final bytes = base64Decode(base64);
        return Image.memory(
          bytes,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (_, __, ___) => _placeholder(),
        );
      } catch (_) {
        return _placeholder();
      }
    }

    if (src.startsWith('http://') || src.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: src,
        fit: fit,
        width: width,
        height: height,
        placeholder: (_, __) => Container(color: AppColors.surface2),
        errorWidget: (_, __, ___) => _placeholder(),
      );
    }

    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: AppColors.surface2,
      child: const Center(
        child: Icon(Icons.directions_car, size: 48, color: AppColors.muted),
      ),
    );
  }
}
