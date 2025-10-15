import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// --- Helper Functions ---
num _parseNum(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value;
  if (value is String) return num.tryParse(value) ?? 0;
  return 0;
}

num? _parseNullableNum(dynamic value) {
  if (value == null) return null;
  if (value is num) return value;
  if (value is String) return num.tryParse(value);
  return null;
}

DateTime? _parseDate(String? date) {
  if (date == null) return null;
  return DateTime.tryParse(date);
}

// --- Vehicle Info Model ---
class VehicleInfo {
  final String model;
  final String plate;
  final String color;

  VehicleInfo({required this.model, required this.plate, required this.color});

  factory VehicleInfo.fromJson(Map<String, dynamic> json) {
    return VehicleInfo(
      model: json['model'] ?? json['car_model'] ?? 'N/A',
      plate: json['plate'] ?? json['car_plate'] ?? 'N/A',
      color: json['color'] ?? json['car_color'] ?? 'N/A',
    );
  }

  Map<String, dynamic> toJson() => {
    'model': model,
    'plate': plate,
    'color': color,
  };
}

// --- Assigned Driver Model ---
class AssignedDriver {
  final String driverId;
  final String driverName;
  final String? driverPhone;
  final String? driverEmail;
  final VehicleInfo? vehicleInfo;

  AssignedDriver({
    required this.driverId,
    required this.driverName,
    this.driverPhone,
    this.driverEmail,
    this.vehicleInfo,
  });

  factory AssignedDriver.fromJson(Map<String, dynamic> json) {
    VehicleInfo? vehicle;
    if (json['vehicle_info'] is String) {
      try {
        final vehicleMap = jsonDecode(json['vehicle_info']);
        if (vehicleMap is Map<String, dynamic>) {
          vehicle = VehicleInfo.fromJson(vehicleMap);
        }
      } catch (e) {
        debugPrint("Error parsing vehicle_info JSON string: $e");
        vehicle = null;
      }
    } else if (json['vehicle_info'] is Map<String, dynamic>) {
      vehicle = VehicleInfo.fromJson(json['vehicle_info']);
    }

    return AssignedDriver(
      driverId:
          json['id']?.toString() ?? json['driver_id']?.toString() ?? 'N/A',
      driverName: json['name'] ?? json['driver_name'] ?? 'Unknown Driver',
      driverPhone: json['phone'] ?? json['driver_phone'],
      driverEmail: json['email'] ?? json['driver_email'],
      vehicleInfo: vehicle,
    );
  }

  Map<String, dynamic> toJson() => {
    'driver_id': driverId,
    'driver_name': driverName,
    'driver_phone': driverPhone,
    'driver_email': driverEmail,
    'vehicle_info': vehicleInfo?.toJson(),
  };

  AssignedDriver copyWith({
    String? driverId,
    String? driverName,
    String? driverPhone,
    String? driverEmail,
    VehicleInfo? vehicleInfo,
  }) {
    return AssignedDriver(
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      driverEmail: driverEmail ?? this.driverEmail,
      vehicleInfo: vehicleInfo ?? this.vehicleInfo,
    );
  }
}

class Contract {
  final String id;
  final String? contractTypeId;
  final String? name;
  final String contractType;
  final String status;
  final num discountPercentage;
  final num basePricePerKm;
  final num minimumFare;
  // ✅ NEW FIELDS ADDED HERE
  final String? description;
  final int maximumPassengers;
  final String? features;

  Contract({
    required this.id,
    required this.contractTypeId,
    required this.name,
    required this.contractType,
    required this.status,
    required this.discountPercentage,
    required this.basePricePerKm,
    required this.minimumFare,
    // ✅ NEW FIELDS ADDED HERE
    this.description,
    required this.maximumPassengers,
    this.features,
  });

  factory Contract.fromJson(Map<String, dynamic> json) {
    return Contract(
      id: json['id'] ?? '',
      contractTypeId: json['contract_type_id'] ?? '',
      name: json['name'] ?? '',
      contractType: json['name'] ?? 'UNKNOWN',
      status: (json['is_active'] == true) ? 'ACTIVE' : 'INACTIVE',
      discountPercentage: _parseNum(json['discount_percentage']),
      basePricePerKm: _parseNum(json['base_price_per_km']),
      minimumFare: _parseNum(json['minimum_fare']),
      // ✅ NEW FIELDS ADDED HERE
      description: json['description'],
      maximumPassengers: _parseNum(json['maximum_passengers']).toInt(),
      features: json['features'],
    );
  }
}

class Subscription {
  final String id;
  final String? contractId;
  final String? contractTypeId;
  final int passengerId;
  final String passengerName;
  final String? passengerPhone;
  final String? passengerEmail;
  final String pickupLocation;
  final String dropoffLocation;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final double? dropoffLatitude;
  final double? dropoffLongitude;
  final String contractType;
  final DateTime? startDate;
  final DateTime? endDate;
  final num fare;
  final num finalFare;
  final num distanceKm;
  final String status;
  final String paymentStatus;
  final AssignedDriver? assignedDriver;

  Subscription({
    required this.id,
    this.contractId,
    this.contractTypeId,
    required this.passengerId,
    required this.passengerName,
    this.passengerPhone,
    this.passengerEmail,
    required this.pickupLocation,
    required this.dropoffLocation,
    this.pickupLatitude,
    this.pickupLongitude,
    this.dropoffLatitude,
    this.dropoffLongitude,
    required this.contractType,
    this.startDate,
    this.endDate,
    required this.fare,
    required this.finalFare,
    required this.distanceKm,
    required this.status,
    required this.paymentStatus,
    this.assignedDriver,
  });

