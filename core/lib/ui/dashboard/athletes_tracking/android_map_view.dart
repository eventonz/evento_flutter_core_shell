import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:evento_core/l10n/app_localizations.dart';
import 'package:evento_core/ui/dashboard/athletes_tracking/side_drawer.dart';
import 'package:evento_core/ui/dashboard/athletes_tracking/tracking_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geojson/geojson.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:apple_maps_flutter/apple_maps_flutter.dart' as apple_map;
import 'package:latlong2/latlong.dart' as latlong;
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:geodart/geometries.dart' as geodart;

import '../../../core/models/athlete_track_detail.dart';
import '../../../core/res/app_colors.dart';
import '../../../core/services/config_reload/config_reload_service.dart';
import '../../../core/utils/enums.dart';
import '../../../core/utils/helpers.dart';
import '../../common_components/retry_layout.dart';
import '../../common_components/text.dart';
import 'map_view.dart';

class AndroidMapView extends StatefulWidget {
  const AndroidMapView({super.key});

  @override
  State<AndroidMapView> createState() => _AndroidMapViewState();
}

class _AndroidMapViewState extends State<AndroidMapView> {
  final TrackingController controller = Get.find();

  late Timer timer;
  Timer? athleteUpdateTimer;
  bool disposed = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      final mapDataSnap = controller.mapDataSnap;
      if (mapDataSnap.value == DataSnapShot.loaded &&
          controller.athleteTrackDetails.isNotEmpty) {
        controller.trackProgressMap = {};
        controller.androidAnnotations.value = {};

        timer.cancel();

        athleteUpdateTimer = Timer.periodic(const Duration(seconds: 1), (
          Timer t,
        ) {
          updateAthleteMarkers();
        });
      }
    });
  }

  updateAthleteMarkers() async {
    for (var trackDetail in controller.athleteTrackDetails) {
      final routePath = controller.getAthleteRouthPath(trackDetail);
      if (routePath.isNotEmpty) {
        var progress = controller.trackProgressMap[trackDetail.track];
        var latLng = routePath.first;

        if (progress == null) {
          progress = TrackProgress(
            oldProgress: trackDetail.location ?? 0,
            currentProgress: trackDetail.location ?? 0,
            currentSpeed: trackDetail.speed ?? 0,
            coveredDistance:
                (trackDetail.location ?? 0) /
                100 *
                Precision(
                  controller
                      .createLineStringPath(
                        (controller.getAthleteRouthPath(trackDetail)),
                      )
                      .length,
                ).toPrecision(3),
          );

          controller.trackProgressMap[trackDetail.track] = progress;

          final geodart.LineString lineStringPath = controller
              .createLineStringPath(routePath);
          latLng = controller.getLatlngFromDistance(
            lineStringPath,
            progress.coveredDistance,
          );

          controller.setLocation(trackDetail.track, latLng);
          var bytes = await AppHelper.widgetToBytes(
            Container(
              width:
                  trackDetail.marker_text.length > 3
                      ? (trackDetail.marker_text.length) * 13
                      : 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppHelper.hexToColor(
                  controller.routePathsColors[trackDetail.path ?? 'path'],
                ),
                //color: AppColors.accentLight
                borderRadius: BorderRadius.circular(40),
              ),
              child: Center(
                child: AppText(
                  trackDetail.marker_text == ''
                      ? trackDetail.track
                      : trackDetail.marker_text,
                  fontSize: 16,
                  color:
                      controller.routePathsColors[trackDetail.path ?? 'path'] ==
                              null
                          ? Colors.black
                          : AppColors.white,
                ),
              ),
            ),
          );

          print('annotation creating ${trackDetail.track}');
          controller.pointAnnotationManager
              ?.create(
                PointAnnotationOptions(
                  image: bytes,
                  geometry: Point(
                    coordinates: Position(latLng.longitude, latLng.latitude),
                  ),
                ),
              )
              .then((annotation) {
                controller.addAndroidAnnotation(trackDetail.track, annotation);
              });

          print('annotation created ${trackDetail.track}');
        } else {
          //print('routePath ${trackDetail.track} ${trackDetail.path}: $routePath');
          final geodart.LineString lineStringPath = controller
              .createLineStringPath(routePath);

          //print('lineString ${trackDetail.track} ${lineStringPath}');

          double coveredDistance = progress.coveredDistance;
          if (coveredDistance <
              Precision(lineStringPath.length).toPrecision(4)) {
            if (progress.newProgressUpdate) {
              print('new update');
              progress.coveredDistance =
                  (progress.currentProgress / 100) *
                  Precision(lineStringPath.length).toPrecision(3);
              progress.newProgressUpdate = false;
            }

            progress.coveredDistance =
                controller.getNewDistanceAfterOneSec(progress.currentSpeed) +
                Precision(progress.coveredDistance).toPrecision(4);
            final latLng = controller.getLatlngFromDistance(
              lineStringPath,
              progress.coveredDistance,
            );

            await controller.setLocation(
              trackDetail.track,
              latLng,
              wait: false,
              update: false,
            );

            if (controller.androidAnnotations.value[trackDetail.track] !=
                null) {
              var annotation =
                  controller.androidAnnotations.value[trackDetail.track]!;
              annotation.geometry = Point(
                coordinates: Position(latLng.longitude, latLng.latitude),
              );
              if (!disposed) {
                controller.pointAnnotationManager?.update(annotation);
              }
            }

            progress.oldProgress = trackDetail.location ?? 0;
            progress.currentProgress = trackDetail.location ?? 0;
            progress.currentSpeed = trackDetail.speed ?? 0;

            controller.trackProgressMap[trackDetail.track] = progress;
          }
        }
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
    athleteUpdateTimer?.cancel();
    disposed = true;
  }

  @override
  Widget build(BuildContext context) {
    final TrackingController controller = Get.find();
    final ConfigReload reloadController = Get.find();
    final mapDataSnap = controller.mapDataSnap;

    print('showStartIcon ${controller.showStartIcon}');

    onPointClick() {
      controller.pointAnnotationManager!.addOnPointAnnotationClickListener(
        AnnotationClickListener((annotation) {
          var point =
              controller.geoJson.features
                  .where(
                    (element) =>
                        element.properties?['annotation'] == annotation.id,
                  )
                  .firstOrNull;
          if (point == null) {
            return;
          }
          showModalBottomSheet(
            context: context,
            builder:
                (_) => BottomSheet(
                  elevation: 0,
                  onClosing: () {},
                  builder:
                      (_) => Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 24.0,
                                right: 24.0,
                                top: 24.0,
                                bottom: 12.0,
                              ),
                              child: Row(
                                children: [
                                  point.properties?['type'] == 'custom'
                                      ? Image.network(
                                        '${point.properties?['icon']}',
                                        width: 30,
                                        height: 30,
                                      )
                                      : Image.asset(
                                        AppHelper.getImage(
                                          '${point.properties?['type']}.png',
                                        ),
                                        width: 30,
                                        height: 30,
                                      ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${point.properties?['title']}',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if ((point.properties?['image'] ?? '') != '')
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Image.network(
                                  point.properties?['image'],
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24.0,
                              ),
                              child: Text(
                                '${point.properties?['description']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                            if (point.properties?['direction'] == true) ...[
                              const SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24.0,
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    AppHelper.showDirectionsOnMap(
                                      apple_map.LatLng(
                                        (point.geometry as GeoJsonPoint)
                                            .geoPoint
                                            .latitude,
                                        (point.geometry as GeoJsonPoint)
                                            .geoPoint
                                            .longitude,
                                      ),
                                    );
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      Theme.of(context).colorScheme.primary,
                                    ),
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    AppLocalizations.of(context)!.getDirections,
                                    style: TextStyle(
                                      color: Theme.of(context).cardColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            SizedBox(
                              height: MediaQuery.of(context).padding.bottom + 8,
                            ),
                          ],
                        ),
                      ),
                ),
          );
        }),
      );
    }

    addDistanceMarkers() {
      for (int x = 0; x < controller.routePathsCordinates.length; x++) {
        print(
          '${controller.routePathsCordinates.length} abcda ${controller.totalDistance}',
        );
        final lineString =
            controller.getLineStringForPath(
              controller.routePathsCordinates.keys.toList()[x],
            )!;
        final totalDistance =
            controller.totalDistance[controller.routePathsCordinates.keys
                .toList()[x]];

        var color =
            controller.routePathsColors[controller.routePathsCordinates.keys
                .toList()[x]];

        for (int i = 1; i < totalDistance!; i++) {
          Widget widget = Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // The main container with the number
                  Container(
                    width: 30,
                    padding: EdgeInsets.symmetric(vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '$i', // The number
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  //Container(height: .5, width: 16, color: Colors.black),
                  RotatedBox(
                    quarterTurns: 2,
                    child: ClipPath(
                      clipper: TriangleClipper(),
                      child: Container(
                        width: 16,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );

          widget = Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 1),
            ),
            child: Center(
              child: Text(
                '$i',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          );

          controller.screenshotController
              .captureFromWidget(
                widget,
                delay: const Duration(milliseconds: 100),
              )
              .then((bytes) {
                controller.images[i] = bytes;

                controller.pointAnnotationManager!
                    .create(
                      PointAnnotationOptions(
                        geometry: Point(
                          coordinates: Position(
                            lineString.along(i.toDouble() * 1000).lng,
                            lineString.along(i.toDouble() * 1000).lat,
                          ),
                        ),
                        image:
                            controller.showDistanceMarkers.value == false
                                ? null
                                : (i % 5 == 0 ? controller.images[i] : null),
                      ),
                    )
                    .then((pointAnnotation) {
                      controller
                              .points['${controller.routePathsCordinates.keys.toList()[x]}_$i'] =
                          pointAnnotation;
                    });
              });
          //}
        }

        if (controller.showStartIcon[controller.routePathsCordinates.keys
                .toList()[x]] ==
            true) {
          print('startingpointa1');
          Widget widget = SvgPicture.asset(
            AppHelper.getSvg('startingpoint'),
            width: 27,
            height: 27,
          );

          controller.screenshotController.captureFromWidget(widget).then((
            value,
          ) async {
            controller.pointAnnotationManager!.create(
              PointAnnotationOptions(
                geometry: Point(
                  coordinates: Position(
                    lineString.coordinates.first.longitude.toDouble(),
                    lineString.coordinates.first.latitude.toDouble(),
                  ),
                ),
                image: value,
              ),
            );
          });
        }

        if (controller.showFinishIcon[controller.routePathsCordinates.keys
                .toList()[x]] ==
            true) {
          Widget widget = SvgPicture.asset(
            AppHelper.getSvg('finishpoint'),
            width: 27,
            height: 27,
          );

          controller.screenshotController.captureFromWidget(widget).then((
            value,
          ) async {
            controller.pointAnnotationManager!.create(
              PointAnnotationOptions(
                geometry: Point(
                  coordinates: Position(
                    lineString.coordinates.last.longitude.toDouble(),
                    lineString.coordinates.last.latitude.toDouble(),
                  ),
                ),
                image: value,
              ),
            );
          });
        }
      }
    }

    addPoiMarkers() {
      final points = controller.geoJson.features;
      controller.screenshotController
          .captureFromWidget(
            Image.asset(
              AppHelper.getImage('transparent.png'),
              width: 10,
              height: 10,
            ),
          )
          .then((value) {
            controller.interestImages['empty_image'] = value;
          });
      for (int index = 0; index < points.length; index++) {
        var element = points[index];
        if (element.type == GeoJsonFeatureType.point) {
          print('hello 4');
          print(element.properties?['type']);
          Widget widget =
              element.properties?['type'] == 'custom'
                  ? Image.network(
                    '${element.properties?['icon']}',
                    width: 30,
                    height: 30,
                  )
                  : Image.asset(
                    AppHelper.getImage('${element.properties?['type']}.png'),
                    width: 30,
                    height: 30,
                  );
          controller.screenshotController
              .captureFromWidget(
                widget,
                delay: Duration(
                  seconds: element.properties?['type'] == 'custom' ? 2 : 1,
                ),
              )
              .then((value) async {
                PointAnnotation pointAnnotation = await controller
                    .pointAnnotationManager!
                    .create(
                      PointAnnotationOptions(
                        geometry: Point(
                          coordinates: Position(
                            (element.geometry as GeoJsonPoint)
                                .geoPoint
                                .longitude,
                            (element.geometry as GeoJsonPoint)
                                .geoPoint
                                .latitude,
                          ),
                        ),
                        image: value,
                      ),
                    );
                if (controller.interestAnnotations[element
                        .properties?['type']] ==
                    null) {
                  controller.interestAnnotations[element.properties?['type']] =
                      [];
                  controller.interestImages[element.properties?['type']] =
                      value;
                }
                controller.interestAnnotations[element.properties?['type']]!
                    .add(pointAnnotation);
                controller.geoJson.features[index].properties?['annotation'] =
                    pointAnnotation.id;
              });
        }
        print(controller.geoJson.features.length);
      }
    }

    onZoom(double zoom) {
      print(zoom);
      if (zoom >= 14) {
        if (controller.zoomedIn) {
          return;
        }
        controller.zoomedIn = true;
      } else {
        if (!controller.zoomedIn) {
          return;
        }
        controller.zoomedIn = false;
      }
      for (int x = 0; x < controller.routePathsCordinates.keys.length; x++) {
        for (int i = 1; i < controller.totalDistance.values.first; i++) {
          var annotation =
              controller
                  .points['${controller.routePathsCordinates.keys.toList()[x]}_$i'];
          if (annotation != null) {
            if (!controller.showDistanceMarkers.value) {
              annotation.image = Uint8List(0);
            } else if (zoom >= 14) {
              annotation.image = controller.images[i];
            } else {
              annotation.image =
                  i % 5 == 0 ? controller.images[i] : Uint8List(0);
            }
            if (!disposed) {
              controller.pointAnnotationManager?.update(annotation);
            }
          }
        }
      }
      controller.points.refresh();
    }

    createRoute() async {
      final positions = <List<Position>>[];
      int i = 0;
      for (List<latlong.LatLng> routePath
          in controller.routePathsCordinates.values) {
        positions.add(
          routePath.map((e) => Position(e.longitude, e.latitude)).toList(),
        );
        i++;
      }
      controller.polylineAnnotationManager?.createMulti(
        List.generate(
          positions.length,
          (index) => PolylineAnnotationOptions(
            geometry: LineString(coordinates: positions[index]),
            lineColor:
                controller.routePathsColors.values.toList()[index] != null
                    ? AppHelper.hexToColor(
                      controller.routePathsColors.values.toList()[index],
                    ).value
                    : AppColors.accentDark.value,
            lineWidth: 3,
          ),
        ).toList(),
      );
    }

    return Obx(() {
      if (mapDataSnap.value == DataSnapShot.loaded) {
        List<apple_map.LatLng> bounds = [];

        controller.routePathsCordinates.values.forEach((element) {
          bounds.addAll(
            element.map(
              (element) =>
                  apple_map.LatLng(element.latitude, element.longitude),
            ),
          );
        });

        double minX = 180;
        double maxX = -180;
        double minY = 90;
        double maxY = -90;

        for (final point in bounds) {
          minX = math.min<double>(minX, point.longitude);
          minY = math.min<double>(minY, point.latitude);
          maxX = math.max<double>(maxX, point.longitude);
          maxY = math.max<double>(maxY, point.latitude);
        }

        var sw = apple_map.LatLng(minY, minX);
        var ne = apple_map.LatLng(maxY, maxX);

        final centerPoint = controller.initialPathCenterPoint();

        return Scaffold(
          key: _scaffoldKey,
          endDrawer: CustomDrawer(_scaffoldKey),
          body: Stack(
            children: [
              MapWidget(
                styleUri:
                    controller.currentStyle.value == 0
                        ? MapboxStyles.MAPBOX_STREETS
                        : (controller.currentStyle.value == 1
                            ? MapboxStyles.STANDARD
                            : MapboxStyles.SATELLITE),
                onMapCreated: (mapboxMap) {
                  mapboxMap.location.updateSettings(
                    LocationComponentSettings(
                      enabled: true,
                      pulsingEnabled: true,
                    ),
                  );
                  mapboxMap.compass.updateSettings(
                    CompassSettings(marginTop: 60, marginRight: 16),
                  );
                  controller.mapboxMap = mapboxMap;
                  mapboxMap.annotations.createPolylineAnnotationManager().then((
                    value,
                  ) async {
                    controller.polylineAnnotationManager = value;
                    createRoute();
                    /*controller.pointAnnotationManager
                            ?.addOnPointAnnotationClickListener(AnnotationClickListener());*/
                  });
                  mapboxMap.annotations.createPointAnnotationManager().then((
                    value,
                  ) async {
                    controller.pointAnnotationManager = value;
                    addPoiMarkers();
                    onPointClick();
                    addDistanceMarkers();
                    setState(() {});
                    //createMarkers();
                    /*controller.pointAnnotationManager
                            ?.addOnPointAnnotationClickListener(AnnotationClickListener());*/
                  });
                },
                onCameraChangeListener: (data) async {
                  final state = await controller.mapboxMap?.getCameraState();
                  var zoom = state?.zoom ?? 0;
                  onZoom(zoom);
                },
                cameraOptions: CameraOptions(
                  center: Point(coordinates: centerPoint),
                  zoom:
                      AppHelper.dgetBoundsZoomLevel(
                        apple_map.LatLngBounds(southwest: sw, northeast: ne),
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                      ) *
                      0.95,
                ),
              ),

              /*if(controller.pointAnnotationManager != null)
                    for (AthleteTrackDetail trackDetail in controller
                        .athleteTrackDetails.value)
                      AnimatedMarkerView(trackDetail: trackDetail),*/
              Positioned(
                right: 2.w,
                top: 2.w,
                child: SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(height: 6),
                      CupertinoButton(
                        padding: const EdgeInsets.all(0),
                        color: AppColors.white,
                        onPressed: () {
                          _scaffoldKey.currentState?.openEndDrawer();
                        },
                        child: Icon(
                          Icons.menu,
                          color: Theme.of(context).iconTheme.color,
                        ),
                      ),
                      const SizedBox(height: 16),
                      /* CupertinoButton(
                                  padding: const EdgeInsets.all(0),
                                  color: AppColors.white,
                                  onPressed: controller.changeMapStyle,
                                  child: SvgPicture.asset(
                                    AppHelper.getSvg('layers'), width: 28,)),
                              const SizedBox(height: 16),*/
                      CupertinoButton(
                        padding: const EdgeInsets.all(0),
                        color: AppColors.white,
                        onPressed: controller.showUserLocation,
                        child: SvgPicture.asset(
                          AppHelper.getSvg('near_me'),
                          width: 28,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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

class AnnotationClickListener extends OnPointAnnotationClickListener {
  final Function(PointAnnotation) onAnnotationClick;
  AnnotationClickListener(this.onAnnotationClick);
  @override
  void onPointAnnotationClick(PointAnnotation annotation) {
    onAnnotationClick(annotation);
    print("onAnnotationClick, id: ${annotation.id} ${annotation.textField}");
  }
}
