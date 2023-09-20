import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/ui/common_components/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class RetryLayout extends StatelessWidget {
  const RetryLayout({Key? key, required this.onTap, this.errorMessage})
      : super(key: key);
  final String? errorMessage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          FeatherIcons.xCircle,
          size: 4.8.w,
          color: AppColors.grey,
        ),
        SizedBox(height: 1.h),
        AppText(
          errorMessage ?? 'Something went wrong...',
          color: AppColors.grey,
          fontSize: 12,
        ),
        TextButton(
          onPressed: onTap,
          child: const AppText(
            'Retry',
            color: AppColors.grey,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    );
  }
}
