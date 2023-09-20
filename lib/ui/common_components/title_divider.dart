import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/ui/common_components/text.dart';
import 'package:flutter/material.dart';

class TitleDivider extends StatelessWidget {
  const TitleDivider({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      width: double.infinity,
      color: Theme.of(context).brightness == Brightness.light
          ? AppColors.darkBlack
          : AppColors.greyLighter,
      child: AppText(
        title,
        fontSize: 12,
      ),
    );
  }
}
