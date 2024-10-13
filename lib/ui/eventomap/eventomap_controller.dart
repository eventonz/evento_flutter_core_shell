import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:apple_maps_flutter/apple_maps_flutter.dart' as apple_maps;
import 'package:evento_core/core/models/app_config.dart';
import 'package:evento_core/core/models/trail.dart';
import 'package:evento_core/ui/dashboard/athletes_tracking/map_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geodart/geometries.dart' as geodart;
import 'package:geojson/geojson.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:screenshot/screenshot.dart';

import '../../core/overlays/toast.dart';
import '../../core/utils/api_handler.dart';
import '../../core/utils/app_global.dart';
import '../../core/utils/helpers.dart';
import '../../core/utils/keys.dart';
import '../../core/utils/preferences.dart';
import 'package:latlong2/latlong.dart' as latlong;

import '../dashboard/athletes_tracking/tracking_controller.dart';

class EventoMapController extends GetxController {

  RxBool loading = true.obs;
  String? sourceId = '';
  Rx<Trail?> trail = Rx(null);

  List<Position> routePathsCordinates = [];

  PointAnnotation? elevationAnnotation;
  Rx<apple_maps.Annotation?> elevationAnnotationApple = Rx(null);
  Uint8List? elevationImage;

  bool showStartIcon = false;
  bool showFinishIcon = false;
  String color = '#000000';

  final ScreenshotController screenshotController = ScreenshotController();
  MapboxMap? mapboxMap;
  final geoJson = GeoJson();

  Rx<List<String>> selectedInterests = Rx(['']);

  Rx<String> mapStyle = MapboxStyles.OUTDOORS.obs;
  Rx<apple_maps.MapType> mapType = apple_maps.MapType.standard.obs;

  RxMap<apple_maps.AnnotationId, apple_maps.Annotation> annotations = <apple_maps.AnnotationId, apple_maps.Annotation>{}.obs;

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

  RxMap<int, dynamic> points = <int, dynamic>{}.obs;
  Map<int, Uint8List> images = {};

  RxMap<String, List<dynamic>> interestAnnotations = <String, List<dynamic>>{}.obs;
  Map<String, Uint8List> interestImages = {};

  double totalDistance = 0;

  PointAnnotationManager? pointAnnotationManager;

  apple_maps.AppleMapController? appleMapsController;

  bool zoomedIn = false;
  RxBool showElevation = false.obs;
  RxBool showDistanceMarkers = false.obs;

  @override
  void onInit() {
    super.onInit();
    final res = Get.arguments;
    sourceId = res['source_id'];
    Uri uri = Uri.parse(sourceId!);
    List<String> pathSegments = uri.pathSegments;
    sourceId = pathSegments.last;
    getConfig();
  }

  @override
  void onReady() {
    super.onReady();
  }

