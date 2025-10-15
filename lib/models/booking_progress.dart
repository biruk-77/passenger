// lib/models/booking_progress.dart
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Represents the real-time progress of an active booking.
class BookingProgress {
  final String? bookingId;
  final String status;
  final LatLng? driverLocation;
  final double? driverBearing;
  final int? etaMinutes;
  final String? driverId;
  final String? driverName;
  final Map<String, dynamic>? vehicleDetails;

  BookingProgress({
    this.bookingId,
    required this.status,
    this.driverLocation,
    this.driverBearing,
    this.etaMinutes,
    this.driverId,
    this.driverName,
    this.vehicleDetails,
  });

  /// Factory constructor to create a [BookingProgress] from a JSON map.
  factory BookingProgress.fromJson(Map<String, dynamic> json) {
    final lastKnownData = json['lastKnown'] as Map<String, dynamic>?;
    LatLng? dLoc;
    double? dBearing;

    if (lastKnownData != null) {
      if (lastKnownData['latitude'] != null &&
          lastKnownData['longitude'] != null) {
        dLoc = LatLng(lastKnownData['latitude'], lastKnownData['longitude']);
      }
      dBearing = (lastKnownData['bearing'] as num?)?.toDouble();
    }

    return BookingProgress(
      bookingId: json['bookingId']?.toString(),
      status: json['status'] ?? 'unknown',
      etaMinutes: (json['etaMinutes'] as num?)?.toInt(),
      driverLocation: dLoc,
      driverBearing: dBearing,
      driverId:
          json['driver']?['_id']?.toString() ?? json['driverId']?.toString(),
      driverName: json['driver']?['name'] as String?,
      vehicleDetails: json['vehicle'] as Map<String, dynamic>?,
    );
  }
}
