import 'dart:math';

import 'package:evento_core/ui/dashboard/athletes_tracking/marker_animation/animated_marker_layer_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
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
  double get _currentLocation => widget.options.location;
  List<LatLng> get routePath => widget.options.routePath;
  double latitude = 0;
  double longitude = 0;

  double _lastLocation = 0;

  Marker get marker => widget.options.marker;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {}

  void _animateMarker() async {
    int li = getIndexFromLocation(_lastLocation);
    int ci = getIndexFromLocation(_currentLocation);
    if (li >= ci) {
      ci = li;
      li = getIndexFromLocation(_currentLocation);
    }
    final minPath = routePath.getRange(li, ci).toList();
    final animationDuration = Duration(seconds: 2);
    for (int i = 0; i < minPath.length; i++) {
      final start = minPath[i];
      final end = minPath[min(i + 1, minPath.length - 1)];

      final animationStart = DateTime.now();

      final stepDuration = animationDuration ~/ minPath.length;

      while (DateTime.now().difference(animationStart) < stepDuration) {
        final progress =
            DateTime.now().difference(animationStart).inMilliseconds /
                stepDuration.inMilliseconds;
        setState(() {
          latitude =
              start.latitude + (end.latitude - start.latitude) * progress;
          longitude =
              start.longitude + (end.longitude - start.longitude) * progress;
        });
        await Future.delayed(Duration(milliseconds: 30));
      }
    }
  }

  int getIndexFromLocation(double location) {
    final res = (routePath.length * (location / 100)).floor();
    return res;
  }

  @override
  void didUpdateWidget(covariant AnimatedMarkerLayer oldWidget) {
    _lastLocation = oldWidget.options.location;
    super.didUpdateWidget(oldWidget);
    _animateMarker();
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
