import 'dart:convert';

import 'package:evento_core/core/utils/helpers.dart';
import 'package:evento_core/ui/common_components/text.dart';
import 'package:evento_core/ui/eventomap/eventomap_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geojson/geojson.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../core/res/app_colors.dart';
import '../dashboard/athletes_tracking/map_view.dart';

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
                  child: Icon(Icons.arrow_back_ios, color: Theme.of(context).colorScheme.primary, size: 24,),
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
                    child: Icon(Icons.menu, color: Theme.of(context).colorScheme.primary, size: 24,),
                  ))),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      endDrawer: Drawer(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 24.0, right: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                      child: GestureDetector(
                        onTap: () {
                          _scaffoldKey.currentState?.closeEndDrawer();
                        },
                        child: Container(
                            height: 38,
                            width: 38,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Center(child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Icon(Icons.close, color: Theme.of(context).colorScheme.primary, size: 24,),
                            ))),
                      ),
                    ),
                  ],
                ),
                Text('Map Style', style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),),
                const SizedBox(height: 8),
                SizedBox(
                    height: 100,
                    child: ListView.builder(itemBuilder: (_, index) {
                      return Obx(
                        () => GestureDetector(
                          onTap: () {
                            controller.changeStyle(index);
                          },
                          child: Column(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: controller.mapStyle.value == controller.mapStyles[index] ? Border.all(
                                    color: Colors.green,
                                    width: 3,
                                  ) : null,
                                ),
                              ),
                              const SizedBox(height: 8),

                              Text(controller.getStyleName(controller.mapStyles[index])),
                            ],
                          ),
                        ),
                      );
                    }, scrollDirection: Axis.horizontal, shrinkWrap: true, itemCount: controller.mapStyles.length),
                ),
                const SizedBox(height: 20),
                Obx(
                  () => SwitchListTile(
                    contentPadding: EdgeInsets.only(right: 16.0),
                    title: const Text('Elevation Profile', style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),),
                    value: controller.showElevation.value,
                    onChanged: (bool value) {
                      controller.changeElevation(value);
                    },
                    activeColor: Colors.blue,
                  ),
                ),
                Obx(
                      () => SwitchListTile(
                    contentPadding: EdgeInsets.only(right: 16.0),
                    title: const Text('Distance Markers', style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),),
                    value: controller.showDistanceMarkers.value,
                    onChanged: (bool value) {
                      controller.changeDistanceMarkers(value);
                    },
                    activeColor: Colors.blue,
                  ),
                ),
                const SizedBox(height: 20),
                Obx(
                      () {

                        List<GeoJsonFeature<dynamic>> points = [];

                        List<String> types = [];

                        final list = controller.geoJson.features.where((element) => element.type == GeoJsonFeatureType.point);

                        list.forEach((element) {
                          if(!types.contains(element.properties?['type'])) {
                            types.add(element.properties?['type']);
                            points.add(element);
                          }
                        });
                        final selectedInterests = controller.selectedInterests.value;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text('Points of Interest', style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            )),
                            const SizedBox(height: 10),
                            Wrap(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if(controller.selectedInterests.value.contains('')) {
                                      controller.updateSelectedInterests([]);
                                    } else {
                                      controller.updateSelectedInterests(['']);
                                    }
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 16),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: selectedInterests.contains('') ? Colors.grey.shade300 : null,
                                      border: Border.all(
                                        color: Colors.black,
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: const Text('All'),
                                  ),
                                ),
                                ...points.map((e) => GestureDetector(
                                  onTap: () {
                                    if(controller.selectedInterests.value.contains('')) {
                                      controller.updateSelectedInterests([]);
                                    }
                                    if(controller.selectedInterests.value.contains(e.properties?['type'])) {
                                      controller.updateSelectedInterests(
                                        List.from(controller.selectedInterests.value)..remove(e.properties?['type']),
                                      );
                                    } else {
                                      controller.updateSelectedInterests([
                                        e.properties?['type'],
                                        ...controller.selectedInterests.value
                                      ]);
                                    }

                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 16, bottom: 12),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: selectedInterests.contains(e.properties?['type']) ? Colors.grey.shade300 : null,
                                      border: Border.all(
                                        color: Colors.black,
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text('${controller.iopTypesMap[e.properties?['type']]}'),
                                  ),
                                )),
                              ],
                            ),
                          ],
                        );
                      }
                ),
              ],
            ),
          ),
        ),
      ),

      body: Obx(() {

      List<LatLng> bounds = [];

      if (controller.loading.value == false) {
        controller.routePathsCordinates.forEach((element) {
          bounds.add(LatLng(element.lat.toDouble(), element.lng.toDouble()));
        });
      }

        return controller.loading.value ? Center(
          child: CircularProgressIndicator(),
        ) : Stack(
          children: [
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
                print(state?.zoom);
                if((state?.zoom ?? 0) >= 14) {
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
                  for(int i = 1; i < controller.totalDistance-1; i++) {
                    final annotation = controller.points[i];
                    if(annotation != null) {
                      if(!controller.showDistanceMarkers.value) {
                        annotation.image = null;

                      } else if((state?.zoom ?? 0) >= 14) {
                        annotation.image = controller.images[i];
                      } else {
                        annotation.image = i % 5 == 0 ? controller.images[i] : null;
                      }
                      controller.pointAnnotationManager?.update(annotation);
                    }
                  }
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
                                    AppHelper.showDirectionsOnMap(LatLng((point.geometry as GeoJsonPoint).geoPoint.latitude, (point.geometry as GeoJsonPoint).geoPoint.longitude));
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

                      for(int i = 1; i < totalDistance-1; i++) {
                        Widget widget = Container(
                          width: 26,
                          height: 26,
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
              top: MediaQuery.of(context).size.height*0.75,
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
                      padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0, bottom: 12.0),
                      child: Row(
                        children: [
                          Image.asset(AppHelper.getImage('aidstation.png'), width: 30, height: 30),
                          const SizedBox(width: 10),
                          Text('Elevation Profile', style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          )),
                        ],
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
