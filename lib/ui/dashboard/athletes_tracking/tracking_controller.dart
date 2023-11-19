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
  late String raceId = '0';
  late Timer timer;
  final athleteTrackDetails = <AthleteTrackDetail>[].obs;
  final mapDataSnap = DataSnapShot.initial.obs;
  final accessToken =
      'pk.eyJ1IjoiamV0aHJvMDA1NiIsImEiOiJjazZwazBhYTIwMDhmM2hxbGs1bWp3Z3BuIn0.F54xb2r1CQfJByfhSaIs5g';
  final terrainStyle = 'cl8bcmdxd001c15p9c5mua0jk';
  late List<LatLng> routePath = [];
  late LineString lineStringPath;

  @override
  void onInit() {
    super.onInit();
    trackingDetails = AppGlobals.appConfig!.tracking;
    raceId = AppGlobals.appEventConfig.singleEventId ?? '';
    if (raceId.isEmpty) {
      raceId = AppGlobals.appEventConfig.multiEventListId ?? '';
    }
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
    timer = Timer.periodic(Duration(seconds: trackingDetails?.updateFreq ?? 60),
        (Timer t) => getAtheteTrackingInfo());
  }

  void getRoutePaths() async {
    if (trackingDetails == null) return;
    final paths = trackingDetails!.paths ?? [];
    try {
      mapDataSnap.value = DataSnapShot.loading;
      final geoJson = GeoJson();
      for (Paths path in paths) {
        final res = await ApiHandler.downloadFile(baseUrl: path.url!);
        final geoJsonFile = File(res.data['file_path']);
        await geoJson.parse(await geoJsonFile.readAsString());
        final geoPoints = geoJson.lines.first.geoSerie?.geoPoints ?? [];
        if (geoPoints.isNotEmpty) {
          createGeoRoutePaths(
              geoPoints.map((e) => LatLng(e.latitude, e.longitude)).toList());
        }
        break;
      }
      mapDataSnap.value = DataSnapShot.loaded;
    } catch (e) {
      debugPrint(e.toString());
      mapDataSnap.value = DataSnapShot.error;
    }
  }

  void createGeoRoutePaths(List<LatLng> geoPoints) async {
    routePath = geoPoints;
    lineStringPath = LineString(routePath
        .map((point) => Coordinate(point.latitude, point.longitude))
        .toList());
  }

  Stream<List<AppAthleteDb>> watchFollowedAthletes() async* {
    yield* DatabaseHandler.getAthletes('', true);
  }

  Future<void> getAtheteTrackingInfo() async {
    if (trackingDetails == null) return;
    final entrants = await watchFollowedAthletes().first;
    final entrantsIds = <String>[];
    for (final AppAthleteDb entrant in entrants) {
      entrantsIds.add(entrant.athleteId);
    }
    final body = {
      'race_id': raceId,
      'web_tracking': true,
      'tracks': entrantsIds
    };
    final res = await ApiHandler.postHttp(
        baseUrl: trackingDetails!.data!, endPoint: '', body: body);
    if (res.statusCode == 200) {
      athleteTrackDetails.clear();
      athleteTrackDetails
          .addAll(TrackDetail.fromJson(res.data).tracks!.toList());
      athleteTrackDetails.refresh();
    }
  }

  AthleteTrackDetail? findTrackDetail(AppAthleteDb entrant) {
    final trackDetail = athleteTrackDetails.value
        .firstWhereOrNull((x) => x.track == entrant.athleteId);
    if (trackDetail != null) {
      return trackDetail;
    }
    getAtheteTrackingInfo();
    return null;
  }

  void toAthleteDetails(AppAthleteDb entrant) async {
    Get.toNamed(Routes.athleteDetails, arguments: {AppKeys.athlete: entrant});
  }
}
