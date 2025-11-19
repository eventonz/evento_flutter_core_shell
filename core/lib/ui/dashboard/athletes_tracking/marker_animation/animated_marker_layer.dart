import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'animated_marker_layer_options.dart';

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
  _AnimatedMarkerLayerState<T> createState() => _AnimatedMarkerLayerState<T>();
}

class _AnimatedMarkerLayerState<T>
    extends AnimatedWidgetBaseState<AnimatedMarkerLayer<T>> {
  Tween<double>? _latitude;
  Tween<double>? _longitude;

  Marker get marker => widget.options.marker;
  double get latitude =>
      _latitude?.evaluate(animation) ?? marker.point.latitude;
  double get longitude =>
      _longitude?.evaluate(animation) ?? marker.point.longitude;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _latitude = visitor(_latitude, widget.options.marker.point.latitude,
            (dynamic value) => Tween<double>(begin: value as double))
    as Tween<double>?;
    _longitude = visitor(_longitude, widget.options.marker.point.longitude,
            (dynamic value) => Tween<double>(begin: value as double))
    as Tween<double>?;
  }

  @override
  void didUpdateWidget(covariant AnimatedMarkerLayer<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return marker.child;
    final mapCamera = MapCamera.of(context);

    final width = marker.width;
    final height = marker.height;

    final left = 0.5 * marker.width * ((marker.alignment ?? Alignment.center).x + 1);
    final top = 0.5 * marker.height * ((marker.alignment ?? Alignment.center)!.y + 1);
    final right = marker.width - left;
    final bottom = marker.height - top;

    // Perform projection
    final pxPoint = mapCamera.project(marker.point);

    // Cull if out of bounds
    if (!mapCamera.pixelBounds.containsPartialBounds(
      Bounds(
        Point(pxPoint.x + left, pxPoint.y - bottom),
        Point(pxPoint.x - right, pxPoint.y + top),
      ),
    )) {
      return const SizedBox();
    }

    final pos = pxPoint - mapCamera.pixelOrigin.toDoublePoint();

    final markerWidget = (marker.rotate ?? widget.options.rotate ?? false)
        ? Transform.rotate(
      angle: -mapCamera.rotationRad,
      alignment: (marker.alignment ?? Alignment.center) * -1,
      child: marker.child,
    ) : marker.child;

    return Positioned(
      key: marker.key,
      width: marker.width,
      height: marker.height,
      left: pos.x - right,
      top: pos.y - bottom,
      child: markerWidget,
    );
  }
}