// ignore_for_file: invalid_use_of_protected_member
import 'dart:io';

import 'package:carousel_slider/carousel_controller.dart';
import 'package:evento_core/core/db/app_db.dart';
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
import 'package:geodart/geometries.dart';
import 'package:geojson/geojson.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:latlong2/latlong.dart';

class TrackingController extends GetxController
    with GetTickerProviderStateMixin {
  late Tracking? trackingDetails;
  late int eventId = 0;
  late Timer timer;
  int currentII = 0;
  final athleteTrackDetails = <AthleteTrackDetail>[].obs;
  final mapDataSnap = DataSnapShot.initial.obs;
  final accessToken ='pk.eyJ1IjoidG9kZGdpbGVzIiwiYSI6ImNsdG5qYnk0ZDA0cnAya3QweTd3b2tsOGcifQ.0XC7vt0QI2JwGtAbwF9dAg';
  final terrainStyle = 'cl8bcmdxd001c15p9c5mua0jk';
  final statelliteStyle = 'cl8bcpr5y004z15s12saxlpsb';
  final mapid =  'mapbox.mapbox-streets-v8';
  final currentStyle = ''.obs;
  List<Paths> routePathLinks = [];
  List<MapPathMarkers> mapPathMarkers = [];
  Map<String, List<LatLng>> routePathsCordinates = {};
  bool animated = false;
  Map<String, LatLng> locations = {};

  MapController mapController = MapController();

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
    //if (eventId.isEmpty) {
    //  eventId = AppGlobals.appEventConfig.multiEventListId ?? '';
    //}
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
    timer.cancel();
  }

  @override
  void onReady() {
    super.onReady();
    getRoutePaths();
  }

  Future<void> setLocation(String track, LatLng location, {bool wait = false}) async {
    locations[track] = location;
    if(wait) {
      await Future.delayed(const Duration(seconds: 1));
    }
    update();
  }

  Future<void> getRoutePaths() async {
    if (trackingDetails == null) return;
    routePathLinks = List.from(trackingDetails!.paths);
    try {
      mapDataSnap.value = DataSnapShot.loading;
      for (Paths path in routePathLinks) {
        final geoJson = GeoJson();
        final res = await ApiHandler.downloadFile(baseUrl: path.url!);
        final geoJsonFile = File(res.data['file_path']);
        await geoJson.parse(await geoJsonFile.readAsString());
        final geoPoints = geoJson.lines.first.geoSerie?.geoPoints ?? [];
        if (geoPoints.isNotEmpty) {
          routePathsCordinates[path.name ?? 'path'] =
              geoPoints.map((e) => LatLng(e.latitude, e.longitude)).toList();
        }
      }
      if (trackingDetails!.mapMarkers != null) {
        final res = await ApiHandler.downloadFile(
            baseUrl: trackingDetails!.mapMarkers!);
        final geoJson = GeoJson();
        final geoJsonFile = File(res.data['file_path']);
        await geoJson.parse(await geoJsonFile.readAsString());
        final markerPoints = geoJson.features;
        if (markerPoints.isNotEmpty) {
          mapPathMarkers.clear();
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
      startTrackingTimer();
    } catch (e) {
      debugPrint(e.toString());
      mapDataSnap.value = DataSnapShot.error;
    }
  }

  void startTrackingTimer() {
    timer = Timer.periodic(Duration(seconds: trackingDetails?.updateFreq ?? 60),
        (Timer t){

      getAthleteTrackingInfo();
    });
  }

  LineString? getLineStringForPath(String pathName) {
    final routePath = routePathsCordinates[pathName];
    if (routePath != null) {
      return LineString(routePath
          .map((point) => Coordinate(point.latitude, point.longitude))
          .toList());
    } else {
      return null;
    }
  }

  LatLng initialPathCenterPoint() {
    final initalPathName = routePathsCordinates.keys.first;
    final lineString = getLineStringForPath(initalPathName);
    if (lineString != null) {
      final point = lineString.center;
      return LatLng(point.lat, point.lng);
    }
    return LatLng(0, 0);
  }

  Stream<List<AppAthleteDb>> watchFollowedAthletes() async* {
    yield* DatabaseHandler.getAthletes('', true);
  }

  Future<void> getAthleteTrackingInfo({bool firstTime = false}) async {
    if (trackingDetails == null) return;
    if(firstTime && athleteTrackDetails.isNotEmpty) {
      currentII++;
      return;
    }

    final entrants = await watchFollowedAthletes().first;
    final entrantsIds = <String>[];
    for (final AppAthleteDb entrant in entrants) {
      entrantsIds.add(entrant.athleteId);
    }
    final body = {
      'race_id': eventId,
      'web_tracking': true,
      'tracks': entrantsIds
    };
    final res = await ApiHandler.postHttp(
        baseUrl: trackingDetails!.data!, endPoint: '', body: body);
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
      athleteTrackDetails.refresh();
    }
    update();
  }

  void changeMapStyle({bool setDefault = false}) {
    if (setDefault) {
      currentStyle.value = terrainStyle;
    } else {
      if (currentStyle.value == terrainStyle) {
        currentStyle.value = statelliteStyle;
      } else {
        currentStyle.value = terrainStyle;
      }
    }
  }

  AthleteTrackDetail? findTrackDetail(AppAthleteDb entrant) {
    final trackDetail = athleteTrackDetails.value
        .firstWhereOrNull((x) => x.track == entrant.athleteId);
    if (trackDetail != null) {
      return trackDetail;
    }
    getAthleteTrackingInfo();
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
    return routePathsCordinates[athleteTrackDetail.path] ??
        routePathsCordinates.values.first;
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
