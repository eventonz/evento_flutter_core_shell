import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:evento_core/core/utils/enums.dart';
import 'package:evento_core/core/utils/helpers.dart';
import 'package:evento_core/ui/dashboard/athletes_tracking/tracking_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;

import '../../../core/res/app_colors.dart';
import '../../common_components/retry_layout.dart';

class AppleMapView extends StatefulWidget {
  const AppleMapView({super.key});

  @override
  State<AppleMapView> createState() => _AppleMapViewState();
}

class _AppleMapViewState extends State<AppleMapView> {

  @override
  void initState() {
    super.initState();
    print('loaded again');
  }

  @override
  Widget build(BuildContext context) {
    final TrackingController controller = Get.find();

    return Obx(() {
      if (controller.mapDataSnap.value == DataSnapShot.loaded) {

        if(controller.counter != 0) {
          controller.getAthleteTrackingInfo();
        }

        final centerPoint = controller.initialPathCenterPoint();

        List<LatLng> bounds = [];
        List<Polyline> polyLines = [];
        List<Annotation> staticMarkers = [];

        int i = 0;
        for (var routePath in controller.routePathsCordinates.values) {
          var positions = [];
          routePath.forEach((latLng) {
            positions.add(LatLng(latLng.latitude, latLng.longitude));
          });
          final String polylineIdVal = 'polyline_id_${controller.polylines.value.length}';
          final PolylineId polylineId = PolylineId(polylineIdVal);

          final Polyline polyline = Polyline(
            polylineId: polylineId,
            consumeTapEvents: true,
            color: controller.routePathsColors.values.toList()[i] != null ? AppHelper.hexToColor(controller.routePathsColors.values.toList()[i]) : AppColors.accentDark,
            width: 3,
            points: routePath.map((element) => LatLng(element.latitude, element.longitude)).toList(),
            onTap: () {

            },
          );
          polyLines.add(polyline);

          i++;
        }

        controller.routePathsCordinates.values.forEach((element) {
          bounds.addAll(element
              .map((element) => LatLng(element.latitude, element.longitude)));
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

        var sw = LatLng(minY, minX);
        var ne = LatLng(maxY, maxX);

        return Stack(
          children: [
            AppleMap(
                initialCameraPosition: CameraPosition(
                    target: LatLng(
                        centerPoint.lat.toDouble(), centerPoint.lng.toDouble()),
                    zoom: AppHelper.dgetBoundsZoomLevel(
                            LatLngBounds(southwest: sw, northeast: ne),
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width) * 1.02),
              polylines: Set.of(polyLines),
              onMapCreated: (mapController) {
                  controller.appleMapController = mapController;
              },
              annotations: Set.of(controller.annotations.value.values),
            )
          ],
        );
      } else if (controller.mapDataSnap.value == DataSnapShot.error) {
        return Center(child: RetryLayout(onTap: controller.getRoutePaths));
      } else {
        return const Center(child: CircularProgressIndicator());
      }
    });
  }
}
