// lib/models/route.dart
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Model for the custom response from the `/v1/mapping/route` endpoint.
class BackendRouteResponse {
  final double distanceKm;
  final int durationMinutes;
  final List<LatLng> decodedPolylinePoints;
  // Let's add a "status" for consistency, even if API doesn't send it, to avoid breaking the UI check
  final String status;

  // Added getters to mimic the old structure for minimal UI changes
  List<RoutePath> get routes => [
    RoutePath(
      overviewPolyline: '', // Not provided by new API
      firstLeg: RouteLeg(
        distanceText: '${distanceKm.toStringAsFixed(1)} km',
        durationText: '$durationMinutes min',
        distanceValue: (distanceKm * 1000).toInt(),
        durationValue: durationMinutes * 60,
      ),
      // Pass the decoded points directly
      decodedPolylinePoints: decodedPolylinePoints,
    ),
  ];

  BackendRouteResponse({
    required this.distanceKm,
    required this.durationMinutes,
    required this.decodedPolylinePoints,
    this.status = "OK", // Default to "OK" if parsing is successful
  });

  /// Factory constructor to create a [BackendRouteResponse] from the custom JSON map.
  factory BackendRouteResponse.fromJson(Map<String, dynamic> json) {
    // Safely parse the coordinates list
    final List<dynamic> coordinates = json['geometry']?['coordinates'] ?? [];
    final List<LatLng> points = coordinates.map((coord) {
      // The format is [longitude, latitude]
      if (coord is List && coord.length == 2) {
        return LatLng(coord[1] as double, coord[0] as double);
      }
      return const LatLng(0, 0); // Fallback for bad data
    }).toList();

    return BackendRouteResponse(
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0.0,
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 0,
      decodedPolylinePoints: points,
    );
  }
}

/// Represents a single route path. This is now simplified to work with the custom API.
class RoutePath {
  final String overviewPolyline;
  final RouteLeg? firstLeg;
  final List<LatLng> decodedPolylinePoints; // Store points directly

  RoutePath({
    required this.overviewPolyline,
    this.firstLeg,
    this.decodedPolylinePoints = const [],
  });
}

/// Represents a single leg of a route (e.g., from origin to destination).
/// This model remains the same as it's used internally by the new `BackendRouteResponse`.
class RouteLeg {
  final String distanceText;
  final int distanceValue; // in meters
  final String durationText;
  final int durationValue; // in seconds

  RouteLeg({
    required this.distanceText,
    required this.distanceValue,
    required this.durationText,
    required this.durationValue,
  });
}

// NOTE: You can probably remove the classes below if they are not used elsewhere.
// I am leaving them for now to avoid breaking other parts of your app.

/// Represents a geographical point used in route/ETA requests.
class RouteRequestLocation {
  final LatLng coordinates;
  RouteRequestLocation({required this.coordinates});
  Map<String, dynamic> toJson() {
    return {
      'latitude': coordinates.latitude,
      'longitude': coordinates.longitude,
    };
  }
}

/// Model for the response from `/v1/mapping/eta` endpoint.
class EtaResponse {
  final int etaSeconds;
  final String etaText;
  EtaResponse({required this.etaSeconds, required this.etaText});
  factory EtaResponse.fromJson(Map<String, dynamic> json) {
    return EtaResponse(
      etaSeconds: json['eta'] as int,
      etaText: json['etaText'] as String,
    );
  }
}
