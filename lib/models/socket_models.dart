// lib/models/socket_models.dart

import 'package:google_maps_flutter/google_maps_flutter.dart';

// =========================================================================
// 🔔 EVENT MODEL 1: BOOKING STATUS UPDATE
// =========================================================================

class BookingStatusUpdate {
  final String bookingId;
  final String status;
  final String? driverId;
  final Map<String, dynamic>? vehicle;

  // ✅ --- FIX: ADDED THESE NEW, NULLABLE FIELDS ---
  // These will be populated with data when the trip is completed.
  final double? fareFinal;
  final double? distanceTraveled;

  BookingStatusUpdate({
    required this.bookingId,
    required this.status,
    this.driverId,
    this.vehicle,
    // ✅ Added to the constructor
    this.fareFinal,
    this.distanceTraveled,
  });

  // ✅ --- THIS FACTORY IS NOW CORRECTED TO PARSE THE NEW FIELDS ---
  factory BookingStatusUpdate.fromJson(Map<String, dynamic> json) {
    // This logic handles data whether it's at the top level or nested in a 'patch' object
    final data = json.containsKey('patch')
        ? json['patch'] as Map<String, dynamic>
        : json;

    return BookingStatusUpdate(
      // The server sometimes sends 'id' instead of 'bookingId'
      bookingId: (json['id'] ?? data['bookingId']) as String? ?? '',
      status: data['status'] as String? ?? 'unknown',
      driverId: data['driverId'] as String?,

      // ✅ Safely parse the new numeric fields. They can be null.
      fareFinal: (data['fareFinal'] as num?)?.toDouble(),
      distanceTraveled: (data['distanceTraveled'] as num?)?.toDouble(),

      // This logic for vehicle remains the same
      vehicle: data.containsKey('vehicle') && data['vehicle'] is Map
          ? data['vehicle'] as Map<String, dynamic>
          : null,
    );
  }
}

class DriverLocationUpdate {
  final String driverId;
  final String? bookingId;
  final LatLng position;
  final double bearing;
  final DateTime timestamp;

  DriverLocationUpdate({
    required this.driverId,
    this.bookingId,
    required this.position,
    required this.bearing,
    required this.timestamp,
  });

  factory DriverLocationUpdate.fromJson(Map<String, dynamic> json) {
    // --- ✅ FIX: Handle multiple possible JSON structures for location data ---

    // 1. Prioritize the new nested 'location' object from your Postman example.
    final locationData = json['location'] as Map<String, dynamic>?;

    // 2. Fallback to the older 'lastKnownLocation' object.
    final lastKnownLocationData =
        json['lastKnownLocation'] as Map<String, dynamic>?;

    // 3. Extract values by checking each source in order of priority.
    //    This uses the null-aware operator '??' for a clean fallback chain.
    double? lat =
        (locationData?['latitude'] as num?)?.toDouble() ??
        (lastKnownLocationData?['latitude'] as num?)?.toDouble() ??
        (json['latitude'] as num?)?.toDouble();

    double? lon =
        (locationData?['longitude'] as num?)?.toDouble() ??
        (lastKnownLocationData?['longitude'] as num?)?.toDouble() ??
        (json['longitude'] as num?)?.toDouble();

    double? bearing =
        (locationData?['bearing'] as num?)?.toDouble() ??
        (lastKnownLocationData?['bearing'] as num?)?.toDouble() ??
        (json['bearing'] as num?)?.toDouble();

    // 4. Handle timestamp with similar fallback logic.
    final String? timestampString =
        (locationData?['recordedAt'] as String?) ??
        (json['updatedAt'] as String?) ??
        (json['timestamp'] as String?);

    // 5. Build the final object, defaulting to safe values if everything is null.
    return DriverLocationUpdate(
      driverId:
          json['driverId'] as String? ??
          json['id'] as String? ??
          '', // Also check 'id'
      bookingId: json['bookingId'] as String?,
      position: LatLng(lat ?? 0.0, lon ?? 0.0), // Ensure non-null LatLng
      bearing: bearing ?? 0.0,
      timestamp: DateTime.tryParse(timestampString ?? '') ?? DateTime.now(),
    );
  }
}

