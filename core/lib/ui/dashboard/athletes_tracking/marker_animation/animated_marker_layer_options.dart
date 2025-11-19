import 'package:evento_core/core/models/athlete_track_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AnimatedMarkerLayerOptions<T> {
  final Duration duration;
  final Curve curve;
  final Marker marker;
  final bool? rotate;
  final Offset? rotateOrigin;
  final AlignmentGeometry? rotateAlignment;
  final List<LatLng> routePath;
  final AthleteTrackDetail trackDetail;
  AnimatedMarkerLayerOptions(
      {this.duration = const Duration(milliseconds: 300),
      this.curve = Curves.linear,
      required this.marker,
      this.rotate,
      this.rotateOrigin,
      this.rotateAlignment,
      required this.routePath,
      required this.trackDetail});
}
