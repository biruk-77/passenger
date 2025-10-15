// lib/models/ride_history.dart
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPoint {
  final LatLng coordinates;
  String? address; // <-- REMOVE 'final' KEYWORD HERE

  LocationPoint({required this.coordinates, this.address});

  // ... fromJson and toJson methods remain the same ...
  factory LocationPoint.fromJson(Map<String, dynamic> json) {
    return LocationPoint(
      coordinates: LatLng(
        (json['latitude'] as num?)?.toDouble() ?? 0.0,
        (json['longitude'] as num?)?.toDouble() ?? 0.0,
      ),
      address: json['address'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'latitude': coordinates.latitude,
    'longitude': coordinates.longitude,
    'address': address,
  };
}

class RideHistoryItem {
  final String id;
  final String status;
  final DateTime createdAt;
  final LocationPoint? pickup;
  final LocationPoint? dropoff;
  final double? fare;
  final String vehicleType;
  final String? driverId;
  final String? driverName;

  RideHistoryItem({
    required this.id,
    required this.status,
    required this.createdAt,
    this.pickup,
    this.dropoff,
    this.fare,
    required this.vehicleType,
    this.driverId,
    this.driverName,
  });

  factory RideHistoryItem.fromJson(Map<String, dynamic> json) {
    // ... your existing fromJson logic is fine ...
    double? finalFare = (json['fareFinal'] as num?)?.toDouble();
    if (finalFare == null || finalFare == 0) {
      finalFare = (json['fareEstimated'] as num?)?.toDouble();
    }
    String? driverId, driverName;
    if (json['driver'] != null && json['driver'] is Map<String, dynamic>) {
      driverId = json['driver']['_id'] as String?;
      driverName = json['driver']['name'] as String?;
    } else {
      driverId = json['driverId'] as String?;
    }
    return RideHistoryItem(
      id: json['_id'] as String? ?? json['id'] as String,
      status: json['status'] as String? ?? 'unknown',
      createdAt: DateTime.parse(json['createdAt'] as String),
      pickup: json['pickup'] != null
          ? LocationPoint.fromJson(json['pickup'])
          : null,
      dropoff: json['dropoff'] != null
          ? LocationPoint.fromJson(json['dropoff'])
          : null,
      fare: finalFare,
      vehicleType: json['vehicleType'] as String? ?? 'standard',
      driverId: driverId,
      driverName: driverName ?? json['driverName'] as String?,
    );
  }

  // ADD THIS METHOD FOR CACHING
  Map<String, dynamic> toJson() => {
    '_id': id,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'pickup': pickup?.toJson(),
    'dropoff': dropoff?.toJson(),
    'fareFinal': fare,
    'vehicleType': vehicleType,
    'driverId': driverId,
    'driverName': driverName,
  };
}
