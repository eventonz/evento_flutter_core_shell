import 'package:cached_network_image/cached_network_image.dart';
import 'package:evento_core/core/models/event_info.dart';
import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/l10n/app_localizations.dart';
import 'package:evento_core/ui/common_components/no_data_found_layout.dart';
import 'package:evento_core/ui/common_components/text.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SubEventTile extends StatelessWidget {
  const SubEventTile({Key? key, required this.onTap, required this.subEvent})
      : super(key: key);
  final VoidCallback onTap;
  final SubEvents subEvent;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minVerticalPadding: 16,
      onTap: onTap,
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: CachedNetworkImage(
            imageUrl: subEvent.image!,
            placeholder: (_, val) =>
                const Center(child: CircularProgressIndicator.adaptive()),
            errorWidget: (_, val, val2) => Center(
                child: NoDataFoundLayout(
              errorMessage: AppLocalizations.of(context)!.noImageFound,
            )),
            width: 10.h,
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            subEvent.title!,
            fontWeight: FontWeight.bold,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(
            height: 2,
          ),
          AppText(
            subEvent.subtitle!,
            fontSize: 12,
            color: AppColors.grey,
          )
        ],
      ),
      trailing: Icon(
        Icons.keyboard_arrow_right_rounded,
        color: AppColors.grey,
        size: 4.5.w,
      ),
    );
  }
}
