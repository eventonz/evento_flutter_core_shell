// ignore_for_file: invalid_use_of_protected_member

import 'dart:io';

import 'package:apple_maps_flutter/apple_maps_flutter.dart' as apple_maps;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:evento_core/core/db/app_db.dart';
import 'package:evento_core/core/models/athlete_track_detail.dart';
import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/l10n/app_localizations.dart';
import 'package:evento_core/ui/common_components/athlete_race_no.dart';
import 'package:evento_core/ui/common_components/retry_layout.dart';
import 'package:evento_core/ui/common_components/text.dart';
import 'package:evento_core/ui/dashboard/athletes_tracking/android_map_view.dart';
import 'package:evento_core/ui/dashboard/athletes_tracking/apple_map_view.dart';
import 'package:evento_core/ui/dashboard/athletes_tracking/map_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'tracking_controller.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TrackingController controller = Get.find();
    return Container(
      color: AppColors.greyLight,
      child: Stack(
        children: [
          if (Platform.isIOS) const AppleMapView() else const AndroidMapView(),
          StreamBuilder<List<AppAthleteDb>>(
              stream: controller.watchFollowedAthletes(),
              builder: (_, snap) {
                if (snap.hasData) {
                  final entrants = snap.data!;
                  if (entrants.isEmpty) {
                    return const SizedBox();
                  }
                  entrants.sort((x, y) => x.raceno.compareTo(y.raceno));
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    print('athletes updating 1');
                    controller.getAthleteTrackingInfo(firstTime: true);
                  });
                  List<LatLng> bounds2 = [];
                  controller.routePathsCordinates.values.forEach((element) {
                    bounds2.addAll(element);
                  });
                  return SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: CarouselSlider(
                          carouselController: controller.carouselController,
                          options: CarouselOptions(
                              height: 12.h,
                              enableInfiniteScroll: false,
                              viewportFraction: 0.82,
                              enlargeCenterPage: true,
                              onPageChanged: (index, reason) {
                                //try {
                                final trackDetail = controller
                                    .athleteTrackDetails.value
                                    .where((element) {
                                  print('element.track');
                                  print(element.track);
                                  print(entrants[index].athleteId);
                                  return element.track ==
                                      entrants[index].athleteId;
                                }).first;
                                LatLng latLng;
                                if (controller.locations[trackDetail.track] ==
                                        null ||
                                    controller
                                        .getAthleteRouthPath(trackDetail)
                                        .isEmpty) {
                                  latLng = LatLng(
                                      controller
                                          .initialPathCenterPoint()
                                          .lat
                                          .toDouble(),
                                      controller
                                          .initialPathCenterPoint()
                                          .lng
                                          .toDouble());
                                } else {
                                  latLng = LatLng(
                                      controller.locations[trackDetail.track]
                                              ?.latitude ??
                                          0,
                                      controller.locations[trackDetail.track]
                                              ?.longitude ??
                                          0);
                                }

                                double zoom = controller
                                            .locations[trackDetail.track] ==
                                        null
                                    ? TrackingMapView.dgetBoundsZoomLevel(
                                            LatLngBounds.fromPoints(bounds2), {
                                          'height': MediaQuery.of(context)
                                              .size
                                              .height,
                                          'width':
                                              MediaQuery.of(context).size.width
                                        }) *
                                        1.02
                                    : 15;
                                print('fly');
                                if (Platform.isIOS) {
                                  controller.appleMapController?.animateCamera(
                                      apple_maps.CameraUpdate.newCameraPosition(
                                          apple_maps.CameraPosition(
                                              target: apple_maps.LatLng(
                                                  latLng.latitude,
                                                  latLng.longitude),
                                              zoom: zoom)));
                                } else {
                                  controller.mapboxMap!.flyTo(
                                      CameraOptions(
                                        zoom: zoom,
                                        center: Point(
                                            coordinates: Position(
                                                latLng.longitude,
                                                latLng.latitude)),
                                      ),
                                      MapAnimationOptions(
                                        duration: 500,
                                        startDelay: 0,
                                      ));
                                }
                                /*} catch (e) {
                                  print(e);
                                }*/
                                //controller.mapController.move(controller.mapPathMarkers[index].latLng, 13);
                              },
                              enlargeFactor: 0.15),
                          items: entrants.map((x) {
                            return Builder(
                              builder: (BuildContext context) {
                                print('builder updating');
                                return Obx(() => SliderAthleteTile(
                                      onTap: () =>
                                          controller.toAthleteDetails(x),
                                      athelete: x,
                                      trackDetail:
                                          controller.findTrackDetail(x),
                                    ));
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  );
                } else if (snap.hasError) {
                  return Center(child: RetryLayout(onTap: controller.update));
                } else {
                  return const Center(
                      child: CircularProgressIndicator.adaptive());
                }
              })
        ],
      ),
    );
  }
}

class SliderAthleteTile extends StatelessWidget {
  const SliderAthleteTile(
      {Key? key, required this.onTap, required this.athelete, this.trackDetail})
      : super(key: key);
  final AppAthleteDb athelete;
  final AthleteTrackDetail? trackDetail;
  final VoidCallback onTap;

  String trackDetailsInfo(BuildContext context) {
    final infoText = trackDetail!.info ?? '';
    return infoText.isEmpty
        ? AppLocalizations.of(context)!.trackingNotAvailable
        : infoText.replaceAll('\\n', '\n').trim();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.hardEdge,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.light
                ? AppColors.greyLighter
                : AppColors.darkBlack,
            borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 50.w,
                  child: AppText(
                    athelete.name,
                    fontSize: 16,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                AthleteRaceNo(
                  number: athelete.disRaceNo ?? '',
                  width: 18.w,
                )
              ],
            ),
          ),
          Divider(
              height: 1,
              thickness: .5,
              color: Theme.of(context).brightness == Brightness.light
                  ? AppColors.greyLight
                  : AppColors.darkgrey),
          Padding(
            padding: const EdgeInsets.all(12),
            child: trackDetail != null
                ? AppText(
                    trackDetailsInfo(context),
                  )
                : const SizedBox(),
          ),
        ]),
      ),
    );
  }
}