  String? get driverId => assignedDriver?.driverId;

  // ✅ ================== THIS IS THE CORRECTED SECTION ================== ✅
  factory Subscription.fromJson(Map<String, dynamic> json) {
    AssignedDriver? driver;

    // Case 1: The API provides a clean, nested 'assigned_driver' object.
    if (json['assigned_driver'] is Map<String, dynamic>) {
      driver = AssignedDriver.fromJson(json['assigned_driver']);
    }
    // Case 2: The API provides flattened driver details at the top level (as seen in your log).
    else if (json['driver_id'] != null) {
      // We manually build a clean map for the driver parser.
      // This is the crucial fix that prevents the subscription's 'id' from
      // overwriting the driver's 'id'.
      final driverData = {
        'id': json['driver_id'], // Map the correct ID source
        'name': json['driver_name'], // Map the correct name source
        'phone': json['driver_phone'],
        'email': json['driver_email'],
        'vehicle_info': json['vehicle_info'],
      };
      driver = AssignedDriver.fromJson(driverData);
    }
    // ✅ ================== END OF CORRECTED SECTION ================== ✅

    return Subscription(
      id: json['id'],
      contractId: json['contract_id'],
      contractTypeId: json['contract_type_id'],
      passengerId: _parseNum(json['passenger_id']).toInt(),
      passengerName: json['passenger_name'] ?? 'N/A',
      passengerPhone: json['passenger_phone'],
      passengerEmail: json['passenger_email'],
      pickupLocation: json['pickup_location'] ?? 'N/A',
      dropoffLocation: json['dropoff_location'] ?? 'N/A',
      pickupLatitude: _parseNullableNum(json['pickup_latitude'])?.toDouble(),
      pickupLongitude: _parseNullableNum(json['pickup_longitude'])?.toDouble(),
      dropoffLatitude: _parseNullableNum(json['dropoff_latitude'])?.toDouble(),
      dropoffLongitude: _parseNullableNum(
        json['dropoff_longitude'],
      )?.toDouble(),
      contractType: json['contract_type'] ?? 'N/A',
      startDate: _parseDate(json['start_date']),
      endDate: _parseDate(json['end_date']),
      fare: _parseNum(json['fare']),
      finalFare: _parseNum(json['final_fare']),
      distanceKm: _parseNum(json['distance_km']),
      status: json['status'] ?? 'UNKNOWN',
      paymentStatus: json['payment_status'] ?? 'UNKNOWN',
      assignedDriver: driver,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'contractId': contractId,
    'contractTypeId': contractTypeId,
    'passengerId': passengerId,
    'passengerName': passengerName,
    'passengerPhone': passengerPhone,
    'passengerEmail': passengerEmail,
    'pickupLocation': pickupLocation,
    'dropoffLocation': dropoffLocation,
    'pickupLatitude': pickupLatitude,
    'pickupLongitude': pickupLongitude,
    'dropoffLatitude': dropoffLatitude,
    'dropoffLongitude': dropoffLongitude,
    'contractType': contractType,
    'startDate': startDate?.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'fare': fare,
    'finalFare': finalFare,
    'distanceKm': distanceKm,
    'status': status,
    'paymentStatus': paymentStatus,
    'assignedDriver': assignedDriver?.toJson(),
  };

  LatLng? get startPoint => (pickupLatitude != null && pickupLongitude != null)
      ? LatLng(pickupLatitude!, pickupLongitude!)
      : null;

  LatLng? get destinationPoint =>
      (dropoffLatitude != null && dropoffLongitude != null)
      ? LatLng(dropoffLatitude!, dropoffLongitude!)
      : null;

  Subscription copyWith({
    String? id,
    String? contractId,
    String? contractTypeId,
    int? passengerId,
    String? passengerName,
    String? passengerPhone,
    String? passengerEmail,
    String? pickupLocation,
    String? dropoffLocation,
    double? pickupLatitude,
    double? pickupLongitude,
    double? dropoffLatitude,
    double? dropoffLongitude,
    String? contractType,
    DateTime? startDate,
    DateTime? endDate,
    num? fare,
    num? finalFare,
    num? distanceKm,
    String? status,
    String? paymentStatus,
    AssignedDriver? assignedDriver,
  }) {
    return Subscription(
      id: id ?? this.id,
      contractId: contractId ?? this.contractId,
      contractTypeId: contractTypeId ?? this.contractTypeId,
      passengerId: passengerId ?? this.passengerId,
      passengerName: passengerName ?? this.passengerName,
      passengerPhone: passengerPhone ?? this.passengerPhone,
      passengerEmail: passengerEmail ?? this.passengerEmail,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      pickupLatitude: pickupLatitude ?? this.pickupLatitude,
      pickupLongitude: pickupLongitude ?? this.pickupLongitude,
      dropoffLatitude: dropoffLatitude ?? this.dropoffLatitude,
      dropoffLongitude: dropoffLongitude ?? this.dropoffLongitude,
      contractType: contractType ?? this.contractType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      fare: fare ?? this.fare,
      finalFare: finalFare ?? this.finalFare,
      distanceKm: distanceKm ?? this.distanceKm,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      assignedDriver: assignedDriver ?? this.assignedDriver,
    );
  }
}
