import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:evento_core/core/models/app_config.dart';
import 'package:evento_core/core/models/trail.dart';
import 'package:geodart/geometries.dart' as geodart;
import 'package:geojson/geojson.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:screenshot/screenshot.dart';

import '../../core/utils/api_handler.dart';
import '../../core/utils/app_global.dart';
import '../../core/utils/keys.dart';
import '../../core/utils/preferences.dart';
import 'package:latlong2/latlong.dart' as latlong;

class EventoMapController extends GetxController {

  RxBool loading = true.obs;
  String? sourceId = '';
  Rx<Trail?> trail = Rx(null);

  List<Position> routePathsCordinates = [];

  bool showStartIcon = false;
  bool showFinishIcon = false;
  String color = '#000000';

  final ScreenshotController screenshotController = ScreenshotController();
  MapboxMap? mapboxMap;
  final geoJson = GeoJson();

  Rx<List<String>> selectedInterests = Rx(['']);

  Rx<String> mapStyle = MapboxStyles.OUTDOORS.obs;

  List<String> mapStyles = [
    MapboxStyles.OUTDOORS,
    MapboxStyles.SATELLITE,
    MapboxStyles.STANDARD,
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

  Map<int, PointAnnotation> points = {};
  Map<int, Uint8List> images = {};

  Map<String, List<PointAnnotation>> interestAnnotations = {};
  Map<String, Uint8List> interestImages = {};

  double totalDistance = 0;

  PointAnnotationManager? pointAnnotationManager;

  bool zoomedIn = false;
  RxBool showElevation = false.obs;
  RxBool showDistanceMarkers = false.obs;

  @override
  void onInit() {
    super.onInit();
    final res = Get.arguments;
    Items item = res[AppKeys.moreItem];
    Uri uri = Uri.parse(item.sourceId!);
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

  void changeDistanceMarkers(bool show) async {
    showDistanceMarkers.value = show;
    update();

    final state = await mapboxMap?.getCameraState();
    print(state?.zoom);
    for(int i = 1; i < totalDistance-1; i++) {
      final annotation = points[i];
      if(annotation != null) {
        if(showDistanceMarkers.value == false) {
          annotation.image = null;
        } else if((state?.zoom ?? 0) >= 14) {
          annotation.image = images[i];
        } else {
          annotation.image = i % 5 == 0 ? images[i] : null;
        }
        pointAnnotationManager?.update(annotation);
      }
    }
  }

  void updateSelectedInterests(List<String> values) {
    selectedInterests.value = values;
    update();
    if(values.contains('')) {
      interestAnnotations.keys.forEach((value) {
        interestAnnotations[value]?.forEach((element) {
          element.image = interestImages[value];
          pointAnnotationManager?.update(element);
        });
      });
    } else {
      interestAnnotations.keys.forEach((value) {
        interestAnnotations[value]?.forEach((element) {
          element.image = null;
          pointAnnotationManager?.update(element);
        });
      });
      for (var value in values) {
        interestAnnotations[value]?.forEach((element) {
          element.image = interestImages[value];
          pointAnnotationManager?.update(element);
        });
      }
    }
  }

  String getStyleName(String style) {
    if(style == MapboxStyles.OUTDOORS) {
      return 'Outdoors';
    } else if(style == MapboxStyles.SATELLITE) {
      return 'Satellite';
    } else if(style == MapboxStyles.STANDARD) {
      return '3D';
    } else {
      return 'Default';
    }
  }

  void changeStyle(int index) {
    mapStyle.value = mapStyles[index];
    mapboxMap?.loadStyleURI(mapStyles[index]);
    update();
    

    //mapboxMap?.style.addSource(RasterDemSource(id: 'mapbox-dem', url: 'mapbox://mapbox.mapbox-terrain-dem-v1', tileSize: 512, maxzoom: 14));
    // add the DEM source as a terrain layer with exaggerated height
    //mapboxMap.style.til();
    mapboxMap?.style.setStyleTerrain(jsonEncode({ 'source': 'mapbox-dem', 'exaggeration': 3.0 }));
  }

  Future<void> getConfig() async {
    final url = 'maps/${sourceId}';
    final res = await ApiHandler.getHttp(endPoint: url);
    trail.value = Trail.fromJson((res.data));

    final res2 = await ApiHandler.downloadFile(baseUrl: trail.value!.geojsonFile);

    final geoJsonFile = File(res2.data['file_path']);
    final map = await geoJsonFile.readAsString();
    final mapJson = jsonDecode(map);

    final features = mapJson['features'] as List;
    for (var feature in features) {
      if (feature['geometry']['type'] == 'Point') {
        final coordinates = feature['geometry']['coordinates'] as Map;
        print(coordinates);
        feature['geometry']['coordinates'] = [coordinates['lng'], coordinates['lat']];
      }
    }


    await geoJson.parse(jsonEncode(mapJson));
    final geoPoints = geoJson.lines.first.geoSerie?.geoPoints ?? [];

    showStartIcon = geoJson.features.where((element) => element.properties?['start_icon'] == true).isNotEmpty;
    showFinishIcon = geoJson.features.where((element) => element.properties?['finish_icon'] == true).isNotEmpty;
    showDistanceMarkers.value = geoJson.features.where((element) => element.properties?['distance_markers'] == true).isNotEmpty;
    color = geoJson.features.where((element) => element.properties?['color'] != null).firstOrNull?.properties?['color'] ?? '#000000';

    if (geoPoints.isNotEmpty) {
      routePathsCordinates =
          geoPoints.map((e) => Position(e.longitude, e.latitude)).toList();
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
    if (lineString != null) {

      final point = lineString.center;
      return Position(point.lng, point.lat);
    }
    return Position(0, 0);
  }
}