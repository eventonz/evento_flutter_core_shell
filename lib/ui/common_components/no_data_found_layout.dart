import 'package:evento_core/core/res/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'text.dart';

class NoDataFoundLayout extends StatelessWidget {
  const NoDataFoundLayout({Key? key, this.title, required this.errorMessage})
      : super(key: key);
  final String? title;
  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        title == null
            ? const SizedBox()
            : Column(
                children: [
                  AppText(
                    title!,
                    textAlign: TextAlign.center,
                    color: AppColors.black.withOpacity(0.8),
                    fontSize: 14,
                  ),
                  SizedBox(
                    height: 0.5.h,
                  ),
                ],
              ),
        AppText(
          errorMessage,
          textAlign: TextAlign.center,
          color: AppColors.grey.withOpacity(0.6),
          fontSize: 12,
        ),
      ],
    );
  }
}
