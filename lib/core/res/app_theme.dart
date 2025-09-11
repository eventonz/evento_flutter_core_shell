import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppThemeColors {
  // App backgrounds
  static const Color lightBackground =
      Color(0xFFF5F5F5); // light grey (bg-gray-100 equivalent)
  static const Color darkBackground = Color(0xFF121212); // dark

  // Card backgrounds
  static const Color lightCard = Color(0xFFFFFFFF); // white
  static const Color darkCard = Color(0x14FFFFFF); // dark card
}

class AppThemeStyles {
  static BoxDecoration cardDecoration(BuildContext context) {
    final isLight = !Get.isDarkMode;
    return BoxDecoration(
      color: isLight ? AppThemeColors.lightCard : AppThemeColors.darkCard,
      borderRadius: BorderRadius.circular(12),
      boxShadow: isLight
          ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 3),
                spreadRadius: 0,
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
