import 'package:evento_core/core/models/athlete_track_detail.dart';
import 'package:evento_core/ui/dashboard/athletes_tracking/marker_animation/animated_marker_layer_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:geodart/geometries.dart';
import 'package:latlong2/latlong.dart';

class AnimatedMarkerLayer<T> extends ImplicitlyAnimatedWidget {
  final AnimatedMarkerLayerOptions<T> options;
  AnimatedMarkerLayer({
    Key? key,
    required this.options,
  }) : super(
          key: key,
          duration: options.duration,
          curve: options.curve,
        );

  @override
  AnimatedWidgetBaseState createState() => _AnimatedMarkerLayerState();
}

class _AnimatedMarkerLayerState
    extends AnimatedWidgetBaseState<AnimatedMarkerLayer>
    with AutomaticKeepAliveClientMixin {
  Tween<double>? _latitude;
  Tween<double>? _longitude;

  int currentPointIndex = 0;
  List<AthleteTrackDetail> trackDetails = [];
  bool isAnimating = false;
  List<LatLng> get routePath => widget.options.routePath;
  LineString get lineStringPath => createlLineString();

  Marker get marker => widget.options.marker;

  late double currentLatitude = marker.point.latitude;
  late double currentLongitude = marker.point.latitude;

  double get latitude => _latitude?.evaluate(animation) ?? currentLatitude;
  double get longitude => _longitude?.evaluate(animation) ?? currentLatitude;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _latitude = visitor(_latitude, currentLatitude,
            (dynamic value) => Tween<double>(begin: value as double))
        as Tween<double>?;
    _longitude = visitor(_longitude, currentLongitude,
            (dynamic value) => Tween<double>(begin: value as double))
        as Tween<double>?;
  }

  @override
  void didUpdateWidget(covariant AnimatedMarkerLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (trackDetails.isEmpty ||
        trackDetails.last.location != oldWidget.options.trackDetail.location) {
      trackDetails.add(oldWidget.options.trackDetail);
    }
    if (mounted) {
      setState(() {});
      checkOnMarkerMovement();
    }
  }

  LineString createlLineString() {
    return LineString(routePath
        .map((point) => Coordinate(point.latitude, point.longitude))
        .toList());
  }

  void checkOnMarkerMovement() {
    if (isAnimating) return;
    final currentTrackDetail = trackDetails[currentPointIndex];
    final nextTrackDetail = (currentPointIndex < trackDetails.length - 1)
        ? trackDetails[currentPointIndex + 1]
        : null;
    moveMarker(
      currentTrackDetail.speed ?? 0,
      currentTrackDetail.location ?? 0,
      nextTrackDetail?.location ?? 0,
    );
  }

  void moveMarker(double speed, double progress, double newProgress) async {
    double totalPathDistance = lineStringPath.length;
    double distanceTraveledinOneSec = (speed * 1600) / 3600;

    double locationAsDistance = (progress / 100) * totalPathDistance;
    double newlocationAsDistance = (newProgress / 100) * totalPathDistance;
    isAnimating = true;
    if (progress > newProgress) {
      while (locationAsDistance >= newlocationAsDistance) {
        locationAsDistance -= distanceTraveledinOneSec;
        Point updatedlatlng = lineStringPath.along(locationAsDistance);
        if (mounted) {
          setState(() {
            currentLatitude = updatedlatlng.lat;
            currentLongitude = updatedlatlng.lng;
          });
          didUpdateWidget(widget);
        }
        await Future.delayed(const Duration(milliseconds: 1200));
      }
    } else {
      while (locationAsDistance <= newlocationAsDistance) {
        locationAsDistance += distanceTraveledinOneSec;
        Point updatedlatlng = lineStringPath.along(locationAsDistance);
        if (mounted) {
          setState(() {
            currentLatitude = updatedlatlng.lat;
            currentLongitude = updatedlatlng.lng;
          });
          didUpdateWidget(widget);
        }
        await Future.delayed(const Duration(milliseconds: 1200));
      }
    }

    isAnimating = false;
    currentPointIndex++;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final map = FlutterMapState.maybeOf(context)!;
    final pxPoint = map.project(LatLng(latitude, longitude));
    final width = marker.width - marker.anchor.left;
    final height = marker.height - marker.anchor.top;
    var sw = CustomPoint(pxPoint.x + width, pxPoint.y - height);
    var ne = CustomPoint(pxPoint.x - width, pxPoint.y + height);
    if (!map.pixelBounds.containsPartialBounds(Bounds(sw, ne))) {
      return const SizedBox();
    }
    final pos = pxPoint - map.pixelOrigin;
    final markerWidget = (marker.rotate ?? widget.options.rotate ?? false)
        // Counter rotated marker to the map rotation
        ? Transform.rotate(
            angle: -map.rotationRad,
            origin: marker.rotateOrigin ?? widget.options.rotateOrigin,
            alignment: marker.rotateAlignment ?? widget.options.rotateAlignment,
            child: marker.builder(context),
          )
        : marker.builder(context);
    return Positioned(
      key: marker.key,
      width: marker.width,
      height: marker.height,
      left: pos.x - width,
      top: pos.y - height,
      child: markerWidget,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
