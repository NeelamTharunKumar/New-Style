import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/design_tokens.dart';

class LocalWardrobeImage extends StatelessWidget {
  const LocalWardrobeImage({
    super.key,
    required this.localImageRef,
    required this.hexColor,
    this.width,
    this.height,
    this.borderRadius = 12,
    this.icon = Icons.checkroom,
  });

  final String? localImageRef;
  final String? hexColor;
  final double? width;
  final double? height;
  final double borderRadius;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final path = _pathFromRef(localImageRef);
    if (path != null) {
      final file = File(path);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Image.file(
            file,
            width: width,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _fallback(context),
          ),
        );
      }
    }
    return _fallback(context);
  }

  Widget _fallback(BuildContext context) {
    final color = _parseHex(hexColor) ?? DrapeColors.of(context).primary.withOpacity(0.4);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: DrapeColors.of(context).border),
      ),
      child: Icon(icon, size: 22, color: DrapeColors.of(context).foreground.withOpacity(0.6)),
    );
  }
}

String? _pathFromRef(String? value) {
  if (value == null || value.isEmpty) return null;
  final uri = Uri.tryParse(value);
  if (uri != null && uri.scheme == 'file') return uri.toFilePath();
  if (value.startsWith('/')) return value;
  return null;
}

Color? _parseHex(String? hex) {
  if (hex == null || !RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(hex)) return null;
  return Color(int.parse('FF${hex.substring(1)}', radix: 16));
}
