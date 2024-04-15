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
import 'package:flutter_map/flutter_map.dart' as flutter_map;
import 'package:geodart/geometries.dart' as geodart;
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:path/path.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class TrackingMapView extends StatelessWidget {
  const TrackingMapView({super.key});

  static double dgetBoundsZoomLevel(flutter_map.LatLngBounds bounds, mapDim) {
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

    createRoute() async {
      final positions = <List<Position>>[];
      for (List<LatLng> routePath in controller.routePathsCordinates.values) {
        positions.add(routePath.map((e) => Position(e.longitude, e.latitude)).toList());
      }

      controller.polylineAnnotationManager?.createMulti(positions
          .map((e) => PolylineAnnotationOptions(
          geometry: LineString(coordinates: e).toJson(),
          lineColor: AppColors.accentDark.value, lineWidth: 3))
          .toList());
    }

    createMarkers() async {
      for (MapPathMarkers marker in controller.mapPathMarkers) {
        Widget widget = CachedNetworkImage(
          imageUrl: marker.iconUrl,
          errorWidget: (context, url, error) =>
          const SizedBox(),
        );
        widget = Container(width: 30, height: 30, color: Colors.red);
        controller.screenshotController.captureFromLongWidget(widget).then((value) {
          controller.pointAnnotationManager?.create(PointAnnotationOptions(
              geometry: Point(
                  coordinates: Position(marker.latLng.longitude, marker.latLng.latitude)
              ).toJson(), image: value));
        });

      }
    }

    return Obx(() {
      List<LatLng> bounds = [];

      if (mapDataSnap.value == DataSnapShot.loaded) {
        final centerPoint = controller.initialPathCenterPoint();
        controller.routePathsCordinates.values.forEach((element) {
          bounds.addAll(element);
        });
        if(reloadController.reloaded) {
          reloadController.reloaded = false;
          try {
            /*Future.delayed(const Duration(milliseconds: 100), () {
                controller.mapController.move(centerPoint,
                    dgetBoundsZoomLevel(flutter_map.LatLngBounds.fromPoints(bounds),
                        {'height': MediaQuery
                            .of(context)
                            .size
                            .height,
                          'width': MediaQuery
                              .of(context)
                              .size
                              .width}) * 1.02);
              });*/
          } catch (e) {
            //
          }
        }

        return Stack(
          children: [
            MapWidget(
              //styleUri: MapboxStyles.SATELLITE,
              onMapCreated: (mapboxMap) {
                controller.mapboxMap = mapboxMap;
                mapboxMap.annotations.createPolylineAnnotationManager().then((value) async {
                  controller.polylineAnnotationManager = value;
                  createRoute();
                  /*controller.pointAnnotationManager
                        ?.addOnPointAnnotationClickListener(AnnotationClickListener());*/
                });
                mapboxMap.annotations.createPointAnnotationManager().then((value) async {
                  controller.pointAnnotationManager = value;
                  createMarkers();
                  /*controller.pointAnnotationManager
                        ?.addOnPointAnnotationClickListener(AnnotationClickListener());*/
                });
              },
              cameraOptions: CameraOptions(
                  center: Point(coordinates: centerPoint).toJson(),
                  zoom: dgetBoundsZoomLevel(flutter_map.LatLngBounds.fromPoints(bounds), {
                    'height' : MediaQuery.of(context).size.height,
                    'width' : MediaQuery.of(context).size.width})*1.02
              ),
            ),
            if(controller.pointAnnotationManager != null)
              for (AthleteTrackDetail trackDetail in controller.athleteTrackDetails.value)
                AnimatedMarkerView(trackDetail: trackDetail),
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
                )),
          ],
        );

        /* return Stack(
          children: [
            flutter_map.FlutterMap(
              children: [
                flutter_map.TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: const ['a', 'b', 'c']

                  // evento one pk.eyJ1IjoiZXZlbnRvbnoiLCJhIjoiY2lqdDViNTU2MGs0NnRobTU0aTRhanR2ayJ9.Jrzvj7GXCqWrgV3gWiIRsg
                  // "https://api.mapbox.com/styles/v1/eventonz/ckbu2fmwe02uw1iqq6gu54h9t/tiles/256/{z}/{x}/{y}@2x?access_token=${controller.accessToken}"

                  *//*urlTemplate: "https://api.mapbox.com/styles/v1/eventonz/ckbu2fmwe02uw1iqq6gu54h9t/wmts?access_token=pk.eyJ1IjoiZXZlbnRvbnoiLCJhIjoiY2lqdDViNTU2MGs0NnRobTU0aTRhanR2ayJ9.Jrzvj7GXCqWrgV3gWiIRsg",

                  //Openstreet

                      //"https://tile.openstreetmap.org/{z}/{x}/{y}.png"
                  subdomains: const ['a', 'b', 'c'],*//*

                ),
<<<<<<< HEAD
                flutter_map.MobileLayerTransformer(
=======
                PolylineLayer(
                  polylines: [
                    for (List<LatLng> routePath
                        in controller.routePathsCordinates.values)
                      Polyline(
                        points: routePath,
                        color: AppHelper.getRandomLightColor(),
                        //color: AppColors.accentDark,
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
>>>>>>> main
                  child: Stack(
                    children: [
                      for (AthleteTrackDetail trackDetail in controller.athleteTrackDetails.value)
                        AnimatedMarkerView(athleteTrackDetail: trackDetail)
                    ],
                  ),
                ),
                *//*for (AthleteTrackDetail trackDetail
                    in controller.athleteTrackDetails.value)
                  AnimatedMarkerView(athleteTrackDetail: trackDetail)*//*
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
            *//*Positioned(
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
            ),*//*
          ],
        );*/
      } else if (mapDataSnap.value == DataSnapShot.error) {
        return Center(child: RetryLayout(onTap: controller.getRoutePaths));
      } else {
        return const Center(child: CircularProgressIndicator());
      }
    });
  }
}

