// ignore_for_file: invalid_use_of_protected_member

import 'package:cached_network_image/cached_network_image.dart';
import 'package:evento_core/core/models/athlete_track_detail.dart';
import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/core/utils/enums.dart';
import 'package:evento_core/core/utils/helpers.dart';
import 'package:evento_core/ui/common_components/retry_layout.dart';
import 'package:evento_core/ui/common_components/text.dart';
import 'package:evento_core/ui/dashboard/athletes_tracking/marker_animation/animated_marker_layer.dart';
import 'package:evento_core/ui/dashboard/athletes_tracking/marker_animation/animated_marker_layer_options.dart';
import 'package:evento_core/ui/dashboard/athletes_tracking/tracking_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geodart/geometries.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:path/path.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class TrackingMapView extends StatelessWidget {
  const TrackingMapView({super.key});

  @override
  Widget build(BuildContext context) {
    final TrackingController controller = Get.find();
    final mapDataSnap = controller.mapDataSnap;
    return Obx(() {
      if (mapDataSnap.value == DataSnapShot.loaded) {
        final centerPoint = controller.initialPathCenterPoint();
        if(!controller.fitted) {
          controller.fitted = true;
          List<LatLng> bounds = [];
          controller.routePathsCordinates.values.forEach((element) {
            bounds.addAll(element);
          });
          Future.delayed(const Duration(milliseconds: 100), () {
            controller.mapController.fitCamera(CameraFit.insideBounds(
              padding: const EdgeInsets.all(200),
              bounds: LatLngBounds.fromPoints(bounds)));
          });
        }
        return Stack(
          children: [
            FlutterMap(
              mapController: controller.mapController,
              options: MapOptions(
                center: centerPoint,
                zoom: 11,
                minZoom: 8,
                maxZoom: 18,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                      //"https://api.mapbox.com/styles/v1/jethro0056/${controller.currentStyle.value}/tiles/256/{z}/{x}/{y}@2x?access_token=${controller.accessToken}",
                  subdomains: const ['a', 'b', 'c'],
                  additionalOptions: {
                    'mapStyleId': controller.terrainStyle,
                    'accessToken': controller.accessToken,
                  },
                ),
                PolylineLayer(
                  polylines: [
                    for (List<LatLng> routePath
                        in controller.routePathsCordinates.values)
                      Polyline(
                        points: routePath,
                        //color: AppHelper.getRandomLightColor(),
                        color: AppColors.accentDark,
                        strokeWidth: 2.0,
                      ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    for (MapPathMarkers marker in controller.mapPathMarkers)
                      Marker(
                          point: marker.latLng,
                          child: CachedNetworkImage(
                              imageUrl: marker.iconUrl,
                              errorWidget: (context, url, error) =>
                                  const SizedBox(),
                            ))
                  ],
                ),
                MobileLayerTransformer(
                  child: Stack(
                    children: [
                      for (AthleteTrackDetail trackDetail in controller.athleteTrackDetails.value)
                        AnimatedMarkerView(athleteTrackDetail: trackDetail)
                    ],
                  ),
                ),
                /*for (AthleteTrackDetail trackDetail
                    in controller.athleteTrackDetails.value)
                  AnimatedMarkerView(athleteTrackDetail: trackDetail)*/
              ],
            ),
            // Positioned(
            //   top: 2.w,
            //   child: SafeArea(
            //     child: CupertinoButton(
            //         padding: const EdgeInsets.all(0),
            //         color: AppColors.white,
            //         onPressed: controller.getRoutePaths,
            //         child: const Icon(
            //           Icons.layers_outlined,
            //           color: AppColors.black,
            //         )),
            //   ),
            // ),
            Positioned(
              right: 2.w,
              top: 2.w,
              child: SafeArea(
                child: CupertinoButton(
                    padding: const EdgeInsets.all(0),
                    color: AppColors.white,
                    onPressed: controller.changeMapStyle,
                    child: const Icon(
                      Icons.layers_outlined,
                      color: AppColors.black,
                    )),
              ),
            ),
          ],
        );
      } else if (mapDataSnap.value == DataSnapShot.error) {
        return Center(child: RetryLayout(onTap: controller.getRoutePaths));
      } else {
        return const Center(child: CircularProgressIndicator());
      }
    });
  }
}

