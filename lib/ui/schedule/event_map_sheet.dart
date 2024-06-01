import 'dart:io';

import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/core/utils/date_extensions.dart';
import 'package:evento_core/core/utils/helpers.dart';
import 'package:evento_core/ui/common_components/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'schedule_controller.dart';

class EventMapSheet extends StatelessWidget {
  final LatLng? latLng;
  const EventMapSheet({Key? key, required this.latLng}) : super(key: key);

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
                  SizedBox(
                    height: 2.h,
                  ),
                  controller.latLng == null
                      ? const SizedBox()
                      : SizedBox(
                          height: 40.h,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Platform.isIOS ? AppleMap(
                              rotateGesturesEnabled: false,
                              zoomGesturesEnabled: false,
                              pitchGesturesEnabled: false,
                              scrollGesturesEnabled: false,
                              initialCameraPosition: CameraPosition(

                                  target: LatLng(controller.latLng!.latitude, controller.latLng!.longitude), zoom: 16),
                              annotations: Set.of([if(controller.annotation.value != null)controller.annotation.value!]),
                            ) : MapWidget(
                              cameraOptions: CameraOptions(
                                zoom: 16,
                                center: Point(coordinates: Position(controller.latLng!.longitude, controller.latLng!.latitude)).toJson(),
                              ),
                                gestureRecognizers: Set.of([]),
                              onMapCreated: (map) async {
                                var image = await AppHelper.widgetToBytes(Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Icon(
                                    Icons.location_on,
                                    color: AppColors.primary,
                                    size: 10.w,
                                  ),
                                ));
                                map.annotations.createPointAnnotationManager().then((value) {
                                  value.create(PointAnnotationOptions(
                                    geometry: Point(coordinates: Position(controller.latLng!.longitude, controller.latLng!.latitude)).toJson(),
                                    image: image,
                                  ));
                                });
                              },
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
                          onPressed: () {
                            AppHelper.showDirectionsOnMap(latLng);
                          },
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
