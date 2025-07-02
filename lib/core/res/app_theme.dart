import 'package:flutter/material.dart';

class AppThemeColors {
  // App backgrounds
  static const Color lightBackground = Color(0xFFF9F9F9); // light
  static const Color darkBackground = Color(0xFF121212); // dark

  // Card backgrounds
  static const Color lightCard = Color(0xFFFFFFFF); // white
  static const Color darkCard = Color(0xFF2C2C2E); // dark card
}

class AppThemeStyles {
  static BoxDecoration cardDecoration(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return BoxDecoration(
      color: isLight ? AppThemeColors.darkCard :  AppThemeColors.lightCard,
      borderRadius: BorderRadius.circular(12),
      boxShadow: isLight
          ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ]
          : null,
      border: !isLight
          ? Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            )
          : null,
    );
  }
}
