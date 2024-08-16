import 'dart:io';
import 'dart:typed_data';

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
import 'side_drawer.dart';

class AppleMapView extends StatefulWidget {
  const AppleMapView({super.key});

  @override
  State<AppleMapView> createState() => _AppleMapViewState();
}

class _AppleMapViewState extends State<AppleMapView> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    print('loaded again');
  }

  @override
  Widget build(BuildContext context) {
    final TrackingController controller = Get.find();

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: CustomDrawer(_scaffoldKey),
      body: Obx(() {
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
            print(controller.routePathsCordinates.values.length.toString()+'abcd');
            var positions = [];
            routePath.forEach((latLng) {
              positions.add(LatLng(latLng.latitude, latLng.longitude));
            });
            final String polylineIdVal = 'polyline_id_${polyLines.length}';
            final PolylineId polylineId = PolylineId(polylineIdVal);

            final Polyline polyline = Polyline(
              polylineId: polylineId,
              consumeTapEvents: true,
              zIndex: i+1,
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

          List<Annotation> pointAnnotations = [];

            controller.interestAnnotations.values.forEach((element) {
              pointAnnotations.addAll(element.map((e) => e as Annotation).toList());
            });

          onZoom(double zoom) {
            print(zoom);
            if(zoom >= 14) {
              if(controller.zoomedIn) {
                return;
              }
              controller.zoomedIn = true;
            } else {
              if(!controller.zoomedIn) {
                return;
              }
              controller.zoomedIn = false;
            }
            for(int x = 0; x < controller.routePathsCordinates.keys.length; x++) {
              for (int i = 1; i < controller.totalDistance.values.first; i++) {
                var annotation = controller.points['${controller.routePathsCordinates.keys.toList()[x]}_$i'];
                if (annotation != null) {
                  if (Platform.isIOS) {
                    var annotation = controller.points['${controller.routePathsCordinates.keys.toList()[x]}_$i'] as Annotation;
                    if (!controller.showDistanceMarkers.value) {
                      annotation = annotation.copyWith(
                          iconParam: BitmapDescriptor.fromBytes(Uint8List(0)));
                    } else if ((zoom) >= 14) {
                      annotation = annotation.copyWith(
                          iconParam: BitmapDescriptor.fromBytes(controller
                              .images[i]!));
                    } else {
                      annotation = annotation.copyWith(
                          iconParam: i % 5 == 0 ? BitmapDescriptor.fromBytes(
                              controller.images[i]!) : BitmapDescriptor
                              .fromBytes(AppHelper.emptyImage));
                    }
                    controller.points['${controller.routePathsCordinates.keys.toList()[x]}_$i'] = annotation;
                  }
                }
              }
            }

            controller.points.refresh();
          }


          return Stack(
            children: [
              AppleMap(
                mapType: controller.mapType.value,
                  initialCameraPosition: CameraPosition(
                      target: LatLng(
                          centerPoint.lat.toDouble(), centerPoint.lng.toDouble()),
                      zoom: AppHelper.dgetBoundsZoomLevel(
                              LatLngBounds(southwest: sw, northeast: ne),
                              height: MediaQuery.of(context).size.height,
                              width: MediaQuery.of(context).size.width) * 1.02),
                polylines: Set.of([
                  ...polyLines,
                ]),
                onMapCreated: (mapController) {
                    controller.appleMapController = mapController;
                    onZoom(AppHelper.dgetBoundsZoomLevel(
                        LatLngBounds(southwest: sw, northeast: ne),
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width) * 1.02);
                },
                onCameraMove: (position) {
                  final zoom = position.zoom;
                  onZoom(zoom);
                },
                annotations: Set.of([
                  ...controller.annotations.value.values,
                  ...controller.extraAnnotations.value.values,
                  ...pointAnnotations,
                  if(controller.showDistanceMarkers.value)
                  ...controller.points.values,
                ]),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: SafeArea(
                  child: GestureDetector(
                    onTap: () {
                      _scaffoldKey.currentState?.openEndDrawer();
                    },
                    child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Center(child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(Icons.menu, size: 24,),
                        ))),
                  ),
                ),
              ),
            ],
          );
        } else if (controller.mapDataSnap.value == DataSnapShot.error) {
          return Center(child: RetryLayout(onTap: controller.getRoutePaths));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      }),
    );
  }
}