// --- REPLACE your old EtaUpdate class with this new, correct version ---
class EtaUpdate {
  final String bookingId;
  final int etaSeconds;
  final String etaText; // ✅ The field we need for the UI
  final LatLng driverLocation;
  final LatLng destination;

  EtaUpdate({
    required this.bookingId,
    required this.etaSeconds,
    required this.etaText,
    required this.driverLocation,
    required this.destination,
  });

  factory EtaUpdate.fromJson(Map<String, dynamic> json) {
    // This factory now correctly parses the data from your log
    return EtaUpdate(
      bookingId: json['bookingId'] as String? ?? '',
      etaSeconds: (json['etaSeconds'] as num?)?.toInt() ?? 0,
      etaText:
          json['etaText'] as String? ?? '...', // Use the text from the backend
      driverLocation: LatLng(
        (json['driverLocation']?['latitude'] as num?)?.toDouble() ?? 0.0,
        (json['driverLocation']?['longitude'] as num?)?.toDouble() ?? 0.0,
      ),
      destination: LatLng(
        (json['destination']?['latitude'] as num?)?.toDouble() ?? 0.0,
        (json['destination']?['longitude'] as num?)?.toDouble() ?? 0.0,
      ),
    );
  }
}

// =========================================================================
// ✅ NEW MODEL 4: BOOKING RATING UPDATE
// Listens for 'booking:rating' from the server
// =========================================================================
class BookingRatingUpdate {
  final String bookingId;
  final String userType; // "passenger" or "driver"
  final int rating;
  final String? feedback;

  BookingRatingUpdate({
    required this.bookingId,
    required this.userType,
    required this.rating,
    this.feedback,
  });

  factory BookingRatingUpdate.fromJson(Map<String, dynamic> json) {
    return BookingRatingUpdate(
      bookingId: json['bookingId'] as String? ?? '',
      userType: json['userType'] as String? ?? 'unknown',
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      feedback: json['feedback'] as String?,
    );
  }
}

class LastKnownLocation {
  final LatLng position;
  final double bearing;

  LastKnownLocation({required this.position, required this.bearing});

  factory LastKnownLocation.fromJson(Map<String, dynamic> json) {
    return LastKnownLocation(
      position: LatLng(
        (json['latitude'] as num?)?.toDouble() ?? 0.0,
        (json['longitude'] as num?)?.toDouble() ?? 0.0,
      ),
      bearing: (json['bearing'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // ✅ FIX: ADDED THE MISSING `toJson` METHOD for the nested object.
  Map<String, dynamic> toJson() {
    return {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'bearing': bearing,
    };
  }
}

// =========================================================================
// 🛡️ EVENT MODEL 3: UNAUTHORIZED NEW BOOKING BROADCAST
// =========================================================================
class NewBookingBroadcast {
  final String id;
  final String vehicleType;
  final String status;

  NewBookingBroadcast({
    required this.id,
    required this.vehicleType,
    required this.status,
  });

  factory NewBookingBroadcast.fromJson(Map<String, dynamic> json) {
    return NewBookingBroadcast(
      id: (json['id'] ?? json['_id'])?.toString() ?? 'Unknown ID',
      vehicleType:
          (json['vehicleTType'] ?? json['vehicleType'])?.toString() ??
          'unknown',
      status: json['status']?.toString() ?? 'unknown',
    );
  }
}

class TripStartedUpdate {
  final String bookingId;
  final DateTime startedAt;

  TripStartedUpdate({required this.bookingId, required this.startedAt});

  factory TripStartedUpdate.fromJson(Map<String, dynamic> json) {
    // Check for standard 'startedAt', and fallback to the likely server typo 'starteedAt'
    final String? timestampString =
        json['startedAt'] as String? ??
        json['starteedAt'] as String?; // ✅ FIX: Added fallback for typo

    return TripStartedUpdate(
      bookingId:
          json['bookingId'] as String? ??
          json['id'] as String? ??
          '', // ✅ FIX: Added fallback for missing bookingId
      startedAt:
          DateTime.tryParse(timestampString ?? '') ??
          DateTime.now(), // ✅ FIX: Safely parse date, default to now
    );
  }
}
