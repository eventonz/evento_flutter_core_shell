import 'package:evento_core/core/models/app_config.dart';
import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/ui/common_components/text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MoreMenuTitle extends StatelessWidget {
  const MoreMenuTitle({Key? key, required this.item}) : super(key: key);
  final Items item;

  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;

    return Container(
      padding: const EdgeInsets.fromLTRB(0, 24, 0, 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(
            item.title!,
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: isLightMode
                ? AppColors.accentDark.withOpacity(0.8)
                : AppColors.accentLight.withOpacity(0.8),
          ),
        ],
      ),
    );
  }
}
