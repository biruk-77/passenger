import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'location.dart';
import 'dart:convert';
import 'contract/driver.dart';

class Booking {
  final String id;
  final String passengerId;
  final String? driverId;
  final LocationPoint pickup;
  final LocationPoint dropoff;
  final String vehicleType;
  final String status;
  final double? estimatedFare;
  final double? finalFare;
  final String paymentMethod;

  // --- ⭐ NEW & EXPANDED FIELDS TO CAPTURE EVERYTHING ---
  final String? assignedDriverName;
  final String? assignedDriverEmail; // New
  final Map<String, dynamic>? assignedVehicleDetails;
  final String? driverPhotoUrl;
  final double? driverRating;
  final String? driverPhone;
  final String? acceptedByUserType; // New: e.g., "driver"
  final DateTime? acceptedAt; // New

  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? driverEmail;
  final AssignedDriver? subscriptionInfo;

  Booking({
    required this.id,
    required this.passengerId,
    this.driverId,
    required this.pickup,
    required this.dropoff,
    required this.vehicleType,
    required this.status,
    this.estimatedFare,
    this.finalFare,
    required this.paymentMethod,
    this.assignedDriverName,
    this.assignedDriverEmail, // New
    this.assignedVehicleDetails,
    this.driverPhotoUrl,
    this.driverRating,
    this.driverPhone,
    this.acceptedByUserType, // New
    this.acceptedAt, // New
    required this.createdAt,
    this.updatedAt,
    this.driverEmail,
    this.subscriptionInfo,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    // sonde: Debugging log to see the raw JSON
    debugPrint(" sonde Parsing Booking from JSON: ${jsonEncode(json)}");

    // --- ✅ THE FIX: UNIFY THE DATA SOURCE ---
    // This logic checks if the core booking data is nested inside `meta.booking`.
    // If it is, it uses that nested map as the main source for details like
    // pickup, dropoff, etc. Otherwise, it uses the top-level json map.
    // This makes the factory compatible with BOTH the `booking:active_snapshot`
    // and `booking:update` event structures.
    final Map<String, dynamic> coreData =
        (json['meta'] is Map && json['meta']['booking'] is Map)
        ? json['meta']['booking'] as Map<String, dynamic>
        : json;

    double? _parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    DateTime? _parseDateTime(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    // Extract nested objects from the top-level json, as they are consistent
    final driverJson = json['driver'] is Map<String, dynamic>
        ? json['driver'] as Map<String, dynamic>
        : null;
    final passengerJson = json['passenger'] is Map<String, dynamic>
        ? json['passenger'] as Map<String, dynamic>
        : null;

    // Create a standardized vehicle details map
    Map<String, dynamic>? vehicleDetails;
    if (driverJson != null) {
      vehicleDetails = {
        'type': driverJson['vehicleType'],
        'model': driverJson['carName'],
        'plate': driverJson['carPlate'],
        'color': driverJson['carColor'],
      };
    }

    return Booking(
      // Prioritize top-level IDs, then fall back to coreData
      id:
          (json['bookingId'] ?? json['id'] ?? coreData['id'] ?? coreData['_id'])
              ?.toString() ??
          '',
      passengerId:
          (json['passengerId'] ?? passengerJson?['id'])?.toString() ?? '',
      driverId: (json['driverId'] ?? driverJson?['id'])?.toString(),

      // --- ✅ Use `coreData` to get location info ---
      pickup: coreData['pickup'] is Map<String, dynamic>
          ? LocationPoint.fromJson(coreData['pickup'])
          : LocationPoint.empty(),
      dropoff: coreData['dropoff'] is Map<String, dynamic>
          ? LocationPoint.fromJson(coreData['dropoff'])
          : LocationPoint.empty(),

      // Prioritize top-level status/vehicleType, then fall back to coreData
      vehicleType:
          json['vehicleType']?.toString() ??
          driverJson?['vehicleType']?.toString() ??
          coreData['vehicleType']?.toString() ??
          'unknown',
      status:
          json['status']?.toString() ??
          coreData['status']?.toString() ??
          'unknown',

      paymentMethod:
          json['paymentMethod']?.toString() ??
          coreData['paymentMethod']?.toString() ??
          'cash',

      // Prioritize top-level fare, then fall back to coreData
      estimatedFare: _parseDouble(
        json['fareEstimated'] ?? coreData['fareEstimated'],
      ),
      finalFare: _parseDouble(json['fareFinal'] ?? coreData['fareFinal']),

      // Extract details from the consistent top-level `driver` object
      assignedDriverName: driverJson?['name']?.toString(),
      assignedDriverEmail: driverJson?['email']?.toString(),
      assignedVehicleDetails: vehicleDetails,
      driverPhotoUrl: driverJson?['photoUrl']?.toString(),
      driverRating: _parseDouble(driverJson?['rating']),
      driverPhone: driverJson?['phone']?.toString(),

      // Get these from the top-level json
      acceptedAt: _parseDateTime(json['acceptedAt']),
      createdAt:
          _parseDateTime(json['createdAt'] ?? coreData['createdAt']) ??
          DateTime.now(),
      updatedAt: _parseDateTime(json['updatedAt'] ?? coreData['updatedAt']),
    );
  }
  @override
  String toString() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'passengerId': passengerId,
      'driverId': driverId,
      'pickup': pickup.toJson(),
      'dropoff': dropoff.toJson(),
      'vehicleType': vehicleType,
      'status': status,
      'estimatedFare': estimatedFare,
      'finalFare': finalFare,
      'paymentMethod': paymentMethod,
      'driver': {
        'name': assignedDriverName,
        'email': assignedDriverEmail, // New
        'photoUrl': driverPhotoUrl,
        'rating': driverRating,
        'phone': driverPhone,
        'vehicle': assignedVehicleDetails,
      },
      'acceptedByUserType': acceptedByUserType, // New
      'acceptedAt': acceptedAt?.toIso8601String(), // New
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Booking copyWith({
    String? id,
    String? passengerId,
    String? driverId,
    LocationPoint? pickup,
    LocationPoint? dropoff,
    String? vehicleType,
    String? status,
    double? estimatedFare,
    double? finalFare,
    String? paymentMethod,
    String? assignedDriverName,
    String? assignedDriverEmail, // New
    Map<String, dynamic>? assignedVehicleDetails,
    String? driverPhotoUrl,
    double? driverRating,
    String? driverPhone,
    String? acceptedByUserType, // New
    DateTime? acceptedAt, // New
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Booking(
      id: id ?? this.id,
      passengerId: passengerId ?? this.passengerId,
      driverId: driverId ?? this.driverId,
      pickup: pickup ?? this.pickup,
      dropoff: dropoff ?? this.dropoff,
      vehicleType: vehicleType ?? this.vehicleType,
      status: status ?? this.status,
      estimatedFare: estimatedFare ?? this.estimatedFare,
      finalFare: finalFare ?? this.finalFare,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      assignedDriverName: assignedDriverName ?? this.assignedDriverName,
      assignedDriverEmail: assignedDriverEmail ?? this.assignedDriverEmail,
      assignedVehicleDetails:
          assignedVehicleDetails ?? this.assignedVehicleDetails,
      driverPhotoUrl: driverPhotoUrl ?? this.driverPhotoUrl,
      driverRating: driverRating ?? this.driverRating,
      driverPhone: driverPhone ?? this.driverPhone,
      acceptedByUserType: acceptedByUserType ?? this.acceptedByUserType,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Request model for creating a new booking (`POST /v1/bookings`).
class CreateBookingRequest {
  final String vehicleType;
  final LatLng pickupCoordinates;
  final LatLng dropoffCoordinates;
  final int? durationMinutes;
  final String? paymentMethod;

  CreateBookingRequest({
    required this.vehicleType,
    required this.pickupCoordinates,
    required this.dropoffCoordinates,
    this.durationMinutes,
    this.paymentMethod,
  });

  Map<String, dynamic> toJson() {
    return {
      'vehicleType': vehicleType,
      'pickup': {
        'latitude': pickupCoordinates.latitude,
        'longitude': pickupCoordinates.longitude,
      },
      'dropoff': {
        'latitude': dropoffCoordinates.latitude,
        'longitude': dropoffCoordinates.longitude,
      },
      if (durationMinutes != null) 'durationMinutes': durationMinutes,
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
    };
  }
}

// =======================================================================
// FIX: ADD THIS CLASS BACK. It was accidentally deleted.
// =======================================================================
/// Request model for updating an existing booking (`PUT /v1/bookings/:bookingId`).
class UpdateBookingRequest {
  final LocationPoint? pickup;
  final String? notes;

  UpdateBookingRequest({this.pickup, this.notes});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (pickup != null) data['pickup'] = pickup!.toJson();
    if (notes != null) data['notes'] = notes;
    return data;
  }
}

class BookingNote {
  final String bookingId;
  final String senderId;
  final String senderType; // "passenger" or "driver"
  final String message;
  final DateTime timestamp;

  BookingNote({
    required this.bookingId,
    required this.senderId,
    required this.senderType,
    required this.message,
    required this.timestamp,
  });

  factory BookingNote.fromJson(Map<String, dynamic> json) {
    return BookingNote(
      bookingId: json['bookingId']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      senderType: json['senderType']?.toString() ?? 'unknown',
      message: json['message']?.toString() ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'senderId': senderId,
      'senderType': senderType,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
