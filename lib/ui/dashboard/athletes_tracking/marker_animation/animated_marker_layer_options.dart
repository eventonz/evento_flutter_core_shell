import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AnimatedMarkerLayerOptions<T> {
  final Duration duration;
  final Curve curve;
  final Marker marker;
  final List<LatLng> routePath;
  final double location;
  final bool? rotate;
  final Offset? rotateOrigin;
  final AlignmentGeometry? rotateAlignment;
  final Stream<T>? stream;
  AnimatedMarkerLayerOptions({
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.linear,
    required this.marker,
    required this.routePath,
    required this.location,
    this.rotate,
    this.rotateOrigin,
    this.rotateAlignment,
    this.stream,
  });
}
