import 'package:evento_core/core/db/app_db.dart';
import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/ui/common_components/text.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class AthleteTile extends StatelessWidget {
  const AthleteTile({
    Key? key,
    required this.entrant,
    required this.onTap,
  }) : super(key: key);
  final AppAthleteDb entrant;
  final VoidCallback onTap;

  String raceNo() {
    if (entrant.raceno == -1) {
      return 'TBC';
    }
    return entrant.raceno.toString();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.all(8),
      leading: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 0, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 12.w,
              child: AppText(
                raceNo(),
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.light
                    ? AppColors.accentDark
                    : AppColors.accentLight,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
      title: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              entrant.name,
            ),
            SizedBox(
              height: 1.h,
            ),
            AppText(
              entrant.info,
              color: AppColors.grey,
              fontSize: 12,
            ),
          ],
        ),
      ),
      trailing: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 6, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Visibility(
                    visible: entrant.isFollowed,
                    child: Icon(
                      Icons.star,
                      color: AppColors.primary,
                      size: 4.w,
                    ),
                  ),
                  SizedBox(
                    width: 1.w,
                  ),
                  Icon(
                    Icons.keyboard_arrow_right_rounded,
                    color: AppColors.primary.withOpacity(0.5),
                    size: 4.5.w,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