class AnimatedMarkerView extends StatefulWidget {
  const AnimatedMarkerView({super.key, required this.athleteTrackDetail});

  final AthleteTrackDetail athleteTrackDetail;

  @override
  State<AnimatedMarkerView> createState() => _AnimatedMarkerViewState();
}

class _AnimatedMarkerViewState extends State<AnimatedMarkerView> {
  AthleteTrackDetail get trackDetail => widget.athleteTrackDetail;
  late TrackingController controller = Get.find();

  List<LatLng> get routePath => controller.getAthleteRouthPath(trackDetail);
  LineString get lineStringPath => createLineStringPath();

  double oldProgress = 0;
  double currentProgress = 0;
  double currentSpeed = 0;

  bool isAnimatingMarker = false;
  double coveredDistance = 0;
  bool newProgressUpdate = false;

  @override
  void initState() {
    super.initState();
    setInitialRouteMarkerPath();
    setInitialDistance();
    controller.updateStream.stream.listen((event) {
      Future.delayed(const Duration(milliseconds: 0), () {
        setState(() {
          oldProgress = widget.athleteTrackDetail.location ?? 0;
          currentProgress = widget.athleteTrackDetail.location ?? 0;
          currentSpeed = widget.athleteTrackDetail.speed ?? 0;
          createLineStringPath();
          newProgressUpdate = true;
          moveMarker();
        });
      });
    });
  }


  @override
  void didUpdateWidget(covariant AnimatedMarkerView oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldProgress = widget.athleteTrackDetail.location ?? 0;
    currentProgress = widget.athleteTrackDetail.location ?? 0;
    currentSpeed = widget.athleteTrackDetail.speed ?? 0;
    createLineStringPath();
    newProgressUpdate = true;
    moveMarker();
  }

  void setInitialRouteMarkerPath() {
    final latLng = routePath.first;
    if (controller.locations[trackDetail.track] == null) {
      controller.setLocation(trackDetail.track, latLng);
    }
  }

  void setInitialDistance() {
    coveredDistance =
        (currentProgress / 100) * lineStringPath.length.toPrecision(3);
  }

  LineString createLineStringPath() {
    final Path path = Path.from(routePath);
    final Path steps = path.equalize(6, smoothPath: true);
    return LineString(steps.coordinates
        .map((latLng) => Coordinate(latLng.latitude, latLng.longitude))
        .toList());
  }

  void moveMarker() async {
    if (isAnimatingMarker) return;
    isAnimatingMarker = true;
    while (coveredDistance < lineStringPath.length.toPrecision(4)) {
      if (newProgressUpdate) {
        setInitialDistance();
        newProgressUpdate = false;
      }
      coveredDistance =
          getNewDistanceAfterOneSec() + coveredDistance.toPrecision(4);
      print(DateTime.now());
      print('---- UPDATE for  ---' + trackDetail.track);
      print(coveredDistance.toPrecision(4));
      print('---');
      final latLng = getLatlngFromDistance();
      //if (mounted) {
        await controller.setLocation(trackDetail.track, latLng, wait: true);
      setState(() {

        });
      //}

    }
    isAnimatingMarker = false;
  }

  LatLng getLatlngFromDistance() {
    final coordinate =
        lineStringPath.along(coveredDistance.toPrecision(4)).coordinate;
    return LatLng(coordinate.latitude, coordinate.longitude);
  }

  double getNewDistanceAfterOneSec() {
    return currentSpeed / 3600 * 1000;
  }

  @override
  Widget build(BuildContext context) {

    return AnimatedMarkerLayer(
      options: AnimatedMarkerLayerOptions(
          duration: Duration(milliseconds: 1000),
          routePath: controller.getAthleteRouthPath(trackDetail),
          trackDetail: trackDetail,
          marker: Marker(
              rotate: true,
              width: trackDetail.isRaceNoBig() ? 70 : 35,
              height: 35,
              point: LatLng(controller.locations[trackDetail.track]?.latitude ?? 0, controller.locations[trackDetail.track]?.longitude ?? 0),
              child: Container(
                  decoration: BoxDecoration(
                      color: AppColors.accentLight,
                      borderRadius: BorderRadius.circular(40)),
                  child: Center(
                    child: AppText(
                      trackDetail.track,
                      fontSize: 16,
                      color: AppColors.white
                    ),
                  ),
                )
          )),
    );
  }
}
