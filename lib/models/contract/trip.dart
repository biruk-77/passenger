// FILE: lib/models/contract/trip.dart
// ✅ UPGRADED AND ROBUST VERSION

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Trip {
  final String id;
  final String subscriptionId;
  final String passengerId;
  final String? driverId;
  final String passengerName; // ✅ ADDED THIS FIELD
  final String? pickupLocation;
  final String? dropoffLocation;
  final LatLng? pickupCoordinates;
  final LatLng? dropoffCoordinates;
  final DateTime? actualPickupTime; // ✅ RENAMED
  final DateTime? actualDropoffTime; // ✅ RENAMED
  final String status;
  final double? fareAmount;
  final String? notes;
  final int? rating;
  final DateTime createdAt;
  final DateTime updatedAt;

  Trip({
    required this.id,
    required this.subscriptionId,
    required this.passengerId,
    required this.passengerName, // ✅ ADDED TO CONSTRUCTOR
    this.driverId,
    this.pickupLocation,
    this.dropoffLocation,
    this.pickupCoordinates,
    this.dropoffCoordinates,
    this.actualPickupTime, // ✅ RENAMED
    this.actualDropoffTime, // ✅ RENAMED
    required this.status,
    this.fareAmount,
    this.notes,
    this.rating,
    required this.createdAt,
    required this.updatedAt,
  });

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  factory Trip.fromJson(Map<String, dynamic> json) {
    final double? pickupLat = _parseDouble(json['pickup_latitude']);
    final double? pickupLng = _parseDouble(json['pickup_longitude']);
    final double? dropoffLat = _parseDouble(json['dropoff_latitude']);
    final double? dropoffLng = _parseDouble(json['dropoff_longitude']);

    return Trip(
      // Provide a fallback for required fields to prevent crashes
      id: json['id'] as String? ?? 'UNKNOWN_ID',
      subscriptionId: json['subscription_id'] as String? ?? 'UNKNOWN_SUB_ID',
      passengerId: json['passenger_id'] as String? ?? 'UNKNOWN_PASS_ID',
      driverId: json['driver_id'] as String?,
      status: json['status'] as String? ?? 'UNKNOWN',

      // ✅ ADDED passenger_name with a fallback
      passengerName: json['passenger_name'] as String? ?? 'Unknown Passenger',

      pickupLocation: json['pickup_location'] as String?,
      dropoffLocation: json['dropoff_location'] as String?,

      pickupCoordinates: (pickupLat != null && pickupLng != null)
          ? LatLng(pickupLat, pickupLng)
          : null,
      dropoffCoordinates: (dropoffLat != null && dropoffLng != null)
          ? LatLng(dropoffLat, dropoffLng)
          : null,

      // ✅ CORRECTED date field names
      actualPickupTime: _parseDate(json['actual_pickup_time']),
      actualDropoffTime: _parseDate(json['actual_dropoff_time']),

      fareAmount: _parseDouble(json['fare_amount']),
      notes: json['notes'] as String?,
      rating: _parseInt(json['rating']),

      createdAt:
          _parseDate(json['createdAt'] ?? json['created_at']) ?? DateTime.now(),
      updatedAt:
          _parseDate(json['updatedAt'] ?? json['updated_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subscription_id': subscriptionId,
      'passenger_id': passengerId,
      'driver_id': driverId,
      'passenger_name': passengerName, // ✅ ADDED TO JSON
      'pickup_location': pickupLocation,
      'dropoff_location': dropoffLocation,
      'pickup_latitude': pickupCoordinates?.latitude,
      'pickup_longitude': pickupCoordinates?.longitude,
      'dropoff_latitude': dropoffCoordinates?.latitude,
      'dropoff_longitude': dropoffCoordinates?.longitude,
      'actual_pickup_time': actualPickupTime?.toIso8601String(), // ✅ RENAMED
      'actual_dropoff_time': actualDropoffTime?.toIso8601String(), // ✅ RENAMED
      'status': status,
      'fare_amount': fareAmount,
      'notes': notes,
      'rating': rating,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
