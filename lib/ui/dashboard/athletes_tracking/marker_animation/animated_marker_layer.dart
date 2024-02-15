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
    final mapState = MapCamera.of(context);
    final pxPoint = mapState.project(LatLng(latitude, longitude));
    final width = marker.width - /*(marker).anchor.left*/0;
    final height = marker.height - /*marker.anchor.top*/0;
    var sw = CustomPoint(pxPoint.x + width, pxPoint.y - height);
    var ne = CustomPoint(pxPoint.x - width, pxPoint.y + height);
    if (!mapState.pixelBounds.containsPartialBounds(Bounds(sw, ne))) {
      return const SizedBox();
    }
    final pos = pxPoint - mapState.pixelOrigin.toDoublePoint();
    final markerWidget = (marker.rotate ?? widget.options.rotate ?? false)
        ? Transform.rotate(
      angle: -mapState.rotationRad,
      alignment:
      marker.alignment ?? widget.options.rotateAlignment,
      child: marker.child,
    )
        : marker.child;
    return Positioned(
      key: marker.key,
      width: marker.width,
      height: marker.height,
      left: pos.x - width,
      top: pos.y - height,
      child: markerWidget,
    );
  }
}