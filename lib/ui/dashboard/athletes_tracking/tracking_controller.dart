// ignore_for_file: invalid_use_of_protected_member
import 'dart:convert';
import 'dart:io';

import 'package:apple_maps_flutter/apple_maps_flutter.dart' as apple_maps;
import 'package:carousel_slider/carousel_controller.dart';
import 'package:evento_core/core/db/app_db.dart';
import 'package:evento_core/core/overlays/toast.dart';
import 'package:evento_core/ui/dashboard/athletes_tracking/map_view.dart';
import 'package:evento_core/ui/dashboard/dashboard_controller.dart';
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
  
  void addPolyline(polylineId, polyline) {
    polylines.value[polylineId] = polyline;
    update();
  }

  void addAnnotation(annotationId, annotation) {
    annotations.value[annotationId] = annotation;
    annotations.refresh();
    update();
  }

  void clearAnnotations() {
    annotations.value.clear();
    annotations.refresh();
    update();
  }

  void updateAnnotation(annotationId, annotation) {
    annotations.value[annotationId] = annotation;
    annotations.refresh();
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
    routePathLinks = List.from(trackingDetails!.paths);
    try {
      mapDataSnap.value = DataSnapShot.loading;
      mapPathMarkers.clear();
      for (Paths path in routePathLinks) {
        print(path.toJson());
        var geoJson = GeoJson();
        routePathsColors[path.name ?? 'path'] = path.color;
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
        await geoJson.parse(jsonEncode(data));
        final geoPoints = geoJson.lines.first.geoSerie?.geoPoints ?? [];
        if (geoPoints.isNotEmpty) {
          routePathsCordinates[path.name ?? 'path'] =
              geoPoints.map((e) => LatLng(e.latitude, e.longitude)).toList();
          //routePathsColors[path.name ?? 'path'] = geoJson.features.where((element) => element.properties?['color'] != null).firstOrNull?.properties?['color'];
        }
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
      debugPrint(e.toString());
      mapDataSnap.value = DataSnapShot.error;
    }
  }

  setupStaticMarkers() async {
    clearAnnotations();
    for(final marker in mapPathMarkers) {
      http.Response response = await http.get(Uri.parse(marker.iconUrl));
      Widget widget = Image.memory(
          response.bodyBytes, width: 30, height: 30);
      final String annotationIdVal = 'annotation_id_${annotations.value
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
      addAnnotation(polygonId, annotation);
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

  MapPathMarkers(
      {required this.latLng,
      required this.name,
      required this.description,
      required this.iconUrl});
}
