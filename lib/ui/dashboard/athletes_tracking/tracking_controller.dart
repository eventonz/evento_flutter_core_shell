// ignore_for_file: invalid_use_of_protected_member

import 'dart:convert';
import 'dart:io';

import 'package:evento_core/app_event_config.dart';
import 'package:evento_core/core/db/app_db.dart';
import 'package:evento_core/core/models/app_config.dart';
import 'package:evento_core/core/models/athlete_track_detail.dart';
import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/core/routes/routes.dart';
import 'package:evento_core/core/utils/api_handler.dart';
import 'package:evento_core/core/utils/app_global.dart';
import 'package:evento_core/core/utils/enums.dart';
import 'package:evento_core/core/utils/keys.dart';
import 'package:flutter/material.dart';
import 'package:geojson/geojson.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';

class TrackingController extends GetxController {
  late Tracking trackingDetails;
  late String raceId;
  late Timer timer;
  final trackDetails = <AthleteTrackDetail>[].obs;
  final mapAccessToken =
      'sk.eyJ1IjoiamV0aHJvMDA1NiIsImEiOiJjbGZsYmoxcGcwMGN3M3pwNmtzeHQzcjh2In0.hfTYWDNzpnMKtzcoOjJBZA';
  late MapboxMap mapBoxMap;
  final geo = GeoJson();

  @override
  void onInit() {
    super.onInit();
    trackingDetails = AppGlobals.appConfig!.tracking!;
    raceId = AppGlobals.appEventConfig.singleEventId ?? '';
    if (raceId.isEmpty) {
      raceId = AppGlobals.appEventConfig.multiEventListId ?? '';
    }
  }

  @override
  void onReady() {
    super.onReady();
    getAtheteTrackingInfo();
    timer = Timer.periodic(Duration(seconds: trackingDetails.updateFreq!),
        (Timer t) => getAtheteTrackingInfo());
  }

  @override
  void onClose() {
    super.onClose();
    timer.cancel();
  }

  Stream<List<AppAthleteDb>> watchFollowedAthletes() async* {
    yield* DatabaseHandler.getAthletes('', true);
  }

  void createGeoJsonTracks() async {
    final paths = trackingDetails.paths ?? [];
    for (Paths path in paths) {
      final res = await ApiHandler.downloadFile(baseUrl: path.url!);
      final geoJsonFile = File(res.data['file_path']);
      await geo.parse(await geoJsonFile.readAsString(), verbose: true);
      await mapBoxMap.style.addSource(
        GeoJsonSource(
          data: await geoJsonFile.readAsString(),
          id: path.name,
          lineMetrics: true,
        ),
      );
      await mapBoxMap.style.addLayer(LineLayer(
          id: 'line_layer',
          sourceId: path.name!,
          lineJoin: LineJoin.ROUND,
          lineCap: LineCap.ROUND,
          lineColor: Colors.grey.value,
          lineWidth: 6.0));
    }
    mapBoxMap.setCamera(
      CameraOptions(
          center: Point(coordinates: Position(176.251594, -38.176509)).toJson(),
          zoom: 15),
    );
  }

  Future<void> getAtheteTrackingInfo() async {
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
        baseUrl: trackingDetails.data!, endPoint: '', body: body);
    if (res.statusCode == 200) {
      trackDetails.clear();
      trackDetails.addAll(TrackDetail.fromJson(res.data).tracks!.toList());
      trackDetails.refresh();
    }
  }

  AthleteTrackDetail? findTrackDetail(AppAthleteDb entrant) {
    final trackDetail = trackDetails.value
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