  void changeElevation(bool show) {
    showElevation.value = show;
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

      //appleMapController?.animateCamera(apple_maps.CameraUpdate.newCameraPosition(apple_maps.CameraPosition(target: apple_maps.LatLng(position.latitude, position.longitude), zoom: 15)));
    }
  }


  void changeDistanceMarkers(bool show) async {
    showDistanceMarkers.value = show;
    update();

    final state = await mapboxMap?.getCameraState();
    print(state?.zoom);
    for(int i = 1; i < totalDistance; i++) {
      final annotation = points[i];
      if(annotation != null) {
        if(!Platform.isIOS) {
          if(showDistanceMarkers.value == false) {
            annotation.image = null;
          } else if((state?.zoom ?? 0) >= 14) {
            annotation.image = images[i];
          } else {
            annotation.image = i % 5 == 0 ? images[i] : null;
          }
          pointAnnotationManager?.update(annotation);
        } else {
          var zoom = await appleMapsController?.getZoomLevel()??0;
          var annotation = points[i] as apple_maps.Annotation;
          if(!showDistanceMarkers.value) {
            annotation = annotation.copyWith(iconParam: apple_maps.BitmapDescriptor.fromBytes(Uint8List(0)));

          } else if((zoom) >= 14) {
            annotation = annotation.copyWith(iconParam: apple_maps.BitmapDescriptor.fromBytes(images[i]!));
          } else {
            annotation = annotation.copyWith(iconParam: i % 5 == 0 ? apple_maps.BitmapDescriptor.fromBytes(images[i]!) : apple_maps.BitmapDescriptor.fromBytes(AppHelper.emptyImage));
          }
          points[i] = annotation;
          points.refresh();
        }

      }
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

  Future<void> getConfig() async {
    try {
      final url = 'maps/${sourceId}';
      final res = await ApiHandler.getHttp(endPoint: url);
      trail.value = Trail.fromJson((res.data));

      final res2 = await ApiHandler.downloadFile(
          baseUrl: trail.value!.geojsonFile);

      final geoJsonFile = File(res2.data['file_path']);
      final map = await geoJsonFile.readAsString();
      final mapJson = jsonDecode(map);

      final features = mapJson['features'] as List;
      for (var feature in features) {
        if (feature['geometry']['type'] == 'Point') {
          final coordinates = feature['geometry']['coordinates'] as Map;
          print(coordinates);
          feature['geometry']['coordinates'] =
          [coordinates['lng'], coordinates['lat']];
        }
      }


      await geoJson.parse(jsonEncode(mapJson));
      final geoPoints = geoJson.lines.first.geoSerie?.geoPoints ?? [];

      showStartIcon = geoJson.features
          .where((element) => element.properties?['start_icon'] == true)
          .isNotEmpty;
      showFinishIcon = geoJson.features
          .where((element) => element.properties?['finish_icon'] == true)
          .isNotEmpty;
      showDistanceMarkers.value = geoJson.features
          .where((element) => element.properties?['distance_markers'] == true)
          .isNotEmpty;
      color = geoJson.features
          .where((element) => element.properties?['color'] != null)
          .firstOrNull
          ?.properties?['color'] ?? '#000000';

      if (geoPoints.isNotEmpty) {
        routePathsCordinates =
            geoPoints.map((e) => Position(e.longitude, e.latitude)).toList();
      }

      if (Platform.isIOS) {
        if (showStartIcon) {
          Widget widget = SvgPicture.asset(
              AppHelper.getSvg('startingpoint'), width: 27, height: 27);
          annotations[apple_maps.AnnotationId('start_icon')] =
              apple_maps.Annotation(
                  annotationId: apple_maps.AnnotationId('start_icon'),
                  position: apple_maps.LatLng(
                      routePathsCordinates.first.lat.toDouble(),
                      routePathsCordinates.first.lng.toDouble()),
                  icon: apple_maps.BitmapDescriptor.fromBytes(
                      await AppHelper.widgetToBytes(widget)));
        }

        if (showFinishIcon) {
          Widget widget = SvgPicture.asset(
              AppHelper.getSvg('finishpoint'), width: 27, height: 27);

          annotations[apple_maps.AnnotationId('finish_icon')] =
              apple_maps.Annotation(
                  annotationId: apple_maps.AnnotationId('finish_icon'),
                  position: apple_maps.LatLng(
                      routePathsCordinates.last.lat.toDouble(),
                      routePathsCordinates.last.lng.toDouble()),
                  icon: apple_maps.BitmapDescriptor.fromBytes(
                      await AppHelper.widgetToBytes(widget)));
        }

        Widget widget = Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: SvgPicture.asset(
              AppHelper.getSvg('startingpoint'), color: Colors.black,
              width: 16,
              height: 16),
        );

        AppHelper.widgetToBytes(widget).then((bytes) {
          elevationAnnotationApple.value =
              apple_maps.Annotation(
                  annotationId: apple_maps.AnnotationId('elevation_icon'),
                  position: apple_maps.LatLng(
                      routePathsCordinates.first.lat.toDouble(),
                      routePathsCordinates.first.lng.toDouble()),
                  icon: apple_maps.BitmapDescriptor.fromBytes(Uint8List(0)));
          elevationImage = bytes;
        });

        final points = geoJson.features;
        for (int index = 0; index < points.length; index++) {
          var element = points[index];
          if (element.type == GeoJsonFeatureType.point) {
            print(geoJson.features[index]
                .properties);
            Widget widget = element
                .properties?['type'] == 'custom' ? Image.network('${element
                .properties?['icon']}', width: 30, height: 30) : Image.asset(AppHelper.getImage('${element
                .properties?['type']}.png'), width: 30, height: 30);
            AppHelper.widgetToBytes(widget, milliseconds: element
                .properties?['type'] == 'custom' ? 2000 : 100)
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
                  appleMapsController?.animateCamera(apple_maps.CameraUpdate.newCameraPosition(apple_maps.CameraPosition(target: apple_maps.LatLng((point.geometry as GeoJsonPoint).geoPoint.latitude, (point.geometry as GeoJsonPoint).geoPoint.longitude), zoom: 18)));
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
                                      point
                                          .properties?['type'] == 'custom' ? Image.network('${element
                                          .properties?['icon']}', width: 30, height: 30) : Image.asset(AppHelper.getImage('${point
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
                                if((point.properties?['image'] ?? '') != '')
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Image.network(point.properties?['image']),
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

                  routePathsCordinates.forEach((element) {
                    bounds.add(LatLng(element.lat.toDouble(), element.lng.toDouble()));
                  });
                  appleMapsController?.animateCamera(apple_maps.CameraUpdate.newCameraPosition(apple_maps.CameraPosition(
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

        if (showDistanceMarkers.value) {
          final lineString = getLineStringForPath();
          final totalDistance = calculateTotalDistance();

          for (int i = 1; i < totalDistance; i++) {
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

            AppHelper.widgetToBytes(widget).then((bytes) {
              images[i] = bytes;

              apple_maps.Annotation pointAnnotation = apple_maps.Annotation(
                  annotationId: apple_maps.AnnotationId('distance_$i'),
                  position: apple_maps.LatLng(lineString
                      .along(i.toDouble() * 1000)
                      .lat, lineString
                      .along(i.toDouble() * 1000)
                      .lng),
                  icon: apple_maps.BitmapDescriptor.fromBytes(
                      i % 5 == 0 ? images[i]! : Uint8List(0)));
              this.points[i] = pointAnnotation;
              this.points.refresh();
            });
            //}
          }
        }
      }
    } catch(e) {
      ToastUtils.show(null);

    }


    loading.value = false;
    update();
  }

  geodart.LineString getLineStringForPath() {
    final routePath = routePathsCordinates;
    return geodart.LineString(routePath
        .map((point) => geodart.Coordinate(point.lat.toDouble(), point.lng.toDouble()))
        .toList());
  }

  double calculateTotalDistance() {
    if (routePathsCordinates.length < 2) {
      return 0.0;
    }

    double totalDistance = 0.0;
    const distanceCalculator = latlong.Distance();

    for (int i = 0; i < routePathsCordinates.length - 1; i++) {
      final point1 = routePathsCordinates[i];
      final point2 = routePathsCordinates[i + 1];
      final distance = distanceCalculator.as(
        latlong.LengthUnit.Centimeter,
        latlong.LatLng(point1.lat.toDouble(), point1.lng.toDouble()),
        latlong.LatLng(point2.lat.toDouble(), point2.lng.toDouble()),
      );
      totalDistance += distance;
    }

    print(totalDistance);
    totalDistance = latlong.LengthUnit.Centimeter.to(latlong.LengthUnit.Kilometer, totalDistance);
    print(totalDistance);

    this.totalDistance = totalDistance;

    return totalDistance;
  }


  Position initialPathCenterPoint() {
    final lineString = getLineStringForPath();
    if (lineString.length != 0) {

      final point = lineString.center;
      return Position(point.lng, point.lat);
    }
    return Position(0, 0);
  }
}