// FILE: lib/models/contract/trip_schedule_item.dart
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TripScheduleItem {
  final String id;
  final String subscriptionId;
  final String passengerId;
  final String driverId;
  final String? passengerName; // Added for convenience in schedule view
  final String? pickupLocation;
  final String? dropoffLocation;
  final LatLng? pickupCoordinates;
  final LatLng? dropoffCoordinates;
  final DateTime scheduledPickupTime;
  final DateTime? actualPickupTime;
  final String status; // e.g., 'SCHEDULED', 'STARTED', 'COMPLETED', 'CANCELLED'
  final String? notes;

  TripScheduleItem({
    required this.id,
    required this.subscriptionId,
    required this.passengerId,
    required this.driverId,
    this.passengerName,
    this.pickupLocation,
    this.dropoffLocation,
    this.pickupCoordinates,
    this.dropoffCoordinates,
    required this.scheduledPickupTime,
    this.actualPickupTime,
    required this.status,
    this.notes,
  });

  factory TripScheduleItem.fromJson(Map<String, dynamic> json) {
    return TripScheduleItem(
      id: json['id'] as String,
      subscriptionId: json['subscription_id'] as String,
      passengerId: json['passenger_id'] as String,
      driverId: json['driver_id'] as String,
      passengerName:
          json['passenger_name'] as String?, // Assuming backend provides this
      pickupLocation: json['pickup_location'] as String?,
      dropoffLocation: json['dropoff_location'] as String?,
      pickupCoordinates:
          (json['pickup_latitude'] != null && json['pickup_longitude'] != null)
          ? LatLng(
              (json['pickup_latitude'] as num).toDouble(),
              (json['pickup_longitude'] as num).toDouble(),
            )
          : null,
      dropoffCoordinates:
          (json['dropoff_latitude'] != null &&
              json['dropoff_longitude'] != null)
          ? LatLng(
              (json['dropoff_latitude'] as num).toDouble(),
              (json['dropoff_longitude'] as num).toDouble(),
            )
          : null,
      scheduledPickupTime: DateTime.parse(
        json['scheduled_pickup_time'] as String,
      ),
      actualPickupTime: json['actual_pickup_time'] != null
          ? DateTime.parse(json['actual_pickup_time'] as String)
          : null,
      status: json['status'] as String,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subscription_id': subscriptionId,
      'passenger_id': passengerId,
      'driver_id': driverId,
      'passenger_name': passengerName,
      'pickup_location': pickupLocation,
      'dropoff_location': dropoffLocation,
      'pickup_latitude': pickupCoordinates?.latitude,
      'pickup_longitude': pickupCoordinates?.longitude,
      'dropoff_latitude': dropoffCoordinates?.latitude,
      'dropoff_longitude': dropoffCoordinates?.longitude,
      'scheduled_pickup_time': scheduledPickupTime.toIso8601String(),
      'actual_pickup_time': actualPickupTime?.toIso8601String(),
      'status': status,
      'notes': notes,
    };
  }
}
