// lib/models/nearby_driver.dart
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'driver_types.dart'; // Import the enum

/// Represents a driver that is nearby to the passenger or assigned to a trip.
/// This model is designed to be flexible, handling data from different API endpoints.
class NearbyDriver {
  final String id;
  final String name;
  final LatLng position;
  final double? bearing; // Direction in degrees (0-360)
  final String? vehicleType; // e.g., 'mini', 'sedan', 'van'
  final bool available;
  final String? photoUrl;
  final double? rating;
  final String? phone;
  final Map<String, dynamic>? vehicle;
  final String? email;
  final double? speedKmh; // Fixed: changed from speedkmh to speedKmh
  final DriverState? state; // Added state field

  NearbyDriver({
    required this.id,
    required this.name,
    required this.position,
    this.bearing,
    this.vehicleType,
    this.available = true,
    this.photoUrl,
    this.rating,
    this.phone,
    this.vehicle,
    this.email,
    this.speedKmh, // Fixed: changed from speedkmh to speedKmh
    this.state, // Added to constructor
  });

  /// Factory constructor to create a [NearbyDriver] from a JSON map.
  factory NearbyDriver.fromJson(Map<String, dynamic> json) {
    final String driverId = (json['driverId'] ?? json['_id'])?.toString() ?? '';

    LatLng parsedPosition = const LatLng(0, 0);
    double? parsedBearing;

    if (json.containsKey('lastKnownLocation') &&
        json['lastKnownLocation'] is Map) {
      final locationData = json['lastKnownLocation'] as Map<String, dynamic>;
      final lat = locationData['latitude'] as num?;
      final lon = locationData['longitude'] as num?;
      if (lat != null && lon != null) {
        parsedPosition = LatLng(lat.toDouble(), lon.toDouble());
      }
      parsedBearing = (locationData['bearing'] as num?)?.toDouble();
    } else if (json.containsKey('latitude') && json.containsKey('longitude')) {
      final lat = json['latitude'] as num?;
      final lon = json['longitude'] as num?;
      if (lat != null && lon != null) {
        parsedPosition = LatLng(lat.toDouble(), lon.toDouble());
      }
    }

    if (parsedBearing == null && json.containsKey('bearing')) {
      parsedBearing = (json['bearing'] as num?)?.toDouble();
    }

    if (parsedPosition.latitude == 0.0 && parsedPosition.longitude == 0.0) {
      if (kDebugMode) {
        debugPrint(
          "Warning: Could not parse location for driver ID $driverId. Defaulting to (0,0).",
        );
      }
    }

    return NearbyDriver(
      id: driverId,
      name: json['name']?.toString() ?? 'Driver #$driverId',
      position: parsedPosition,
      bearing: parsedBearing,
      vehicleType: json['vehicleType']?.toString(),
      available: json['available'] as bool? ?? true,
      photoUrl: json['photoUrl']?.toString(),
      rating: (json['rating'] as num?)?.toDouble(),
      phone: json['phone']?.toString(),
      vehicle: json['vehicle'] as Map<String, dynamic>?,
      email: json['email']?.toString(),
      speedKmh: (json['speedKmh'] as num?)?.toDouble(), // Parse speed from JSON
      state: json['state'] != null
          ? _parseDriverState(json['state'])
          : null, // Parse state from JSON
    );
  }

  // Helper method to parse DriverState from string
  static DriverState? _parseDriverState(dynamic stateValue) {
    if (stateValue is String) {
      try {
        return DriverState.values.firstWhere(
          (e) => e.toString().split('.').last == stateValue,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lastKnownLocation': {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'bearing': bearing,
      },
      'vehicleType': vehicleType,
      'available': available,
      'photoUrl': photoUrl,
      'rating': rating,
      'phone': phone,
      'vehicle': vehicle,
      'email': email,
      'speedKmh': speedKmh, // Include speed in JSON
      'state': state?.toString().split('.').last, // Include state in JSON
    };
  }
}
