// ignore_for_file: invalid_use_of_protected_member
import 'dart:io';

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
  final athleteTrackDetails = <AthleteTrackDetail>[].obs;
  final mapDataSnap = DataSnapShot.initial.obs;
  final accessToken =
      'pk.eyJ1IjoiamV0aHJvMDA1NiIsImEiOiJjazZwazBhYTIwMDhmM2hxbGs1bWp3Z3BuIn0.F54xb2r1CQfJByfhSaIs5g';
  final terrainStyle = 'cl8bcmdxd001c15p9c5mua0jk';
  final statelliteStyle = 'cl8bcpr5y004z15s12saxlpsb';
  final currentStyle = ''.obs;
  List<Paths> routePathLinks = [];
  List<MapPathMarkers> mapPathMarkers = [];
  Map<String, List<LatLng>> routePathsCordinates = {};

  @override
  void onInit() {
    super.onInit();
    trackingDetails = AppGlobals.appConfig!.tracking;
    eventId = AppGlobals.selEventId;//
    changeMapStyle(setDefault: true);
    //if (eventId.isEmpty) {
    //  eventId = AppGlobals.appEventConfig.multiEventListId ?? '';
    //}
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
      print('LOL');
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

  Future<void> getAthleteTrackingInfo() async {
    if (trackingDetails == null) return;
    final entrants = await watchFollowedAthletes().first;
    final entrantsIds = <String>[];
    for (final AppAthleteDb entrant in entrants) {
      entrantsIds.add(entrant.athleteId);
    }
    print(entrantsIds);
    print('entrantsIds');
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
    print("LOL2");
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
    print(entrant.athleteId);
    print(athleteTrackDetails.value.map((x) => x.track));
    print('LOL8');
    final trackDetail = athleteTrackDetails.value
        .firstWhereOrNull((x) => x.track == entrant.athleteId);
    if (trackDetail != null) {
      print('WHY');
      return trackDetail;
    }
    getAthleteTrackingInfo();
    return null;
  }

  void toAthleteDetails(AppAthleteDb entrant) async {
    Get.toNamed(Routes.athleteDetails, arguments: {AppKeys.athlete: entrant});
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
