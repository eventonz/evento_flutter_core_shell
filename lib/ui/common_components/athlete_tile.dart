import 'package:evento_core/core/db/app_db.dart';
import 'package:evento_core/core/models/athlete.dart';
import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/ui/common_components/text.dart';
import 'package:evento_core/ui/dashboard/athletes/athletes_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:country_flags/country_flags.dart';

class AthleteTile extends StatelessWidget {
  const AthleteTile({
    Key? key,
    required this.entrant,
    this.onFollow,
    required this.onTap,
  }) : super(key: key);
  final dynamic entrant;
  final VoidCallback onTap;
  final Function(Entrants)? onFollow;

  String raceNo() {
    if (entrant.disRaceNo == '') {
      return 'TBC';
    }
    return entrant.disRaceNo.toString();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AthletesController());

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.all(8),
      leading: entrant.profileImage == '' || onFollow != null
          ? null
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: SizedBox(
                      width: 14.w,
                      child: Image.network(
                        entrant.profileImage,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
      title: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    entrant.name,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    maxLines: 2,
                  ),
                  SizedBox(
                    height: 1.5,
                  ),
                  AppText(
                    entrant.info,
                    maxLines: 2,
                    color: Theme.of(context).brightness == Brightness.light
                        ? AppColors.darkgrey
                        : AppColors.splitLightGrey,
                    fontSize: 14,
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(0, 0, 6, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Demonstration flag - uncomment to test flag display
                    // ClipRRect(
                    //   borderRadius: BorderRadius.circular(4),
                    //  child: CountryFlag.fromCountryCode(
                    //     'nz',
                     //    height: 20,
                     //     width: 30,
                    //   ),
                     //),
                    // const SizedBox(width: 8),
                    if (entrant.country != null &&
                        entrant.country.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: CountryFlag.fromCountryCode(
                          entrant.country,
                          height: 20,
                          width: 30,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Container(
                      width: 48,
                      padding: EdgeInsets.symmetric(
                        vertical: .5.w,
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color:
                              (Theme.of(context).brightness == Brightness.light
                                      ? AppColors.greyLight
                                      : AppColors.greyLight)
                                  .withOpacity(0.3)),
                      child: Text(raceNo(),
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center),
                    ),
                  ],
                ),
                SizedBox(
                  width: 48,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (onFollow != null) {
                            onFollow!(entrant);
                          } else {
                            onTap();
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 1.5.w, vertical: 1.h),
                          child: Icon(
                            onFollow == null
                                ? CupertinoIcons.arrow_right_circle
                                : (entrant.isFollowed
                                    ? CupertinoIcons.checkmark_alt_circle_fill
                                    : CupertinoIcons.add_circled),
                            size: 6.5.w,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
