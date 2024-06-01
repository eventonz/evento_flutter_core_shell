import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppStyles {
  static const appBarTitle = TextStyle(
    fontSize: 19,
    fontWeight: FontWeight.bold,
  );

  static const eventTitle =
      TextStyle(fontSize: 14, fontWeight: FontWeight.bold);

  static const eventTitle2 =
      TextStyle(fontSize: 12, color: AppColors.greyLight);

  static const eventDescription =
      TextStyle(fontSize: 18, fontWeight: FontWeight.w500);

  static final light = ThemeData.light().copyWith(
      appBarTheme: AppBarTheme(
          backgroundColor: AppColors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(
            color: AppColors.primary,
          )),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.white,
      ),
      iconTheme: IconThemeData(color: AppColors.accentLight),
      listTileTheme: ListTileThemeData(iconColor: AppColors.accentLight),
      cupertinoOverrideTheme: const NoDefaultCupertinoThemeData(
        barBackgroundColor: AppColors.lightblack,
      ),
      scaffoldBackgroundColor: AppColors.white,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      colorScheme: const ColorScheme.light().copyWith(
        primary: AppColors.primary,
        brightness: Brightness.dark,
        secondary: AppColors.grey,
      ));

  static final dark = ThemeData.dark().copyWith(
    appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightblack,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: AppColors.white,
        )),
    //brightness: Brightness.dark,
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.lightblack,
    ),
    iconTheme: IconThemeData(color: AppColors.accentDark),
    listTileTheme: ListTileThemeData(iconColor: AppColors.accentDark),
    cupertinoOverrideTheme: const NoDefaultCupertinoThemeData(
      barBackgroundColor: AppColors.lightblack,
    ),
    scaffoldBackgroundColor: AppColors.black,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    primaryIconTheme: const IconThemeData(color: AppColors.white),
    colorScheme: const ColorScheme.dark().copyWith(
        primary: AppColors.primary,
        brightness: Brightness.light,
        secondary: AppColors.white),
  );

  static final tileDeepShadow = BoxShadow(
    color: AppColors.black.withOpacity(0.9),
    spreadRadius: 1,
    blurRadius: 15,
  );
}
