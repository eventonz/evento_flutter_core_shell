// ignore_for_file: invalid_use_of_protected_member
import 'dart:convert';
import 'dart:io';

import 'package:apple_maps_flutter/apple_maps_flutter.dart' as apple_maps;
import 'package:carousel_slider/carousel_controller.dart';
import 'package:evento_core/core/db/app_db.dart';
import 'package:evento_core/core/overlays/toast.dart';
import 'package:evento_core/ui/dashboard/athletes_tracking/map_view.dart';
import 'package:evento_core/ui/dashboard/dashboard_controller.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:evento_core/core/models/app_config.dart';
import 'package:evento_core/core/models/athlete_track_detail.dart';
import 'package:evento_core/core/routes/routes.dart';
import 'package:evento_core/core/utils/api_handler.dart';
import 'package:evento_core/core/utils/app_global.dart';
import 'package:evento_core/core/utils/enums.dart';
import 'package:evento_core/core/utils/keys.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geodart/geometries.dart' as geodart;
import 'package:get/get_utils/get_utils.dart';
import 'package:http/http.dart' as http;
import 'package:geojson/geojson.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'dart:async';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:screenshot/screenshot.dart';

import '../../../core/res/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../common_components/text.dart';
import 'dart:ui' as ui;

class TrackingController extends GetxController
    with GetTickerProviderStateMixin {
  late Tracking? trackingDetails;
  late int eventId = 0;
  late Timer timer;
  Timer? athleteUpdateTimer;
  int currentII = 0;
  int counter = 0;
  final athleteTrackDetails = <AthleteTrackDetail>[].obs;
  final mapDataSnap = DataSnapShot.initial.obs;
  final accessToken ='pk.eyJ1IjoiZXZlbnRvbnoiLCJhIjoiY2x2enQ4a3FuMDdmaTJxcGY1MG1ldjh6diJ9.72FtQjCQ4uUiyFyzWCh5hA';
  final mapid =  'mapbox.mapbox-streets-v8';
  final currentStyle = 0.obs;
  List<Paths> routePathLinks = [];
  List<MapPathMarkers> mapPathMarkers = [];
  Map<String, List<LatLng>> routePathsCordinates = {};
  Map<String, String?> routePathsColors = {};
  bool animated = false;
  Map<String, LatLng> locations = {};

  bool isAnimatingMarkers = false;

  apple_maps.AppleMapController? appleMapController;
  Rx<Map<apple_maps.PolylineId, apple_maps.Polyline>> polylines = Rx(<apple_maps.PolylineId, apple_maps.Polyline>{});
  Rx<Map<apple_maps.AnnotationId, apple_maps.Annotation>> annotations = Rx(<apple_maps.AnnotationId, apple_maps.Annotation>{});
  Rx<Map<apple_maps.AnnotationId, apple_maps.Annotation>> extraAnnotations = Rx(<apple_maps.AnnotationId, apple_maps.Annotation>{});

  Map<String, TrackProgress> trackProgressMap = {};
  bool isFirstTime = true;

  PointAnnotationManager? pointAnnotationManager;
  PolylineAnnotationManager? polylineAnnotationManager;
  MapboxMap? mapboxMap;

  MapController mapController = MapController();
  ScreenshotController screenshotController = ScreenshotController();

  CarouselController carouselController = CarouselController();

  late StreamController<int> updateStream = StreamController<int>.broadcast();


  static const _startedId = 'AnimatedMapController#MoveStarted';
  static const _inProgressId = 'AnimatedMapController#MoveInProgress';
  static const _finishedId = 'AnimatedMapController#MoveFinished';

  bool zoomedIn = false;
  RxBool showDistanceMarkers = false.obs;

  RxMap<String, dynamic> points = <String, dynamic>{}.obs;

  Map<String, double> totalDistance = {};

  Map<int, Uint8List> images = {};

  List<String> mapStyles = [
    MapboxStyles.OUTDOORS,
    MapboxStyles.SATELLITE,
    MapboxStyles.STANDARD,
  ];

  List<apple_maps.MapType> mapTypes = <apple_maps.MapType>[
    apple_maps.MapType.standard,
    apple_maps.MapType.satellite,
    apple_maps.MapType.hybrid,
  ];

  Rx<String> mapStyle = MapboxStyles.OUTDOORS.obs;
  Rx<apple_maps.MapType> mapType = apple_maps.MapType.standard.obs;

  var geoJson = GeoJson();

  RxMap<String, List<dynamic>> interestAnnotations = <String, List<dynamic>>{}.obs;
  Map<String, Uint8List> interestImages = {};

  Rx<List<String>> selectedInterests = Rx(['']);

  final Map<String, String> iopTypesMap = {
    "spectators": "Spectator Zones",
    "camera": "Camera",
    "bagdrop": "Bag Drop",
    "checkpoint": "Checkpoint",
    "mechanic": "Mechanic Zones",
    "timing": "Timing Points",
    "aidstation": "Aid Station",
    "info": "Information",
    "wc": "Toilets",
    "store": "Store",
    "caution": "Caution",
    "firstaid": "First Aid"
  };


  @override
  void onInit() {
    super.onInit();
    trackingDetails = AppGlobals.appConfig!.tracking;
    eventId = AppGlobals.selEventId;//
    changeMapStyle(setDefault: true);
    updateStream.add(1);
    MapboxOptions.setAccessToken(accessToken);
    //if (eventId.isEmpty) {
    //  eventId = AppGlobals.appEventConfig.multiEventListId ?? '';
    //}
  }

  void changeDistanceMarkers(bool show) async {
    showDistanceMarkers.value = show;
    update();

    final state = await mapboxMap?.getCameraState();
    print(state?.zoom);
    for(int x = 0; x < routePathsCordinates.values.length; x++) {
      var distance = totalDistance.values.toList()[x];
      for (int i = 1; i < distance; i++) {

        final annotation = points['${routePathsCordinates.keys.toList()[x]}_$i'];
        if (annotation != null) {
          if (!Platform.isIOS) {
            if (showDistanceMarkers.value == false) {
              annotation.image = null;
            } else if ((state?.zoom ?? 0) >= 14) {
              annotation.image = images[i];
            } else {
              annotation.image = i % 5 == 0 ? images[i] : null;
            }
            pointAnnotationManager?.update(annotation);
          } else {
            var zoom = await appleMapController?.getZoomLevel() ?? 0;
            var annotation = points['${routePathsCordinates.keys.toList()[x]}_$i'] as apple_maps.Annotation;
            if (!showDistanceMarkers.value) {
              annotation = annotation.copyWith(
                  iconParam: apple_maps.BitmapDescriptor.fromBytes(
                      Uint8List(0)));
            } else if ((zoom) >= 14) {
              annotation = annotation.copyWith(
                  iconParam: apple_maps.BitmapDescriptor.fromBytes(images[i]!));
            } else {
              annotation = annotation.copyWith(
                  iconParam: i % 5 == 0 ? apple_maps.BitmapDescriptor.fromBytes(
                      images[i]!) : apple_maps.BitmapDescriptor.fromBytes(
                      AppHelper.emptyImage));
            }
            points['${routePathsCordinates.keys.toList()[x]}_$i'] = annotation;
            points.refresh();
          }
        }
      }
    }
  }

  double calculateTotalDistance() {
/*    if (routePathsCordinates.length < 2) {
      return 0.0;
    }*/

    double totalDistance = 0.0;
    const distanceCalculator = Distance();

    for (int x = 0; x < routePathsCordinates.values.length; x++) {
      var pathCoordinates = routePathsCordinates.values.toList()[x];
      for (int i = 0; i < pathCoordinates.length - 1; i++) {
        final point1 = pathCoordinates[i];
        final point2 = pathCoordinates[i + 1];
        final distance = distanceCalculator.as(
          LengthUnit.Centimeter,
          LatLng(point1.latitude.toDouble(), point1.longitude.toDouble()),
          LatLng(point2.latitude.toDouble(), point2.longitude.toDouble()),
        );
        totalDistance += distance;
      }

      print(totalDistance);
      totalDistance =
          LengthUnit.Centimeter.to(LengthUnit.Kilometer, totalDistance);
      print(totalDistance);

      this.totalDistance[routePathsCordinates.keys.toList()[x]] = totalDistance;
    }

    return totalDistance;
  }

  void changeStyle(int index) {
    mapStyle.value = mapStyles[index];
    mapType.value = mapTypes[index];
    mapboxMap?.loadStyleURI(mapStyles[index]);
    update();


    //mapboxMap?.style.addSource(RasterDemSource(id: 'mapbox-dem', url: 'mapbox://mapbox.mapbox-terrain-dem-v1', tileSize: 512, maxzoom: 14));
    // add the DEM source as a terrain layer with exaggerated height
    //mapboxMap.style.til();
    mapboxMap?.style.setStyleTerrain(jsonEncode({ 'source': 'mapbox-dem', 'exaggeration': 3.0 }));
  }

  String getStyleName(String style) {
    if(style == MapboxStyles.OUTDOORS) {
      return 'Outdoors';
    } else if(style == MapboxStyles.SATELLITE) {
      return 'Satellite';
    } else if(style == MapboxStyles.STANDARD) {
      return Platform.isIOS ? 'Hybrid' : '3D';
    } else {
      return 'Default';
    }
  }

  String getStyleImage(String style) {
    if(style == MapboxStyles.OUTDOORS) {
      return 'square.png';
    } else if(style == MapboxStyles.SATELLITE) {
      return 'square2.png';
    } else if(style == MapboxStyles.STANDARD) {
      return Platform.isIOS ? 'square3.png' : 'square3.png';
    } else {
      return 'square3.png';
    }
  }

  void updateSelectedInterests(List<String> values) {
    selectedInterests.value = values;
    update();
    if(values.contains('')) {
      interestAnnotations.keys.forEach((value) {
        int index = 0;
        interestAnnotations[value]?.forEach((element) {
          if(Platform.isIOS) {
            interestAnnotations[value]![index] = (element as apple_maps.Annotation).copyWith(iconParam: apple_maps.BitmapDescriptor.fromBytes(interestImages[value]!));
          } else {
            element.image = interestImages[value];
            pointAnnotationManager?.update(element);
          }
          index++;
        });
      });
    } else {
      interestAnnotations.keys.forEach((value) {
        int index = 0;
        interestAnnotations[value]?.forEach((element) {
          if(Platform.isIOS) {
            interestAnnotations[value]![index] = (element as apple_maps.Annotation).copyWith(iconParam: apple_maps.BitmapDescriptor.fromBytes(Uint8List(0)));
          } else {
            element.image = null;
            pointAnnotationManager?.update(element);
          }
          index++;
        });
      });
      for (var value in values) {
        int index = 0;
        interestAnnotations[value]?.forEach((element) {
          if(Platform.isIOS) {
            interestAnnotations[value]![index] = (element as apple_maps.Annotation).copyWith(iconParam: apple_maps.BitmapDescriptor.fromBytes(interestImages[value]!));
          } else {
            element.image = interestImages[value];
            pointAnnotationManager?.update(element);
          }
          index++;
        });
      }
    }
    interestAnnotations.refresh();
  }
  
  void addPolyline(polylineId, polyline) {
    polylines.value[polylineId] = polyline;
    update();
  }

  void addAnnotation(annotationId, annotation) {
    annotations.value[annotationId] = annotation;
    annotations.refresh();
    update();
  }

  void addExtraAnnotation(annotationId, annotation) {
    extraAnnotations.value[annotationId] = annotation;
    extraAnnotations.refresh();
    update();
  }

  void addStaticAnnotation(annotationId, annotation) {
    if(interestAnnotations['static'] == null) {
      interestAnnotations['static'] = [];
    }
    interestAnnotations['static']?.add(annotation);
    interestAnnotations.refresh();
    update();
  }

  void clearAnnotations() {
    annotations.value.clear();
    annotations.refresh();
    update();
  }

  void clearStaticAnnotations() {
    interestAnnotations.value.clear();
    interestAnnotations.refresh();
    update();
  }

  void updateAnnotation(annotationId, annotation) {
    annotations.value[annotationId] = annotation;
    annotations.refresh();
    update();
  }

  void updateStaticAnnotation(annotationId, annotation) {
    if(interestAnnotations['static'] == null) {
      interestAnnotations['static'] = [];
    }
    interestAnnotations['static']?.add(annotation);
    interestAnnotations.refresh();
    update();
  }

  void animatedMapMove(LatLng destLocation, double destZoom) {
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final camera = mapController.camera;
    final latTween = Tween<double>(
        begin: camera.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: camera.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: camera.zoom, end: destZoom);

    // Create a animation controller that has a duration and a TickerProvider.
    final controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    final Animation<double> animation =
    CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    // Note this method of encoding the target destination is a workaround.
    // When proper animated movement is supported (see #1263) we should be able
    // to detect an appropriate animated movement event which contains the
    // target zoom/center.
    final startIdWithTarget =
        '$_startedId#${destLocation.latitude},${destLocation.longitude},$destZoom';
    bool hasTriggeredMove = false;

    controller.addListener(() {
      final String id;
      if (animation.value == 1.0) {
        id = _finishedId;
      } else if (!hasTriggeredMove) {
        id = startIdWithTarget;
      } else {
        id = _inProgressId;
      }

      hasTriggeredMove |= mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
        id: id,
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }


  @override
  void onClose() {
    super.onClose();
    athleteUpdateTimer?.cancel();

    timer.cancel();
  }

  @override
  void onReady() {
    super.onReady();
    getRoutePaths();
  }

  Future<void> setLocation(String track, LatLng location, {bool wait = false, bool update = true}) async {
    locations[track] = location;
    if(wait) {
      await Future.delayed(const Duration(seconds: 1));
    }
    if(update) {
      this.update();
    }
  }

  Future<void> getRoutePaths() async {
    if (trackingDetails == null) return;
    print('getRoutePaths');

    /*trackingDetails!.paths = [
      Paths(
        url: "https://evento-nz.fra1.cdn.digitaloceanspaces.com/geojson/9FB682C1-6276-458D-B605-F5757D61A895.geojson",
        name: 'p_1',
        color: '#000000',
      ),
      Paths(
        url: "https://evento-nz.fra1.cdn.digitaloceanspaces.com/geojson/06292487-C9D2-407F-9861-FD421266A1D9.geojson",
        name: 'p_2',
        color: '#1681CF',
      ),
    ];*/

    routePathLinks = List.from(trackingDetails!.paths);
    try {
      mapDataSnap.value = DataSnapShot.loading;
      mapPathMarkers.clear();
      for (Paths path in routePathLinks) {
        print(path.toJson());
        //routePathsColors[path.name ?? 'path'] = path.color;
        final res = await ApiHandler.downloadFile(baseUrl: path.url!);
        final geoJsonFile = File(res.data['file_path']);
        var text = await geoJsonFile.readAsString();
        print(text);
        var data = jsonDecode(text);
        var list = ((data['features'] as List));
        var i = 0;
        for (var element in list) {
          print(element['geometry']['coordinates']);
          if(element['geometry']['coordinates'] is Map) {
            data['features'][i]['geometry']['coordinates'] =
              [element['geometry']['coordinates']['lng'], element['geometry']['coordinates']['lat']]
            ;
          }
          i++;
        }

        geoJson = GeoJson();

        await geoJson.parse(jsonEncode(data));
        final geoPoints = geoJson.lines.first.geoSerie?.geoPoints ?? [];
        if (geoPoints.isNotEmpty) {
          routePathsCordinates[path.name ?? 'path'] =
              geoPoints.map((e) => LatLng(e.latitude, e.longitude)).toList();
          //routePathsColors[path.name ?? 'path'] = geoJson.features.where((element) => element.properties?['color'] != null).firstOrNull?.properties?['color'];
        }

        final points = geoJson.features;
        for (int index = 0; index < points.length; index++) {
          var element = points[index];
          if (element.type == GeoJsonFeatureType.point) {
            print(geoJson.features[index]
                .properties);
            Widget widget = Image.asset(AppHelper.getImage('${element
                .properties?['type']}.png'), width: 30, height: 30);
            AppHelper.widgetToBytes(widget)
                .then((value) async {
              apple_maps.Annotation pointAnnotation = apple_maps.Annotation(
                annotationId: apple_maps.AnnotationId(element
                    .properties?['id']),
                icon: apple_maps.BitmapDescriptor.fromBytes(value),
                position: apple_maps.LatLng(
                    (element.geometry as GeoJsonPoint).geoPoint
                        .latitude,
                    (element.geometry as GeoJsonPoint).geoPoint
                        .longitude),
                onTap: () async {
                  var point = element;
                  print(point.geometry);
                  appleMapController?.animateCamera(apple_maps.CameraUpdate.newCameraPosition(apple_maps.CameraPosition(target: apple_maps.LatLng((point.geometry as GeoJsonPoint).geoPoint.latitude, (point.geometry as GeoJsonPoint).geoPoint.longitude), zoom: 18)));
                  await showModalBottomSheet(
                      barrierColor: Colors.black.withOpacity(0.04),
                      context: Get.context!, builder: (_) =>
                      BottomSheet(
                          elevation: 0,
                          onClosing: () {

                          }, builder: (_) =>
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 24.0,
                                      right: 24.0,
                                      top: 24.0,
                                      bottom: 12.0),
                                  child: Row(
                                    children: [
                                      Image.asset(AppHelper.getImage('${point
                                          .properties?['type']}.png'),
                                          width: 30, height: 30),
                                      const SizedBox(width: 8),
                                      Text('${point.properties?['title']}',
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                          )),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24.0),
                                  child: Text(
                                      '${point.properties?['description']}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      )),
                                ),
                                if(point.properties?['direction'] == true)
                                  ...[
                                    const SizedBox(height: 16),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24.0),
                                      child: ElevatedButton(onPressed: () {
                                        AppHelper.showDirectionsOnMap(
                                            apple_maps.LatLng(
                                                (point.geometry as GeoJsonPoint)
                                                    .geoPoint.latitude,
                                                (point.geometry as GeoJsonPoint)
                                                    .geoPoint.longitude));
                                      },
                                        style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty
                                              .all(Theme
                                              .of(Get.context!)
                                              .colorScheme
                                              .primary),
                                          shape: MaterialStateProperty.all(
                                              RoundedRectangleBorder(
                                                  borderRadius: BorderRadius
                                                      .circular(5))),
                                        ),
                                        child: Text(
                                          'Get Directions', style: TextStyle(
                                          color: Theme
                                              .of(Get.context!)
                                              .colorScheme.secondary,
                                        ),),),
                                    ),
                                  ],
                                SizedBox(height: MediaQuery
                                    .of(Get.context!)
                                    .padding
                                    .bottom + 8),
                              ],
                            ),
                          )));
                  List<LatLng> bounds = [];

                  routePathsCordinates.values.forEach((element) {
                    bounds.addAll(element.map((element) => LatLng(element.latitude.toDouble(), element.longitude.toDouble())));
                  });
                  appleMapController?.animateCamera(apple_maps.CameraUpdate.newCameraPosition(apple_maps.CameraPosition(
                    target: initialPathCenterPoint().lat.toDouble() == 0.0 ? apple_maps.LatLng(-42.0178775,174.3417791) : apple_maps.LatLng(initialPathCenterPoint().lat.toDouble(), initialPathCenterPoint().lng.toDouble()),
                    zoom: bounds.isEmpty ? 5 : TrackingMapView.dgetBoundsZoomLevel(
                        LatLngBounds.fromPoints(bounds), {

                      'height': MediaQuery
                          .of(Get.context!)
                          .size
                          .height,
                      'width': MediaQuery
                          .of(Get.context!)
                          .size
                          .width})*1.05,
                  )));
                },
              );
              if (interestAnnotations[element
                  .properties?['type']] == null) {
                interestAnnotations[element
                    .properties?['type']] = [];
                interestImages[element
                    .properties?['type']] = value;
              }
              interestAnnotations[element
                  .properties?['type']]!.add(pointAnnotation);
              geoJson.features[index]
                  .properties?['annotation'] =
                  pointAnnotation.annotationId.value;
              interestAnnotations.refresh();
              update();
            });
          }
          print(geoJson.features.length);
        }

        calculateTotalDistance();


        bool showStartIcon = geoJson.features
            .where((element) => element.properties?['start_icon'] == true)
            .isNotEmpty;
        bool showFinishIcon = geoJson.features
            .where((element) => element.properties?['finish_icon'] == true)
            .isNotEmpty;

        showDistanceMarkers.value = geoJson.features
            .where((element) => element.properties?['distance_markers'] == true)
            .isNotEmpty;

        routePathsColors[path.name ?? 'path'] = geoJson.features
            .firstWhereOrNull((element) => element.properties?['color']?.isNotEmpty ?? false)
        ?.properties!['color'];

        showStartIcon = true;
        showFinishIcon = true;


        if (Platform.isIOS) {
          var lineString = getLineStringForPath(path.name ?? 'path');
          if (showStartIcon) {
            print('showStartIcon');
            Widget widget = SvgPicture.asset(
                AppHelper.getSvg('startingpoint'), width: 27, height: 27);

            AppHelper.widgetToBytes(widget).then((value) {

            var annotationId = apple_maps.AnnotationId('start_icon_${path.name}');

            var annotation = apple_maps.Annotation(
                annotationId: annotationId,
                zIndex: 4,
                position: apple_maps.LatLng(
                    lineString!.coordinates.first.latitude.toDouble(),
                    lineString.coordinates.first.longitude.toDouble()),
                icon: apple_maps.BitmapDescriptor.fromBytes(
                    value));

            addExtraAnnotation(annotationId, annotation);

            });

          }

          if (showFinishIcon) {
            Widget widget = SvgPicture.asset(
                AppHelper.getSvg('finishpoint'), width: 27, height: 27);

            var annotationId = apple_maps.AnnotationId('finish_icon_${path.name}');

                var annotation = apple_maps.Annotation(
                    annotationId: annotationId,
                    position: apple_maps.LatLng(
                        lineString!.coordinates.last.latitude.toDouble(),
                        lineString.coordinates.last.longitude.toDouble()),
                    icon: apple_maps.BitmapDescriptor.fromBytes(
                        await AppHelper.widgetToBytes(widget)));

                addExtraAnnotation(annotationId, annotation);
          }

          //if (showDistanceMarkers.value) {
        }
      }

      for (int x = 0; x < routePathsCordinates.length; x++) {
        print('${routePathsCordinates.length} abcda ${this.totalDistance}');
        final lineString = getLineStringForPath(routePathsCordinates.keys.toList()[x]);
        final totalDistance = this.totalDistance[routePathsCordinates.keys.toList()[x]];

        var color = routePathsColors[routePathsCordinates.keys.toList()[x]];

        for (int i = 1; i < totalDistance!; i++) {
          Widget widget = Container(
            width: Platform.isIOS ? 24 : 16,
            height: Platform.isIOS ? 24 : 16,
            decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black,
                  width: 1,
                )
            ),
            child: Center(
              child: Text('$i', style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),),
            ),
          );

          widget = Stack(
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
              /*Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 4,
                  height: 25,
                  decoration: BoxDecoration(
                    color: Colors.red,
                  ),
                ),
              ),*/
            ],
          );

          AppHelper.widgetToBytes(widget).then((bytes) {
            images[i] = bytes;

            apple_maps.Annotation pointAnnotation = apple_maps.Annotation(
                annotationId: apple_maps.AnnotationId('distance_$i $x'),
                position: apple_maps.LatLng(lineString!
                    .along(i.toDouble() * 1000)
                    .lat, lineString
                    .along(i.toDouble() * 1000)
                    .lng),
                icon: apple_maps.BitmapDescriptor.fromBytes(
                    i % 5 == 0 ? images[i]! : Uint8List(0)));
            this.points['${routePathsCordinates.keys.toList()[x]}_$i'] = pointAnnotation;
            this.points.refresh();
          });
          //}
        }
        //}
      }



      if (trackingDetails!.mapMarkers != null) {
        final res = await ApiHandler.downloadFile(
            baseUrl: trackingDetails!.mapMarkers!);
        final geoJson = GeoJson();
        final geoJsonFile = File(res.data['file_path']);
        print(geoJsonFile.readAsString());
        await geoJson.parse(await geoJsonFile.readAsString());
        final markerPoints = geoJson.features;
        print(markerPoints.map((e) => e.properties));
        if (markerPoints.isNotEmpty) {
          for (GeoJsonFeature<dynamic> markerPoint in markerPoints) {
            print('markers ${markerPoint.geometry}');
            final geoPoint = (markerPoint.geometry as GeoJsonPoint).geoPoint;
            mapPathMarkers.add(MapPathMarkers(
                latLng: LatLng(geoPoint.latitude, geoPoint.longitude),
                name: markerPoint.properties?['name'] ?? '',
                description: markerPoint.properties?['description'] ?? '',
                iconUrl: markerPoint.properties?['urlicon'] ?? ''));
          }
        }

      }
      mapDataSnap.value = DataSnapShot.loaded;
      await getAthleteTrackingInfo();
      updateAthleteMarkers();
      startAthleteUpdateTimer();
      startTrackingTimer();
      if(Platform.isIOS) {
        setupStaticMarkers();
      }
    } catch (e) {
      rethrow;
      debugPrint(e.toString());
      mapDataSnap.value = DataSnapShot.error;
    }
  }

  setupStaticMarkers() async {
    clearAnnotations();
    for(final marker in mapPathMarkers) {
      print('marker ${marker.type}');

      final response = await http.get(Uri.parse(marker.iconUrl));
      

      Widget widget = Image.memory(response.bodyBytes, width: 30, height: 30);
      final String annotationIdVal = 'static_annotation_id_${interestAnnotations.value
          .length}';
      final apple_maps.AnnotationId polygonId = apple_maps.AnnotationId(
          annotationIdVal);
      var bytes = await AppHelper.widgetToBytes(widget);
      final apple_maps.Annotation annotation = apple_maps.Annotation(
        annotationId: polygonId,
        icon: apple_maps.BitmapDescriptor.fromBytes(bytes),
        //icon: BitmapDescriptor.defaultAnnotation,
        position: apple_maps.LatLng(marker.latLng.latitude, marker.latLng.longitude),
        onTap: () {

        },
      );
      addStaticAnnotation(polygonId.value, annotation);
    }
  }

  void startTrackingTimer() {
    print('freq ${ trackingDetails?.updateFreq ?? 60}');
    timer = Timer.periodic(Duration(seconds: trackingDetails?.updateFreq ?? 60),
        (Timer t){

      DashboardController controller = Get.find();

      print(controller.selMenu.value?.label);
      print('okak');
      if(controller.selMenu.value?.label == 'track') {
        getAthleteTrackingInfo();
      } else {
        counter++;
      }
    });
  }

  void startAthleteUpdateTimer() {
    athleteUpdateTimer?.cancel();
    athleteUpdateTimer = Timer.periodic(const Duration(milliseconds: 1000),
            (Timer t){
            updateAthleteMarkers();
        });
  }

  geodart.LineString? getLineStringForPath(String pathName) {
    final routePath = routePathsCordinates[pathName];
    if (routePath != null) {
      return geodart.LineString(routePath
          .map((point) => geodart.Coordinate(point.latitude, point.longitude))
          .toList());
    } else {
      return null;
    }
  }

  Position initialPathCenterPoint() {
    final initalPathName = routePathsCordinates.keys.first;
    final lineString = getLineStringForPath(initalPathName);
    if (lineString != null) {
      final point = lineString.center;
      return Position(point.lng, point.lat);
    }
    return Position(0, 0);
  }

  Stream<List<AppAthleteDb>> watchFollowedAthletes() async* {
    yield* DatabaseHandler.getAthletes('', true);
  }

  Future<void> getAthleteTrackingInfo({bool firstTime = false}) async {

    counter = 0;

    if (trackingDetails == null) return;
    //if(firstTime && athleteTrackDetails.isNotEmpty) {
    //  currentII++;
    //  return;
    //}

    final entrants = await watchFollowedAthletes().first;
    print('athletes updating 2');
    final entrantsIds = <String>[];
    for (final AppAthleteDb entrant in entrants) {
      entrantsIds.add(entrant.athleteId);
    }
    print('entrantsIds');
    print(entrantsIds);
    print(trackingDetails!.data!);
    final body = {
      'race_id': eventId,
      'web_tracking': true,
      'tracks': entrantsIds
    };
    trackingDetails!.data = 'https://eventotracker.com/api/v3/api.cfm/tracking';
    final res = await ApiHandler.postHttp(
        baseUrl: trackingDetails!.data!, endPoint: '', body: body);
    print(res.data);
    print('res.data');
    if (res.statusCode == 200) {
      athleteTrackDetails.clear();
      athleteTrackDetails
          .addAll(TrackDetail.fromJson(res.data).tracks!.toList());
      entrantsIds.forEach((element) {
        if(athleteTrackDetails.where((p0) => p0.track == element).isEmpty) {
          athleteTrackDetails.add(AthleteTrackDetail(
            track: element,
          ));
        }
      });

    }

    if(false && routePathsCordinates.isNotEmpty) {
      athleteTrackDetails.addAll([
        AthleteTrackDetail(
          track: '1',
          info: '1',
          speed: 6,
          location: 6,
          prevLocation: 6,
          path: routePathsCordinates.keys.first,
          status: '1',
          marker_text: '1',
        ),
        AthleteTrackDetail(
          track: '2',
          info: '2',
          speed: 10,
          location: 8,
          prevLocation: 8,
          path: routePathsCordinates.keys.first,
          status: '2',
          marker_text: '2',
        ),
      ]);
    }
    athleteTrackDetails.refresh();
    update();


    if(Platform.isIOS) {
      annotations.value.clear();
      annotations.refresh();
      trackProgressMap.clear();
      updateTrackProgress();
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

  LatLng getLatlngFromDistance(geodart.LineString lineStringPath, double coveredDistance) {
    final coordinate =
        lineStringPath.along(Precision(coveredDistance).toPrecision(4)).coordinate;
    return LatLng(coordinate.latitude, coordinate.longitude);
  }

  void updateTrackProgress() {
    for (var trackDetail in athleteTrackDetails.value) {
      final progress = trackProgressMap[trackDetail.track];
      if(progress != null) {
        progress.oldProgress = trackDetail.location ?? 0;
        progress.currentProgress = trackDetail.location ?? 0;
        progress.currentSpeed = trackDetail.speed ?? 0;
        progress.newProgressUpdate = true;
      }
    }
  }

  double getNewDistanceAfterOneSec(double speed) {
    return speed / 3600 * 1000;
  }

  updateAthleteMarkers() async {
    print('updateAthleteMarkers');
    for (var trackDetail in athleteTrackDetails.value) {
      final routePath = getAthleteRouthPath(trackDetail);
      if (routePath.isNotEmpty) {
        print('routePath');
        var progress = trackProgressMap[trackDetail.track];
        var latLng = routePath.first;

        if (progress == null) {

          progress = TrackProgress(
            oldProgress: trackDetail.location ?? 0,
            currentProgress: trackDetail.location ?? 0,
            currentSpeed: trackDetail.speed ?? 0,
            coveredDistance: (trackDetail.location ?? 0) / 100 *
                Precision(createLineStringPath((getAthleteRouthPath(trackDetail))).length).toPrecision(3),
          );


          trackProgressMap[trackDetail.track] = progress;

          final geodart.LineString lineStringPath = createLineStringPath(
              routePath);
          latLng =
              getLatlngFromDistance(lineStringPath, progress.coveredDistance);

          setLocation(trackDetail.track, latLng);
          var bytes = await AppHelper.widgetToBytes(Container(
            width: trackDetail.marker_text.length > 3 ? (trackDetail.marker_text
                .length) * 13 : 36,
            height: 36,
            decoration: BoxDecoration(
                color: AppHelper.hexToColor(routePathsColors[trackDetail.path ?? 'path']),
                //color: AppColors.accentLight
                borderRadius: BorderRadius.circular(40)),
            child: Center(
              child: AppText(
                  trackDetail.marker_text,
                  fontSize: 16,
                  color: routePathsColors[trackDetail.path ?? 'path'] == null ? Colors.black : AppColors.white
              ),
            ),
          ));
          var marker = apple_maps.Annotation(
            annotationId: apple_maps.AnnotationId(trackDetail.track),
            position: apple_maps.LatLng(latLng.latitude, latLng.longitude),
            infoWindow: apple_maps.InfoWindow(title: trackDetail.track),
            icon: apple_maps.BitmapDescriptor.fromBytes(bytes),
          );
          addAnnotation(
              apple_maps.AnnotationId(trackDetail.track), marker);
        } else {

          print('routePath ${trackDetail.track} ${trackDetail.path}: $routePath');
            final geodart.LineString lineStringPath = createLineStringPath(routePath);

            print('lineString ${trackDetail.track} ${lineStringPath}');

            double coveredDistance = progress.coveredDistance;
            if (coveredDistance < Precision(lineStringPath.length).toPrecision(4)) {
              print('track '+ trackDetail.track);
              print('location ${trackDetail.location}');
              print('speed: ${(getNewDistanceAfterOneSec(progress.currentSpeed))}');
              print('distance: $coveredDistance ${Precision(lineStringPath.length).toPrecision(4)}');

              if (progress.newProgressUpdate) {
                print('new update');
                progress.coveredDistance =
                    (progress.currentProgress / 100) *
                        Precision(lineStringPath.length).toPrecision(3);
                progress.newProgressUpdate = false;
              }

              print('distance2: ${getNewDistanceAfterOneSec(progress.currentSpeed)}');

              progress.coveredDistance =
                  getNewDistanceAfterOneSec(progress.currentSpeed) +
                      Precision(progress.coveredDistance).toPrecision(4);
              final latLng = getLatlngFromDistance(lineStringPath, progress.coveredDistance);

              await setLocation(trackDetail.track, latLng, wait: false, update: false);

              if (annotations.value[apple_maps.AnnotationId(trackDetail.track)] != null) {
                print('annotation update');
                final dashboardController = Get.put(DashboardController());
                if (dashboardController.selMenu.value!.label == 'track') {
                  updateAnnotation(
                    apple_maps.AnnotationId(trackDetail.track),
                    annotations.value[apple_maps.AnnotationId(
                        trackDetail.track)]!
                        .copyWith(positionParam: apple_maps.LatLng(
                        latLng.latitude, latLng.longitude)),
                  );
                }
              }

              progress.oldProgress = trackDetail.location ?? 0;
              progress.currentProgress = trackDetail.location ?? 0;
              progress.currentSpeed = trackDetail.speed ?? 0;

              trackProgressMap[trackDetail.track] = progress;
            }
        }
      }
    }
  }

  void changeMapStyle({bool setDefault = false}) {
    if (setDefault) {
      currentStyle.value = 0;
    } else {
      if (currentStyle.value == 0) {
        currentStyle.value = 1;
      } else if (currentStyle.value == 1) {
        currentStyle.value = 2;
      } else {
        currentStyle.value = 0;
      }
    }

    mapboxMap?.loadStyleURI(currentStyle.value == 0 ? MapboxStyles.MAPBOX_STREETS : (currentStyle.value == 1 ? MapboxStyles.STANDARD : MapboxStyles.SATELLITE));
    update();
  }

  Future<void> showUserLocation() async {

    bool serviceEnabled;
    geolocator.LocationPermission permission;

    try {
      // Test if location services are enabled.
      serviceEnabled = await geolocator.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled don't continue
        // accessing the position and request users of the
        // App to enable the location services.
        return Future.error('Location services are disabled.');
      }
    } catch(e) {
      ToastUtils.show('Location service is disabled');
      return;
    }

    permission = await geolocator.Geolocator.checkPermission();
    if (permission == geolocator.LocationPermission.denied) {
      permission = await geolocator.Geolocator.requestPermission();
      if (permission == geolocator.LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        //return Future.error('Location permissions are denied');
      }
    }

    if (permission == geolocator.LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      /*return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');*/
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    var position = await geolocator.Geolocator.getCurrentPosition();
    if(Platform.isAndroid) {
      mapboxMap?.setCamera(CameraOptions(
        center: Point(coordinates: Position(position.longitude, position.latitude)),
        zoom: 15,
      ));
    } else {
      appleMapController?.animateCamera(apple_maps.CameraUpdate.newCameraPosition(apple_maps.CameraPosition(target: apple_maps.LatLng(position.latitude, position.longitude), zoom: 15)));
    }
  }

  AthleteTrackDetail? findTrackDetail(AppAthleteDb entrant) {
    final trackDetail = athleteTrackDetails.value
        .firstWhereOrNull((x) => x.track == entrant.athleteId);
    if (trackDetail != null) {
      return trackDetail;
    }
    print('athletes updating 3');
    //getAthleteTrackingInfo();
    return null;
  }

  void toAthleteDetails(AppAthleteDb entrant) async {
    Get.toNamed(Routes.athleteDetails, arguments: {AppKeys.athlete: entrant});
  }

  void setAnimated(bool animated) {
    this.animated = animated;
    update();
  }

  List<LatLng> getAthleteRouthPath(AthleteTrackDetail athleteTrackDetail) {
    return routePathsCordinates[athleteTrackDetail.path] ?? [];
  }
}

class MapPathMarkers {
  final LatLng latLng;
  final String name;
  final String description;
  final String iconUrl;
  final String type;
  final String featureColor;
  final bool direction;

  MapPathMarkers(
      {required this.latLng,
      required this.name,
      required this.description, this.type = '', this.featureColor = '', this.direction = false,
      required this.iconUrl});
}

class TriangleClipper extends CustomClipper<ui.Path> {
  @override
  ui.Path getClip(ui.Size size) {
    ui.Path path = ui.Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<ui.Path> oldClipper) {
    return false;
  }
}
