import 'dart:ffi';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:evento_core/core/db/app_db.dart';
import 'package:evento_core/core/models/athlete_track_detail.dart';
import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/core/utils/enums.dart';
import 'package:evento_core/ui/common_components/athlete_race_no.dart';
import 'package:evento_core/ui/common_components/retry_layout.dart';
import 'package:evento_core/ui/common_components/text.dart';
import 'package:evento_core/ui/dashboard/athletes_tracking/marker_animation/animated_marker_layer.dart';
import 'package:evento_core/ui/dashboard/athletes_tracking/marker_animation/animated_marker_layer_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'tracking_controller.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TrackingController controller = Get.find();
    return Container(
      color: AppColors.greyLight,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                _buildMapWidget(controller),
                StreamBuilder<List<AppAthleteDb>>(
                    stream: controller.watchFollowedAthletes(),
                    builder: (_, snap) {
                      if (snap.hasData) {
                        final entrants = snap.data!;
                        if (entrants.isEmpty) {
                          return const SizedBox();
                        }
                        entrants.sort((x, y) => x.raceno.compareTo(y.raceno));
                        return SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: CarouselSlider(
                                options: CarouselOptions(
                                    height: 20.h,
                                    enableInfiniteScroll: false,
                                    viewportFraction: 0.82,
                                    enlargeCenterPage: true,
                                    enlargeFactor: 0.15),
                                items: entrants.map((x) {
                                  return Builder(
                                    builder: (BuildContext context) {
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
                        return Center(
                            child: RetryLayout(onTap: controller.update));
                      } else {
                        return const Center(
                            child: CircularProgressIndicator.adaptive());
                      }
                    })
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapWidget(TrackingController controller) {
    final mapDataSnap = controller.mapDataSnap;
    return Obx(() {
      if (mapDataSnap.value == DataSnapShot.loaded) {
        final routePath = controller.routePath;
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: FlutterMap(
            options: MapOptions(
                center: routePath.first, zoom: 10, minZoom: 8, maxZoom: 18),
            children: [
              TileLayer(
                urlTemplate:
                    "https://api.mapbox.com/styles/v1/jethro0056/${controller.terrainStyle}/tiles/256/{z}/{x}/{y}@2x?access_token=${controller.accessToken}",
                subdomains: const ['a', 'b', 'c'],
                additionalOptions: {
                  'mapStyleId': controller.terrainStyle,
                  'accessToken': controller.accessToken,
                },
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                      points: routePath,
                      color: AppColors.secondary,
                      strokeWidth: 4.0,
                      useStrokeWidthInMeter: true),
                ],
              ),
              for (AthleteTrackDetail trackDetails
                  in controller.athleteTrackDetails.value)
                AnimatedMarkerLayer(
                  options: AnimatedMarkerLayerOptions(
                    duration: const Duration(
                      seconds: 0,
                    ),
                    location: trackDetails.location ?? 0,
                    routePath: routePath,
                    marker: Marker(
                      width: 30,
                      height: 30,
                      point: controller.getLatLngByThreshold(trackDetails),
                      builder: (context) => Center(
                        child: Icon(
                          Icons.fiber_manual_record,
                          color: Colors.redAccent,
                          size: 8.w,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      } else if (mapDataSnap.value == DataSnapShot.error) {
        return Center(
            child: RetryLayout(onTap: controller.createGeoJsonTracks));
      } else {
        return const Center(child: CircularProgressIndicator());
      }
    });
  }
}

class SliderAthleteTile extends StatelessWidget {
  const SliderAthleteTile(
      {Key? key, required this.onTap, required this.athelete, this.trackDetail})
      : super(key: key);
  final AppAthleteDb athelete;
  final AthleteTrackDetail? trackDetail;
  final VoidCallback onTap;

  String trackDetailsInfo() {
    final infoText = trackDetail!.info ?? '';
    return infoText.replaceAll('\\n', '\n').trim();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
            color: AppColors.white, borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: AppText(
                    athelete.name,
                    fontSize: 16,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                AthleteRaceNo(
                  number: athelete.raceno,
                  width: 16.w,
                )
              ],
            ),
          ),
          const Divider(
            height: 0,
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                athelete.profileImage.isEmpty
                    ? const SizedBox()
                    : Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: athelete.profileImage,
                              placeholder: (_, val) => const Center(
                                  child: CircularProgressIndicator.adaptive()),
                              errorWidget: (_, val, val2) => const Center(
                                  child: Center(
                                      child: Icon(FeatherIcons.alertTriangle))),
                              width: 18.w,
                              height: 18.w,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(
                            width: 16,
                          ),
                        ],
                      ),
                trackDetail == null
                    ? const SizedBox()
                    : AppText(
                        trackDetailsInfo(),
                      ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
