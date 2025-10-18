// ========================================================================
// lib/models/location.dart
// NOTE: Consolidated and corrected models are placed here.
// ========================================================================

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Represents a geographical point with optional address details.
/// Used for pickup, dropoff, and general location data.
class LocationPoint {
  final LatLng coordinates;
  final String? address; // e.g., "123 Main St, City"
  final String? name; // e.g., "Home", "Office", "Starbucks"

  LocationPoint({required this.coordinates, this.address, this.name});

  /// Factory constructor to create a [LocationPoint] from a JSON map.
  /// Handles various formats and malformed data with extreme resilience.
  factory LocationPoint.fromJson(Map<String, dynamic> json) {
    double? lat;
    double? lon;

    // Helper to safely parse a double from any numeric type
    double? _parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    // Attempt 1: Parse GeoJSON format [longitude, latitude]
    if (json['coordinates'] is List && json['coordinates'].length == 2) {
      final List<dynamic> coords = json['coordinates'];
      // GeoJSON is [long, lat]
      lon = _parseDouble(coords[0]);
      lat = _parseDouble(coords[1]);
    }
    // Attempt 2: Fallback to direct latitude/longitude fields
    else {
      lat = _parseDouble(json['latitude']);
      lon = _parseDouble(json['longitude']);
    }

    // Final validation: If parsing failed, default to origin and log a warning.
    if (lat == null || lon == null) {
      if (kDebugMode) {
        debugPrint(
          "⚠️ WARNING: Malformed or missing coordinates in LocationPoint JSON. Defaulting to (0,0). JSON: $json",
        );
      }
      return LocationPoint.empty(); // Use our new safe default
    }

    return LocationPoint(
      coordinates: LatLng(lat, lon),
      address: json['address'] as String?,
      name: json['name'] as String?,
    );
  }

  /// A factory for creating a safe, default "empty" LocationPoint.
  /// This is used as a fallback when API data is missing, preventing null crashes.
  factory LocationPoint.empty() {
    return LocationPoint(
      coordinates: const LatLng(0, 0),
      address: 'Unknown Location',
      name: 'Unknown',
    );
  }

  /// Converts this [LocationPoint] object to a JSON map suitable for API requests.
  Map<String, dynamic> toJson() {
    return {
      'latitude': coordinates.latitude,
      'longitude': coordinates.longitude,
      if (address != null) 'address': address,
      if (name != null) 'name': name,
    };
  }

  /// Converts coordinates to the backend's GeoJSON format `{'coordinates': [longitude, latitude]}`.
  Map<String, dynamic> toGeoJsonPayload() {
    return {
      'type': 'Point',
      'coordinates': [coordinates.longitude, coordinates.latitude],
    };
  }
}

/// Represents a detailed address with structured components.
/// This is the single source of truth for address information in the app.
class PlaceAddress {
  final String name;
  final String? street;
  final String? city;
  final String fullAddress;
  final LatLng coordinates;
  final String? placeType;

  PlaceAddress({
    required this.name,
    this.street,
    this.city,
    required this.fullAddress,
    required this.coordinates,
    this.placeType,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'street': street,
    'city': city,
    'fullAddress': fullAddress,
    'latitude': coordinates.latitude,
    'longitude': coordinates.longitude,
    'placeType': placeType,
  };

  factory PlaceAddress.fromJson(Map<String, dynamic> json) => PlaceAddress(
    name: json['name'] ?? json['fullAddress'] ?? 'Unknown',
    street: json['street'],
    city: json['city'],
    fullAddress: json['fullAddress'] ?? 'Unknown Address',
    coordinates: LatLng(json['latitude'] ?? 0.0, json['longitude'] ?? 0.0),
    placeType: json['placeType'],
  );
}
