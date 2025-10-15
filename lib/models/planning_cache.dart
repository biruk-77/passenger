// lib/models/planning_cache.dart
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pasenger/models/pricing_rule.dart';

class PlanningCacheItem {
  final List<LatLng> polylinePoints;
  // --- CHANGE THESE ---
  final double distanceInKm;
  final int durationInMinutes;
  // ------------------
  final Map<String, FareEstimate> fareEstimates;

  PlanningCacheItem({
    required this.polylinePoints,
    required this.distanceInKm, // Updated
    required this.durationInMinutes, // Updated
    required this.fareEstimates,
  });
}