class AnimatedMarkerView extends StatefulWidget {

  final AthleteTrackDetail trackDetail;
  const AnimatedMarkerView({super.key, required this.trackDetail});

  @override
  State<AnimatedMarkerView> createState() => _AnimatedMarkerViewState();
}

class _AnimatedMarkerViewState extends State<AnimatedMarkerView> {

  AthleteTrackDetail get trackDetail => widget.trackDetail;

  late TrackingController controller = Get.find();

  PointAnnotationManager get annotationManager => controller.pointAnnotationManager!;

  PointAnnotation? annotation;

  List<LatLng> get routePath => controller.getAthleteRouthPath(trackDetail);
  geodart.LineString get lineStringPath => createLineStringPath();

  double oldProgress = 0;
  double currentProgress = 0;
  double currentSpeed = 0;

  bool isAnimatingMarker = false;
  double coveredDistance = 0;
  bool newProgressUpdate = false;

  bool disposed = false;

  @override
  void initState() {
    super.initState();
    setInitialRouteMarkerPath();
    setInitialDistance();
    controller.updateStream.stream.listen((event) {
      Future.delayed(const Duration(milliseconds: 0), () {
        oldProgress = trackDetail.location ?? 0;
        currentProgress = trackDetail.location ?? 0;
        currentSpeed = trackDetail.speed ?? 0;
        createLineStringPath();
        newProgressUpdate = true;
        moveMarker();
      });
    });
  }

  @override
  void didUpdateWidget(covariant AnimatedMarkerView oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldProgress = trackDetail.location ?? 0;
    currentProgress = trackDetail.location ?? 0;
    currentSpeed = trackDetail.speed ?? 0;
    createLineStringPath();
    newProgressUpdate = true;
    moveMarker();
  }

  @override
  void dispose() {
    super.dispose();
    disposed = true;
  }

  void setInitialRouteMarkerPath() {
    if(routePath.isNotEmpty) {
      final latLng = routePath.first;
      if (controller.locations[trackDetail.track] == null) {
        controller.setLocation(trackDetail.track, latLng);
      }
      if (annotation == null) {
        var widget = Container(
          width: 36,
          height: 36,
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
        );

        controller.screenshotController.captureFromWidget(widget).then((
            value) async {
          annotation = await annotationManager.create(PointAnnotationOptions(
            image: value,
            geometry: Point(
                coordinates: Position(latLng.longitude, latLng.latitude)
            ).toJson(),
          ));
        });
      }
    }
  }

  void setInitialDistance() {
    coveredDistance =
        (currentProgress / 100) * lineStringPath.length.toPrecision(3);
  }

  geodart.LineString createLineStringPath() {
    if(routePath.isEmpty) {
      return geodart.LineString([]);
    }
    final Path path = Path.from(routePath);
    final Path steps = path.equalize(6, smoothPath: true);
    return geodart.LineString(steps.coordinates
        .map((latLng) => geodart.Coordinate(latLng.latitude, latLng.longitude))
        .toList());
  }

  void moveMarker() async {
    if (isAnimatingMarker) return;
    isAnimatingMarker = true;
    while (coveredDistance < lineStringPath.length.toPrecision(4)) {
      if(disposed) {
        break;
      }
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
      annotation?.geometry = Point(
          coordinates: Position(latLng.longitude, latLng.latitude)
      ).toJson();
      if(annotation != null) {
        annotationManager.update(annotation!);
      } else {
        var widget = Container(
          width: 36,
          height: 36,
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
        );

        controller.screenshotController.captureFromWidget(widget).then((
            value) async {
          annotation = await annotationManager.create(PointAnnotationOptions(
            image: value,
            geometry: Point(
                coordinates: Position(latLng.longitude, latLng.latitude)
            ).toJson(),

          ));
        });
      }
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
    return SizedBox();
  }
}

