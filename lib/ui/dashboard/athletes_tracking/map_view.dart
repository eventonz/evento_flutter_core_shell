// ignore_for_file: invalid_use_of_protected_member

import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:evento_core/core/models/athlete_track_detail.dart';
import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/core/services/config_reload/config_reload_service.dart';
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

  static double dgetBoundsZoomLevel(LatLngBounds bounds, mapDim) {
    var WORLD_DIM = Map.from(mapDim);
    WORLD_DIM['width'] = WORLD_DIM['width'];
    WORLD_DIM['height'] = WORLD_DIM['height'];
    var ZOOM_MAX = 21;

    double latRad(lat) {
      var sin2 = sin(lat * pi / 180);
      var radX2 = log((1 + sin2) / (1 - sin2)) / 2;
      return max(min(radX2, pi), - pi) / 2;
    }

    double zoom(mapPx, worldPx, fraction) {
      return (log(mapPx / worldPx / fraction) / ln2).floorToDouble();
    }

    var ne = bounds.northEast;
    var sw = bounds.southWest;

    var latFraction = (latRad(ne.latitude) - latRad(sw.latitude)) / pi;

    var lngDiff = ne.longitude - sw.longitude;
    var lngFraction = ((lngDiff < 0) ? (lngDiff + 360) : lngDiff) / 360;

    double latZoom = zoom(mapDim['height'], WORLD_DIM['height'], latFraction);
    double lngZoom = zoom(mapDim['width'], WORLD_DIM['width'], lngFraction);

    return min(latZoom, lngZoom);
  }

  @override
  Widget build(BuildContext context) {
    final TrackingController controller = Get.find();
    final ConfigReload reloadController = Get.find();
    final mapDataSnap = controller.mapDataSnap;

    return Obx(() {
      List<LatLng> bounds = [];

      print('bounds');

      if (mapDataSnap.value == DataSnapShot.loaded) {
        final centerPoint = controller.initialPathCenterPoint();
          controller.routePathsCordinates.values.forEach((element) {
            bounds.addAll(element);
          });
          if(reloadController.reloaded) {
            reloadController.reloaded = false;
            try {
              Future.delayed(const Duration(milliseconds: 100), () {
                controller.mapController.move(centerPoint,
                    dgetBoundsZoomLevel(LatLngBounds.fromPoints(bounds),
                        {'height': MediaQuery
                            .of(context)
                            .size
                            .height,
                          'width': MediaQuery
                              .of(context)
                              .size
                              .width}) * 1.02);
              });
            } catch (e) {
              //
            }
          }

        for (String routePath
        in controller.routePathsCordinates.keys) {
          print(routePath);
        }
        print('hha');

        return Stack(
          children: [
            FlutterMap(
              mapController: controller.mapController,
              options: MapOptions(
                initialCenter: centerPoint,
                initialZoom: dgetBoundsZoomLevel(LatLngBounds.fromPoints(bounds),
    {'height' : MediaQuery.of(context).size.height,
      'width' : MediaQuery.of(context).size.width})*1.02,
                minZoom: 8,
                maxZoom: 18,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: const ['a', 'b', 'c']

                  // evento one pk.eyJ1IjoiZXZlbnRvbnoiLCJhIjoiY2lqdDViNTU2MGs0NnRobTU0aTRhanR2ayJ9.Jrzvj7GXCqWrgV3gWiIRsg
                  // "https://api.mapbox.com/styles/v1/eventonz/ckbu2fmwe02uw1iqq6gu54h9t/tiles/256/{z}/{x}/{y}@2x?access_token=${controller.accessToken}"

                  /*urlTemplate: "https://api.mapbox.com/styles/v1/eventonz/ckbu2fmwe02uw1iqq6gu54h9t/wmts?access_token=pk.eyJ1IjoiZXZlbnRvbnoiLCJhIjoiY2lqdDViNTU2MGs0NnRobTU0aTRhanR2ayJ9.Jrzvj7GXCqWrgV3gWiIRsg",
       
                  //Openstreet

                      //"https://tile.openstreetmap.org/{z}/{x}/{y}.png"
                  subdomains: const ['a', 'b', 'c'],*/

                ),
                PolylineLayer(
                  polylines: [
                    for (List<LatLng> routePath
                        in controller.routePathsCordinates.values)
                      Polyline(
                        points: routePath,
                        color: AppColors.accentDark,
                        // change the color here 
                        //color: AppColors.accentDark,
                        // color: AppHelper.getRandomLightColor(),
                        strokeWidth: 3.5,
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
            /*Positioned(
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
            ),*/
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
    if(routePath.isNotEmpty) {
      final latLng = routePath.first;
      if (controller.locations[trackDetail.track] == null) {
        controller.setLocation(trackDetail.track, latLng);
      }
    }
  }

  void setInitialDistance() {
    coveredDistance =
        (currentProgress / 100) * lineStringPath.length.toPrecision(3);
  }

  LineString createLineStringPath() {
    if(routePath.isEmpty) {
      return LineString([]);
    }
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
      print(trackDetail.toJson());
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
    print(lineStringPath);
    print(trackDetail.path);
    print('hello');
    return AnimatedMarkerLayer(
      options: AnimatedMarkerLayerOptions(
          duration: Duration(milliseconds: 1000),
          routePath: controller.getAthleteRouthPath(trackDetail),
          trackDetail: trackDetail,
          marker: Marker(
              rotate: true,
              width: trackDetail.isRaceNoBig() ? 70 : 40,
              height: 40,
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
