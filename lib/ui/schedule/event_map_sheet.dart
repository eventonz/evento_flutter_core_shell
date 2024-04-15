import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/core/utils/date_extensions.dart';
import 'package:evento_core/ui/common_components/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'schedule_controller.dart';

class EventMapSheet extends StatelessWidget {
  const EventMapSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ScheduleController controller = Get.find();
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(15.0),
      ),
      child: Container(
        color: Theme.of(context).brightness == Brightness.light
            ? AppColors.darkBlack
            : AppColors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppBar(
              backgroundColor: Theme.of(context).brightness == Brightness.light
                  ? AppColors.darkBlack
                  : AppColors.white,
              elevation: 0,
              leading: IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: Icon(
                    FeatherIcons.x,
                    color: AppColors.primary,
                  )),
              title: AppText(
                controller.eventDetails.title!,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    controller.getEventTimings(),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  AppText(
                    controller.eventDetails.datetime!
                        .withDateFormat(format: 'E, dd MMMM'),
                    color: AppColors.grey,
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  AppText(
                    (controller.eventDetails.location?.title ?? ''),
                  ),
                  AppText(
                    (controller.eventDetails.content ?? ''),
                    color: AppColors.grey,
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  controller.latLng == null
                      ? const SizedBox()
                      : SizedBox(
                          height: 40.h,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: FlutterMap(
                              options: MapOptions(
                                  center: controller.latLng!, zoom: 16),
                              children: [
                                TileLayer(
                                   urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                                    subdomains: const ['a', 'b', 'c']
                                
                                  /*urlTemplate:
                                      "https://api.mapbox.com/styles/v1/jethro0056/${controller.terrainStyle}/tiles/256/{z}/{x}/{y}@2x?access_token=${controller.accessToken}",
                                  subdomains: const ['a', 'b', 'c'],
                                  additionalOptions: {
                                    'mapStyleId': controller.terrainStyle,
                                    'accessToken': controller.accessToken,
                                  },
                                  */
                                ),
                                MarkerLayer(markers: [
                                  Marker(
                                    width: 10.w,
                                    height: 10.w,
                                    point: controller.latLng!,
                                    child:Icon(
                                      Icons.location_on,
                                      color: AppColors.primary,
                                      size: 10.w,
                                    ),
                                  )
                                ])
                              ],
                            ),
                          ),
                        )
                ],
              ),
            ),
            const Spacer(),
            controller.latLng == null
                ? const SizedBox()
                : SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: CupertinoButton(
                          color: AppColors.accentLight,
                          onPressed: controller.showDirectionsOnMap,
                          padding: const EdgeInsets.all(8),
                          child: const AppText(
                            'Get Directions',
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
