import 'package:flutter/material.dart';

import '../../core/design_tokens.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 52});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.secondary, AppColors.accent],
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: AppShadows.accent,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.checkroom_outlined, size: size * 0.48, color: Colors.white),
          Positioned(
            right: size * 0.15,
            top: size * 0.15,
            child: Icon(Icons.auto_awesome, size: size * 0.22, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
