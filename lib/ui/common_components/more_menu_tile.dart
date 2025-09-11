import 'package:evento_core/core/models/app_config.dart';
import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/core/utils/helpers.dart';
import 'package:evento_core/ui/common_components/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class MoreMenuTile extends StatelessWidget {
  const MoreMenuTile({Key? key, required this.item, required this.onTap})
      : super(key: key);
  final Items item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          children: [
            SvgPicture.asset(
              AppHelper.getSvg(item.icon!),
              fit: BoxFit.cover,
              color: Theme.of(context).brightness == Brightness.light
                  ? AppColors.primary
                  : AppColors.secondary,
              width: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppText(
                item.title!,
                fontSize: 16,
              ),
            ),
            Icon(
              Icons.arrow_circle_right_outlined,
              color: Theme.of(context).brightness == Brightness.light
                  ? AppColors.primary
                  : AppColors.secondary,
              size: 4.5.w,
            ),
          ],
        ),
      ),
    );
  }
}
