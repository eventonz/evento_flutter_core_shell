// ignore_for_file: invalid_use_of_protected_member

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:apple_maps_flutter/apple_maps_flutter.dart' as apple_maps;
import 'package:collection/collection.dart';
import 'package:evento_core/core/models/athlete_track_detail.dart';
import 'package:evento_core/core/res/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:evento_core/core/services/config_reload/config_reload_service.dart';
import 'package:evento_core/core/utils/enums.dart';
import 'package:evento_core/core/utils/helpers.dart';
import 'package:evento_core/ui/common_components/retry_layout.dart';
import 'package:evento_core/ui/common_components/text.dart';
import 'package:evento_core/ui/dashboard/athletes_tracking/tracking_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as flutter_map;
import 'package:geodart/geometries.dart' as geodart;
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:responsive_sizer/responsive_sizer.dart';


class TrackingMapView extends StatefulWidget {
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
  State<TrackingMapView> createState() => _TrackingMapViewState();
}

class _TrackingMapViewState extends State<TrackingMapView> {

  final TrackingController controller = Get.find();

  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    controller.polylines.value.clear();
    controller.annotations.value.clear();
    if(Platform.isIOS) {
      Timer.periodic(const Duration(seconds: 1), (timer) async {
        final mapDataSnap = controller.mapDataSnap;
        print('bb ${controller.athleteTrackDetails.value.length}');
        if (mapDataSnap.value == DataSnapShot.loaded &&
            controller.athleteTrackDetails.value.isNotEmpty) {
          timer.cancel();
          print('CANCELLED');
          setInitialDistances();
          await setInitialRouteMarkerPaths();

          Future.delayed(const Duration(milliseconds: 100), () {
            updateTrackProgress();
            updateMarkers();
            controller.updateStream.stream.listen((event) {
              Future.delayed(const Duration(milliseconds: 0), () {

              });
            });
            //controller.updateStream.add(1);

          });
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant TrackingMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    //updateMarkers();
  }


  void updateTrackProgress() {
    for (var trackDetail in controller.athleteTrackDetails.value) {
      final progress = controller.trackProgressMap[trackDetail.track];
      if(progress != null) {
        progress.oldProgress = trackDetail.location ?? 0;
        progress.currentProgress = trackDetail.location ?? 0;
        progress.currentSpeed = trackDetail.speed ?? 0;
        progress.newProgressUpdate = true;
      }
    }
  }

  Future<void> setInitialRouteMarkerPaths() async {
    for (var trackDetail in controller.athleteTrackDetails.value) {
      final routePath = controller.getAthleteRouthPath(trackDetail);
      if (routePath.isNotEmpty) {
        print('routePath');
        final progress = controller.trackProgressMap[trackDetail.track];
        var latLng = routePath.first;
        if(progress != null) {
          final geodart.LineString lineStringPath = createLineStringPath(routePath);
          latLng = getLatlngFromDistance(lineStringPath, progress.coveredDistance);
        }
        controller.setLocation(trackDetail.track, latLng);
        var bytes = await AppHelper.widgetToBytes(Container(
          width: trackDetail.marker_text.length > 3 ? (trackDetail.marker_text.length)*13 : 36,
          height: 36,
          decoration: BoxDecoration(
              color: AppColors.accentLight,
              borderRadius: BorderRadius.circular(40)),
          child: Center(
            child: AppText(
                trackDetail.marker_text,
                fontSize: 16,
                color: AppColors.white
            ),
          ),
        ));
        var marker = apple_maps.Annotation(
          annotationId: apple_maps.AnnotationId(trackDetail.track),
          position: apple_maps.LatLng(latLng.latitude, latLng.longitude),
          infoWindow: apple_maps.InfoWindow(title: trackDetail.track),
          icon: apple_maps.BitmapDescriptor.fromBytes(bytes),
        );
        controller.addAnnotation(apple_maps.AnnotationId(trackDetail.track), marker);
        setState(() {

        });
        print(controller.annotations.value.length);
        print('controller.annotations.value.length');
      }
    }
  }

  geodart.LineString createLineStringPath(List<LatLng> routePath) {
    if (routePath.isEmpty) {
      return geodart.LineString([]);
    }
    final path = Path.from(routePath);
    final steps = path.equalize(6, smoothPath: true);
    return geodart.LineString(steps.coordinates
        .map((latLng) => geodart.Coordinate(latLng.latitude, latLng.longitude))
        .toList());
  }

  void setInitialDistances() {
    for (var trackDetail in controller.athleteTrackDetails.value) {
      final progress = TrackProgress(
        coveredDistance: (trackDetail.location ?? 0) / 100 *
            createLineStringPath(controller.getAthleteRouthPath(trackDetail)).length.toPrecision(3),
      );

      controller.trackProgressMap[trackDetail.track] = progress;
    }
  }

  LatLng getLatlngFromDistance(geodart.LineString lineStringPath, double coveredDistance) {
    final coordinate =
        lineStringPath.along(coveredDistance.toPrecision(4)).coordinate;
    return LatLng(coordinate.latitude, coordinate.longitude);
  }

  double getNewDistanceAfterOneSec(double speed) {
    return speed / 3600 * 1000;
  }

  @override
  void dispose() {
    _isDisposed = true; // Set the flag to true to stop the loop
    super.dispose();
  }

  void updateMarkers() {
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_isDisposed) {
        timer.cancel();
        print('Timer cancelled because _isDisposed is true');
        return;
      }

      for (var trackDetail in controller.athleteTrackDetails.value) {
        if (_isDisposed) {
          timer.cancel();
          print('Timer cancelled during iteration because _isDisposed is true');
          break;
        }

        var progress = controller.trackProgressMap[trackDetail.track];

        if(progress == null) {
          final routePath = controller.getAthleteRouthPath(trackDetail);

          final progressA = TrackProgress(
            coveredDistance: (trackDetail.location ?? 0) / 100 *
                createLineStringPath(controller.getAthleteRouthPath(trackDetail)).length.toPrecision(3),
          );

          controller.trackProgressMap[trackDetail.track] = progressA;

          progress = controller.trackProgressMap[trackDetail.track]!;

          if (routePath.isNotEmpty) {
            print('routePath');
            final latLng = routePath.first;
            controller.setLocation(trackDetail.track, latLng);
            var bytes = await AppHelper.widgetToBytes(Container(
              width: trackDetail.marker_text.length > 3 ? (trackDetail.marker_text.length)*13 : 36,
              height: 36,
              decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(40)),
              child: Center(
                child: AppText(
                    trackDetail.marker_text,
                    fontSize: 16,
                    color: AppColors.white
                ),
              ),
            ));
            var marker = apple_maps.Annotation(
              annotationId: apple_maps.AnnotationId(trackDetail.track),
              position: apple_maps.LatLng(latLng.latitude, latLng.longitude),
              infoWindow: apple_maps.InfoWindow(title: trackDetail.track),
              icon: apple_maps.BitmapDescriptor.fromBytes(bytes),
            );
            controller.addAnnotation(apple_maps.AnnotationId(trackDetail.track), marker);
            setState(() {

            });
            print(controller.annotations.value.length);
            print('controller.annotations.value.length');
          }
        }

        final routePath = controller.getAthleteRouthPath(trackDetail);

        print('routePath ${trackDetail.track} ${trackDetail.path}: $routePath');
        if (routePath.isNotEmpty) {
          final geodart.LineString lineStringPath = createLineStringPath(routePath);

          print('lineString ${trackDetail.track} ${lineStringPath}');

          double coveredDistance = progress!.coveredDistance;
          if (coveredDistance < lineStringPath.length.toPrecision(4)) {
            print('track '+ trackDetail.track);
            print('location ${trackDetail.location}');
            print('speed: ${(getNewDistanceAfterOneSec(progress.currentSpeed))}');
            print('distance: $coveredDistance ${lineStringPath.length.toPrecision(4)}');

            if (progress.newProgressUpdate) {
              progress.coveredDistance =
                  (progress.currentProgress / 100) *
                      lineStringPath.length.toPrecision(3);
              progress.newProgressUpdate = false;
            }
            print('distance2: ${getNewDistanceAfterOneSec(progress.currentSpeed)}');

            progress.coveredDistance =
                getNewDistanceAfterOneSec(progress.currentSpeed) +
                    progress.coveredDistance.toPrecision(4);
            final latLng = getLatlngFromDistance(lineStringPath, progress.coveredDistance);

            await controller.setLocation(trackDetail.track, latLng, wait: false, update: false);

            if (controller.annotations.value[apple_maps.AnnotationId(trackDetail.track)] != null) {
              print('annotation update');
              controller.addAnnotation(
                apple_maps.AnnotationId(trackDetail.track),
                controller.annotations.value[apple_maps.AnnotationId(trackDetail.track)]!
                    .copyWith(positionParam: apple_maps.LatLng(latLng.latitude, latLng.longitude)),
              );
            }

            progress.oldProgress = trackDetail.location ?? 0;
            progress.currentProgress = trackDetail.location ?? 0;
            progress.currentSpeed = trackDetail.speed ?? 0;
            createLineStringPath(controller.getAthleteRouthPath(trackDetail));
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final TrackingController controller = Get.find();
    final ConfigReload reloadController = Get.find();
    final mapDataSnap = controller.mapDataSnap;

    print(controller.trackingDetails?.updateFreq);
    print('updateFreq');

    createRoute() async {


      final positions = <List<Position>>[];
      final positionsApple = <List<apple_maps.LatLng>>[];
      int i = 0;
      for (List<LatLng> routePath in controller.routePathsCordinates.values) {
        positionsApple.add([]);
        routePath.forEach((latLng) {
          positionsApple[i].add(apple_maps.LatLng(latLng.latitude, latLng.longitude));
        });
        positions.add(routePath.map((e) => Position(e.longitude, e.latitude)).toList());
        i++;
      }

      if(Platform.isIOS) {

        positionsApple.forEachIndexed((index, element) {
          final String polylineIdVal = 'polyline_id_${controller.polylines.value.length}';
          final apple_maps.PolylineId polylineId = apple_maps.PolylineId(polylineIdVal);

          final apple_maps.Polyline polyline = apple_maps.Polyline(
            polylineId: polylineId,
            consumeTapEvents: true,
            color: controller.routePathsColors.values.toList()[index] != null ? AppHelper.hexToColor(controller.routePathsColors.values.toList()[index]) : AppColors.accentDark,
            width: 3,
            points: positionsApple[index],
            onTap: () {

            },
          );

          controller.addPolyline(polylineId, polyline);
        });
        return;
      }

      controller.polylineAnnotationManager?.createMulti(List.generate(positions.length, (index) => PolylineAnnotationOptions(
          geometry: LineString(coordinates: positions[index]).toJson(),

          lineColor: controller.routePathsColors.values.toList()[index] != null ? AppHelper.hexToColor(controller.routePathsColors.values.toList()[index]).value : AppColors.accentDark.value, lineWidth: 3))
          .toList());
    }

    createMarkers() async {

      for (MapPathMarkers marker in controller.mapPathMarkers) {

        print('marker ${marker.latLng.toJson()}');

        if(Platform.isIOS) {
          http.Response response = await http.get(Uri.parse(marker.iconUrl));
          Widget widget = Image.memory(
              response.bodyBytes, width: 30, height: 30);
          final String annotationIdVal = 'annotation_id_${controller.annotations.value.length}';
          final apple_maps.AnnotationId polygonId = apple_maps.AnnotationId(annotationIdVal);
            var bytes = await AppHelper.widgetToBytes(widget);
            final apple_maps.Annotation annotation = apple_maps.Annotation(
              annotationId: polygonId,
              icon: apple_maps.BitmapDescriptor.fromBytes(bytes),
              //icon: apple_maps.BitmapDescriptor.defaultAnnotation,
              position: apple_maps.LatLng( marker.latLng.latitude, marker.latLng.longitude),
              onTap: () {

              },
            );
            controller.addAnnotation(polygonId, annotation);
        } else {
          http.Response response = await http.get(Uri.parse(marker.iconUrl));
          Widget widget = Image.memory(
              response.bodyBytes, width: 30, height: 30);
          controller.screenshotController.captureFromWidget(widget).then((
              value) {
            controller.pointAnnotationManager?.create(PointAnnotationOptions(
                geometry: Point(
                    coordinates: Position(
                        marker.latLng.longitude, marker.latLng.latitude)
                ).toJson(), image: value));
          });
        }
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

        if(Platform.isIOS) {

          return Stack(
            children: [
              Obx(
                () => apple_maps.AppleMap(
                  myLocationEnabled: true,

                  mapType: controller.currentStyle.value == 0 ? apple_maps.MapType.standard : (controller.currentStyle.value == 1 ? apple_maps.MapType.hybrid : apple_maps.MapType.satellite),
                  onMapCreated: (appleMapController) async {
                    controller.appleMapController = appleMapController;
                    createRoute();
                    createMarkers();


                    /*appleMapController.location.updateSettings(LocationComponentSettings(
                        enabled: true,
                        pulsingEnabled: true
                    ));*/
                  },

                  polylines: Set<apple_maps.Polyline>.of(controller.polylines.value.values),
                  annotations: controller.annotations.value.values.toSet(),
                  initialCameraPosition: apple_maps.CameraPosition(
                      target: apple_maps.LatLng(centerPoint.lat.toDouble(), centerPoint.lng.toDouble()),
                      zoom: TrackingMapView.dgetBoundsZoomLevel(flutter_map.LatLngBounds.fromPoints(bounds), {
                        'height' : MediaQuery.of(context).size.height,
                        'width' : MediaQuery.of(context).size.width})*1.02
                  ),
                ),
              ),
              if(/*controller.pointAnnotationManager != null*/false)
                for (AthleteTrackDetail trackDetail in controller.athleteTrackDetails.value)
                  AnimatedMarkerView(trackDetail: trackDetail),

              Positioned(
                  right: 2.w,
                  top: 2.w,
                  child: SafeArea(
                    child: Column(
                      children: [
                        CupertinoButton(
                            padding: const EdgeInsets.all(0),
                            color: AppColors.white,
                            onPressed: controller.changeMapStyle,
                            child: SvgPicture.asset(AppHelper.getSvg('layers'), width: 28,)),
                        const SizedBox(height: 16),
                        CupertinoButton(
                            padding: const EdgeInsets.all(0),
                            color: AppColors.white,
                            onPressed: controller.showUserLocation,
                            child: SvgPicture.asset(AppHelper.getSvg('near_me'), width: 28,)),
                      ],
                    ),
                  )),
            ],
          );
        }

        return Obx(
          () => Stack(
            children: [
              MapWidget(
                styleUri: controller.currentStyle.value == 0 ? MapboxStyles.MAPBOX_STREETS : (controller.currentStyle.value == 1 ? MapboxStyles.STANDARD : MapboxStyles.SATELLITE),
                onMapCreated: (mapboxMap) {
                  mapboxMap.location.updateSettings(LocationComponentSettings(
                    enabled: true,
                    pulsingEnabled: true
                  ));
                  controller.mapboxMap = mapboxMap;
                  mapboxMap.annotations.createPolylineAnnotationManager().then((value) async {
                    controller.polylineAnnotationManager = value;
                    createRoute();
                    /*controller.pointAnnotationManager
                          ?.addOnPointAnnotationClickListener(AnnotationClickListener());*/
                  });
                  mapboxMap.annotations.createPointAnnotationManager().then((value) async {
                    controller.pointAnnotationManager = value;
                    setState(() {

                    });
                    createMarkers();
                    /*controller.pointAnnotationManager
                          ?.addOnPointAnnotationClickListener(AnnotationClickListener());*/
                  });
                },
                cameraOptions: CameraOptions(
                    center: Point(coordinates: centerPoint).toJson(),
                    zoom: TrackingMapView.dgetBoundsZoomLevel(flutter_map.LatLngBounds.fromPoints(bounds), {
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
                    child: Column(
                      children: [
                        CupertinoButton(
                            padding: const EdgeInsets.all(0),
                            color: AppColors.white,
                            onPressed: controller.changeMapStyle,
                            child: SvgPicture.asset(AppHelper.getSvg('layers'), width: 28,)),
                        const SizedBox(height: 16),
                        CupertinoButton(
                            padding: const EdgeInsets.all(0),
                            color: AppColors.white,
                            onPressed: controller.showUserLocation,
                            child: SvgPicture.asset(AppHelper.getSvg('near_me'), width: 28,)),
                      ],
                    ),
                  )),
            ],
          ),
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
    final TrackingController controller = Get.find();
    setInitialRouteMarkerPath();
    setInitialDistance();
    print('animated marker init');
    controller.updateStream.stream.listen((event) {
      print('heee');
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
    if(annotation != null) {
      annotationManager.delete(annotation!);
      print('deleted annotation');
    }
  }

  void setInitialRouteMarkerPath() {

    if(routePath.isNotEmpty) {
    //if(controller.locations[trackDetail.track] != null) {
      final latLng = routePath.first;
      //final latLng = controller.locations[trackDetail.track]!;
      if (controller.locations[trackDetail.track] == null) {
        print('location set ${trackDetail.track}');
        controller.setLocation(trackDetail.track, latLng);
      }
      if (annotation == null) {
        var widget = Container(
          width: trackDetail.marker_text.length > 3 ? (trackDetail.marker_text.length)*13 : 36,
          height: 36,
          decoration: BoxDecoration(
              color: AppColors.accentLight,
              borderRadius: BorderRadius.circular(40)),
          child: Center(
            child: AppText(
                trackDetail.marker_text,
                fontSize: 16,
                color: AppColors.white
            ),
          ),
        );

        print('annotation creating ${trackDetail.track}');

        controller.screenshotController.captureFromWidget(widget).then((
            value) async {
          print('annotation creating ${trackDetail.track}');
          annotation = await annotationManager.create(PointAnnotationOptions(
            image: value,
            geometry: Point(
                coordinates: Position(latLng.longitude, latLng.latitude)
            ).toJson(),
          ));
          print('annotation created ${trackDetail.track}');
        });
      } else {
        print('annotation is not null ${trackDetail.track}');
      }
    } else {
      print('route path is empty ${trackDetail.track}');
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
        /*var widget = Container(
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
        });*/
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

class TrackProgress {
  double oldProgress;
  double currentProgress;
  double currentSpeed;
  double coveredDistance;
  bool newProgressUpdate;

  TrackProgress({
    this.oldProgress = 0,
    this.currentProgress = 0,
    this.currentSpeed = 0,
    this.coveredDistance = 0,
    this.newProgressUpdate = false,
  });
}