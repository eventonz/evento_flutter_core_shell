import 'dart:io';

import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/core/utils/date_extensions.dart';
import 'package:evento_core/core/utils/helpers.dart';
import 'package:evento_core/l10n/app_localizations.dart';
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
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(15.0),
      ),
      child: Container(
        color: isLightMode ? const Color(0xFFF5F5F5) : AppColors.darkBlack,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppBar(
                      backgroundColor: isLightMode
                          ? const Color(0xFFF5F5F5)
                          : AppColors.darkBlack,
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
                        color:
                            isLightMode ? AppColors.darkBlack : AppColors.white,
                      ),
                    ),
                    // Event Details Card
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isLightMode
                              ? AppColors.white
                              : AppColors.darkBlack,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Time
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 20,
                                    color: isLightMode
                                        ? AppColors.primary
                                        : AppColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: AppText(
                                      controller.getEventTimings(),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: isLightMode
                                          ? AppColors.darkBlack
                                          : AppColors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Date
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 20,
                                    color: isLightMode
                                        ? AppColors.primary
                                        : AppColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: AppText(
                                      controller.eventDetails.datetime!
                                          .withDateFormat(format: 'E, dd MMMM'),
                                      fontSize: 16,
                                      color: isLightMode
                                          ? AppColors.darkgrey
                                          : AppColors.splitLightGrey,
                                    ),
                                  ),
                                ],
                              ),
                              // Location (only show if location exists and has valid title)
                              if (controller.eventDetails.location?.title
                                      ?.trim()
                                      .isNotEmpty ==
                                  true) ...[
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 20,
                                      color: isLightMode
                                          ? AppColors.primary
                                          : AppColors.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: AppText(
                                        controller
                                            .eventDetails.location!.title!,
                                        fontSize: 16,
                                        color: isLightMode
                                            ? AppColors.darkBlack
                                            : AppColors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Map Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: controller.latLng == null
                              ? const SizedBox()
                              : SizedBox(
                                  height: 40.h,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Platform.isIOS
                                        ? Obx(
                                            () => AppleMap(
                                              rotateGesturesEnabled: false,
                                              zoomGesturesEnabled: false,
                                              pitchGesturesEnabled: false,
                                              scrollGesturesEnabled: false,
                                              initialCameraPosition:
                                                  CameraPosition(
                                                      target: LatLng(
                                                          controller
                                                              .latLng!.latitude,
                                                          controller.latLng!
                                                              .longitude),
                                                      zoom: 16),
                                              annotations: Set.of([
                                                if (controller
                                                        .annotation.value !=
                                                    null)
                                                  controller.annotation.value!
                                              ]),
                                            ),
                                          )
                                        : MapWidget(
                                            cameraOptions: CameraOptions(
                                              zoom: 16,
                                              center: Point(
                                                  coordinates: Position(
                                                      controller
                                                          .latLng!.longitude,
                                                      controller
                                                          .latLng!.latitude)),
                                            ),
                                            gestureRecognizers: Set.of([]),
                                            onMapCreated: (map) async {
                                              var image =
                                                  await AppHelper.widgetToBytes(
                                                      Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 10.0),
                                                child: Icon(
                                                  Icons.location_on,
                                                  color: AppColors.primary,
                                                  size: 10.w,
                                                ),
                                              ));
                                              map.annotations
                                                  .createPointAnnotationManager()
                                                  .then((value) {
                                                value.create(
                                                    PointAnnotationOptions(
                                                  geometry: Point(
                                                      coordinates: Position(
                                                          controller.latLng!
                                                              .longitude,
                                                          controller.latLng!
                                                              .latitude)),
                                                  image: image,
                                                ));
                                              });
                                            },
                                          ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                    // Content Card
                    if (controller.eventDetails.content != null &&
                        controller.eventDetails.content!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isLightMode
                                ? AppColors.white
                                : AppColors.darkBlack,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.description,
                                      size: 20,
                                      color: isLightMode
                                          ? AppColors.primary
                                          : AppColors.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    AppText(
                                      'Details',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: isLightMode
                                          ? AppColors.darkBlack
                                          : AppColors.white,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                SingleChildScrollView(
                                  child: Text(
                                    controller.eventDetails.content!,
                                    style: TextStyle(
                                      color: isLightMode
                                          ? AppColors.darkBlack
                                          : AppColors.white,
                                      fontSize: 16,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
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
                          child: AppText(
                            AppLocalizations.of(context)!.getDirections,
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
