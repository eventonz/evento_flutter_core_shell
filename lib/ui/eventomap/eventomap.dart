import 'dart:convert';
import 'dart:io';

import 'package:apple_maps_flutter/apple_maps_flutter.dart' as apple_maps;
import 'package:collection/collection.dart';
import 'package:evento_core/core/utils/helpers.dart';
import 'package:evento_core/ui/common_components/text.dart';
import 'package:evento_core/ui/eventomap/eventomap_controller.dart';
import 'package:evento_core/ui/eventomap/side_drawer.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geojson/geojson.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../core/res/app_colors.dart';
import '../common_components/no_data_found_layout.dart';
import '../dashboard/athletes_tracking/map_view.dart';
import '../settings/settings_controller.dart';

class EventoMap extends StatefulWidget {
  const EventoMap({super.key});

  @override
  State<EventoMap> createState() => _EventoMapState();
}

class _EventoMapState extends State<EventoMap> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {

    final controller = Get.put(EventoMapController());

    print('hello');
    print(controller.routePathsCordinates.firstOrNull?.lat);
    print(controller.routePathsCordinates.firstOrNull?.lng);

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
      for(int i = 1; i < controller.totalDistance; i++) {
        var annotation = controller.points[i];
        if(annotation != null) {
          if(Platform.isIOS) {
            var annotation = controller.points[i] as apple_maps.Annotation;
            if(!controller.showDistanceMarkers.value) {
              annotation = annotation.copyWith(iconParam: apple_maps.BitmapDescriptor.fromBytes(Uint8List(0)));

            } else if((zoom) >= 14) {
              annotation = annotation.copyWith(iconParam: apple_maps.BitmapDescriptor.fromBytes(controller.images[i]!));
            } else {
              annotation = annotation.copyWith(iconParam: i % 5 == 0 ? apple_maps.BitmapDescriptor.fromBytes(controller.images[i]!) : apple_maps.BitmapDescriptor.fromBytes(AppHelper.emptyImage));
            }
            controller.points[i] = annotation;


          } else {
            if(!controller.showDistanceMarkers.value) {
              annotation.image = null;

            } else if(zoom >= 14) {
              annotation.image = controller.images[i];
            } else {
              annotation.image = i % 5 == 0 ? controller.images[i] : null;
            }
            controller.pointAnnotationManager?.update(annotation);
          }

        }
      }
      controller.points.refresh();
    }

    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Center(
          child: InkWell(
            onTap: () {
              Get.back();
            },
            child: CircleAvatar(
                backgroundColor: Theme.of(context).cardColor,
                child: Center(child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(Icons.arrow_back_ios, color: Theme.of(context).colorScheme.secondary, size: 24,),
                ))),
          ),
        ),
        actions: [
          Center(
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
          const SizedBox(width: 16),
        ],
      ),
      endDrawer: CustomDrawer(_scaffoldKey),

      body: Obx(() {

      List<LatLng> bounds = [];

      if (controller.loading.value == false) {
        controller.routePathsCordinates.forEach((element) {
          bounds.add(LatLng(element.lat.toDouble(), element.lng.toDouble()));
        });
      }

      List<Color> gradientColors = [
        AppColors.contentColorCyan,
        AppColors.contentColorBlue,
      ];

      Widget leftTitleWidgets(double value, TitleMeta meta) {
        const style = TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        );

        double maxElevation = controller.trail.value?.elevationData.map((e) => e[1].toDouble()).reduce((a, b) => a > b ? a : b) ?? 0;
        double step = maxElevation / 5;

        double top = 0;
        double bottom = 0;

        String text = '';
        if (value == step * 1) {
          top = 36;
          text = (step * 1).toStringAsFixed(0) + 'm';
        } else if (value == step * 5) {
          top = 0;
          text = (step * 5).toStringAsFixed(0) + 'm';
        }

        return Container(
            margin: EdgeInsets.only(top: top, bottom: bottom),
            child: Text(text, style: style, textAlign: TextAlign.left));
      }

      LineChartData mainData() {
        List<List<num>> elevationData = controller.trail.value?.elevationData ?? [];
        double maxX = elevationData.map((e) => e[0].toDouble()).reduce((a, b) => a > b ? a : b);
        double maxY = elevationData.map((e) => e[1].toDouble()).reduce((a, b) => a > b ? a : b);
        double minX = elevationData.map((e) => e[0].toDouble()).reduce((a, b) => a < b ? a : b);
        return LineChartData(
          lineTouchData: LineTouchData(
              handleBuiltInTouches: true,
              touchCallback: (event, response) {
                if(!event.isInterestedForInteractions) {
                 if(Platform.isIOS) {
                   controller.elevationAnnotationApple.value = controller.elevationAnnotationApple.value?.copyWith(
                     iconParam: apple_maps.BitmapDescriptor.fromBytes(Uint8List(0))
                   );
                 } else {
                   controller.elevationAnnotation!.image = null;
                   controller.pointAnnotationManager?.update(
                       controller.elevationAnnotation!);
                 }
                  return;
                }
              if (response == null || response.lineBarSpots == null) {
                return;
              }
                if(Platform.isIOS) {
                  if(controller.elevationAnnotationApple.value != null) {
                    controller.elevationAnnotationApple.value = controller.elevationAnnotationApple.value?.copyWith(
                        iconParam: apple_maps.BitmapDescriptor.fromBytes(controller.elevationImage!),
                        positionParam: apple_maps.LatLng(controller.getLineStringForPath().along((response.lineBarSpots?.first.x ?? 1)*1000).lat, controller.getLineStringForPath().along((response.lineBarSpots?.first.x ?? 1)*1000).lng),
                    );
                  }
                } else {
                  if(controller.elevationAnnotation != null) {
                    controller.elevationAnnotation!.image = controller.elevationImage;
                    controller.elevationAnnotation!.geometry = Point(coordinates: Position(controller.getLineStringForPath().along((response.lineBarSpots?.first.x ?? 1)*1000).lng, controller.getLineStringForPath().along((response.lineBarSpots?.first.x ?? 1)*1000).lat)).toJson();
                    controller.pointAnnotationManager?.update(
                        controller.elevationAnnotation!);
                  }
                }
                controller.elevationAnnotationApple.refresh();
              }
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxY*1.1) / 1,
            verticalInterval: maxX / 2,
            getDrawingHorizontalLine: (value) {
              return const FlLine(
                color: AppColors.black,
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return const FlLine(
                color: AppColors.black,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: maxY / 5,
                getTitlesWidget: leftTitleWidgets,
                reservedSize: 45,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: const Color(0xff37434d)),
          ),
          minX: minX,
          maxX: maxX,
          minY: 0,
          maxY: maxY*1.1,
          lineBarsData: [
            LineChartBarData(
              spots: [
                ...controller.trail.value?.elevationData.map((e) => FlSpot(double.parse(e.first.toStringAsFixed(0)), double.parse(e.last.toStringAsFixed(0)))).toList() ?? [],
              ],
              isCurved: true,
              gradient: LinearGradient(
                colors: gradientColors,
              ),
              barWidth: 5,
              isStrokeCapRound: true,
              dotData: const FlDotData(
                show: false,
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: gradientColors
                      .map((color) => color.withOpacity(0.3))
                      .toList(),
                ),
              ),
            ),
          ],
        );
      }

      List<apple_maps.Annotation> pointAnnotations = [];

      if(Platform.isIOS) {
        controller.interestAnnotations.values.forEach((element) {
          pointAnnotations.addAll(element.map((e) => e as apple_maps.Annotation).toList());
        });
      }

        return controller.loading.value ? Center(
          child: CircularProgressIndicator(color: Theme.of(context).colorScheme.secondary, strokeWidth: 1),
        ) : Stack(
          children: [
            if(Platform.isIOS)
              apple_maps.AppleMap(
                mapType: controller.mapType.value,
                onCameraMove: (cameraPosition) {
                  final zoom = cameraPosition.zoom;
                  onZoom(zoom);
                },
                compassEnabled: false,
                padding: const EdgeInsets.only(top: 60, right: 10),
                initialCameraPosition: apple_maps.CameraPosition(
                target: controller.initialPathCenterPoint().lat.toDouble() == 0.0 ? apple_maps.LatLng(-42.0178775,174.3417791) : apple_maps.LatLng(controller.initialPathCenterPoint().lat.toDouble(), controller.initialPathCenterPoint().lng.toDouble()),
                zoom: bounds.isEmpty ? 5 : TrackingMapView.dgetBoundsZoomLevel(
                    LatLngBounds.fromPoints(bounds), {

                  'height': MediaQuery
                      .of(context)
                      .size
                      .height,
                  'width': MediaQuery
                      .of(context)
                      .size
                      .width})*1.05,
              ), polylines: Set.of([apple_maps.Polyline(width: 3, color: AppHelper.hexToColor(controller.color), polylineId: apple_maps.PolylineId('route'), points: controller.routePathsCordinates.map((e) => apple_maps.LatLng(e.lat.toDouble(), e.lng.toDouble())).toList())]),
                annotations: Set.of([...controller.annotations.values, ...pointAnnotations, if(controller.elevationAnnotationApple.value != null)controller.elevationAnnotationApple.value!, ...controller.points.values]),
                onMapCreated: (appleMapsController) {
                  controller.appleMapsController = appleMapsController;
                },
              )
            else
              MapWidget(
                styleUri: controller.mapStyle.value,
                cameraOptions: CameraOptions(
                    center: Point(coordinates:
                    controller.initialPathCenterPoint()

                    ).toJson(),
                    zoom: TrackingMapView.dgetBoundsZoomLevel(
                        LatLngBounds.fromPoints(bounds), {
                      'height': MediaQuery
                          .of(context)
                          .size
                          .height,
                      'width': MediaQuery
                          .of(context)
                          .size
                          .width})
                ),
                onCameraChangeListener: (data) async {
                  final state = await controller.mapboxMap?.getCameraState();
                  var zoom = state?.zoom ?? 0;
                  onZoom(zoom);
                },
                onMapCreated: (mapboxMap) {
                  controller.mapboxMap = mapboxMap;
                  mapboxMap.style.addSource(RasterDemSource(id: 'mapbox-dem', url: 'mapbox://mapbox.mapbox-terrain-dem-v1', tileSize: 512, maxzoom: 14));
                  // add the DEM source as a terrain layer with exaggerated height
                  //mapboxMap.style.til();
                  mapboxMap.style.setStyleTerrain(jsonEncode({ 'source': 'mapbox-dem', 'exaggeration': 3.0 }));

                  mapboxMap.location.updateSettings(LocationComponentSettings(
                      enabled: true,
                      pulsingEnabled: true
                  ));

                  mapboxMap.compass.updateSettings(CompassSettings(
                    marginTop: 60,
                    marginRight: 16,
                  ));

                  mapboxMap.annotations.createPolylineAnnotationManager().then((
                      value) async {
                    final polylineAnnotationManager = value;
                    polylineAnnotationManager.create(PolylineAnnotationOptions(
                        geometry: LineString(
                            coordinates: controller.routePathsCordinates).toJson(),
                        lineColor: AppHelper.hexToColor(controller.color).value, lineWidth: 3));
                  });
                  mapboxMap.annotations.createPointAnnotationManager().then((value) async {
                    final pointAnnotationManager = value;
                    controller.pointAnnotationManager = pointAnnotationManager;

                    if(controller.showStartIcon) {
                      Widget widget = SvgPicture.asset(
                          AppHelper.getSvg('startingpoint'), width: 27, height: 27);
                      controller.screenshotController.captureFromWidget(widget)
                          .then((value) {
                        pointAnnotationManager.create(PointAnnotationOptions(
                          geometry: Point(
                              coordinates: controller.routePathsCordinates.first)
                              .toJson(),
                          image: value,
                        ));
                      });
                    }

                    Widget widget = Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: SvgPicture.asset(
                          AppHelper.getSvg('startingpoint'), color: Colors.black, width: 16, height: 16),
                    );
                    controller.screenshotController.captureFromWidget(widget)
                        .then((value) {
                      pointAnnotationManager.create(PointAnnotationOptions(
                        geometry: Point(
                            coordinates: controller.routePathsCordinates.first)
                            .toJson(),
                        image: value,
                      )).then((val) {
                        controller.elevationAnnotation = val;
                        controller.elevationImage = value;
                      });
                    });

                    if(controller.showFinishIcon) {
                      Widget widget = SvgPicture.asset(
                          AppHelper.getSvg('finishpoint'), width: 27, height: 27);
                      controller.screenshotController.captureFromWidget(widget)
                          .then((value) {
                        pointAnnotationManager.create(PointAnnotationOptions(
                          geometry: Point(
                              coordinates: controller.routePathsCordinates.last)
                              .toJson(),
                          image: value,
                        ));
                      });
                    }

                    final points = controller.geoJson.features;
                    for (int index = 0; index < points.length; index++) {
                      var element = points[index];
                      if(element.type == GeoJsonFeatureType.point) {
                        Widget widget = Image.asset(AppHelper.getImage('${element
                            .properties?['type']}.png'), width: 30, height: 30);
                        controller.screenshotController.captureFromWidget(widget)
                            .then((value) async {
                          PointAnnotation pointAnnotation = await pointAnnotationManager
                              .create(PointAnnotationOptions(
                            geometry: Point(coordinates: Position(
                                (element.geometry as GeoJsonPoint).geoPoint
                                    .longitude,
                                (element.geometry as GeoJsonPoint).geoPoint
                                    .latitude)).toJson(),
                            image: value,
                          ));
                          if (controller.interestAnnotations[element
                              .properties?['type']] == null) {
                            controller.interestAnnotations[element
                                .properties?['type']] = [];
                            controller.interestImages[element
                                .properties?['type']] = value;
                          }
                          controller.interestAnnotations[element
                              .properties?['type']]!.add(pointAnnotation);
                          controller.geoJson.features[index]
                              .properties?['annotation'] = pointAnnotation.id;
                        });
                      }
                      print(controller.geoJson.features.length);
                    }
                    pointAnnotationManager.addOnPointAnnotationClickListener(AnnotationClickListener((annotation) {
                      var point = controller.geoJson.features.where((element) => element.properties?['annotation'] == annotation.id).firstOrNull;
                      if(point == null) {
                        return;
                      }
                      showModalBottomSheet(context: context, builder: (_) => BottomSheet(
                          elevation: 0,
                          onClosing: () {}, builder: (_) => Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0, bottom: 12.0),
                              child: Row(
                                children: [
                                  Image.asset(AppHelper.getImage('${point
                                      .properties?['type']}.png'), width: 30, height: 30),
                                  const SizedBox(width: 8),
                                  Text('${point.properties?['title']}', style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  )),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0),
                              child: Text('${point.properties?['description']}', style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              )),
                            ),
                            if(point.properties?['direction'] == true)
                              ...[
                                const SizedBox(height: 16),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                  child: ElevatedButton(onPressed: () {
                                    AppHelper.showDirectionsOnMap(apple_maps.LatLng((point.geometry as GeoJsonPoint).geoPoint.latitude, (point.geometry as GeoJsonPoint).geoPoint.longitude));
                                  }, style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
                                    shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
                                  ), child: Text('Get Directions', style: TextStyle(
                                    color: Theme.of(context).cardColor,
                                  ),),),
                                ),
                              ],
                            SizedBox(height: MediaQuery.of(context).padding.bottom+8),
                          ],
                        ),
                      )));
                    }));

                    //if(controller.showDistanceMarkers.value) {
                    final lineString = controller.getLineStringForPath();
                    final totalDistance = controller.calculateTotalDistance();

                    for(int i = 1; i < totalDistance; i++) {
                      Widget widget = Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.black,
                              width: 1,
                            )
                        ),
                        child: Center(
                          child: Text('$i', style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),),
                        ),
                      );

                      controller.screenshotController.captureFromWidget(widget, delay: const Duration(milliseconds: 100)).then((bytes) {
                        controller.images[i] = bytes;

                        pointAnnotationManager.create(PointAnnotationOptions(
                          geometry: Point(coordinates: Position(lineString.along(i.toDouble()*1000).lng, lineString.along(i.toDouble()*1000).lat)).toJson(),
                          image: i % 5 == 0 ? controller.images[i] : null,
                        )).then((pointAnnotation) {
                          controller.points[i] = pointAnnotation;
                        });
                      });
                      //}
                    }
                  });
                },
              ),
            if(controller.showElevation.value)
            Positioned(
              top: MediaQuery.of(context).size.height*0.7,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 24.0, right: 16.0, top: 24.0, bottom: 12.0),
                      child: Row(
                        children: [
                          Image.asset(AppHelper.getImage('aidstation.png'), width: 30, height: 30),
                          const SizedBox(width: 10),
                          const Text('Elevation Profile', style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          )),
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              controller.changeElevation(false);
                            },
                            icon: Icon(Icons.close),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          right: 18,
                          left: 12,
                          top: 12,
                          bottom: 12,
                        ),
                        child: (controller.trail.value?.elevationData ?? []).isEmpty ? const Center(child: NoDataFoundLayout(title: 'No Data Found', errorMessage: '',)) : LineChart(
                          mainData(),
                        ),
                      ),
                    ),
                  ],
                )
              ),
            ),
          ],
        );
      }
      ),
    );
  }
}

class AnnotationClickListener extends OnPointAnnotationClickListener {

  final Function(PointAnnotation) onAnnotationClick;
  AnnotationClickListener(this.onAnnotationClick);
  @override
  void onPointAnnotationClick(PointAnnotation annotation) {
    onAnnotationClick(annotation);
    print("onAnnotationClick, id: ${annotation.id} ${annotation.textField}");
  }
}
