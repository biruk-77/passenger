import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteDetails {
  final List<LatLng> points;
  final String distanceText;
  final String durationText;
  final int distanceValue; // in meters
  final int durationValue; // in seconds
  final LatLngBounds bounds;

  RouteDetails({
    required this.points,
    required this.distanceText,
    required this.durationText,
    required this.distanceValue,
    required this.durationValue,
    required this.bounds,
  });
}
