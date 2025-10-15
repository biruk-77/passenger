// lib/models/contract/driver.dart
import 'dart:convert';

class Vehicle {
  final String model;
  final String plate;
  final String color;

  Vehicle({required this.model, required this.plate, required this.color});

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      model: json['car_model'] as String? ?? 'N/A',
      plate: json['car_plate'] as String? ?? 'N/A',
      color: json['car_color'] as String? ?? 'N/A',
    );
  }
}

// ✅ NEW: Model for the nested subscription info
class DriverSubscriptionInfo {
  final String id;
  final String status;
  final DateTime? startDate;
  final DateTime? endDate;

  DriverSubscriptionInfo({
    required this.id,
    required this.status,
    this.startDate,
    this.endDate,
  });

  factory DriverSubscriptionInfo.fromJson(Map<String, dynamic> json) {
    return DriverSubscriptionInfo(
      id: json['id'] as String? ?? 'N/A',
      status: json['status'] as String? ?? 'Unknown',
      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'])
          : null,
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'])
          : null,
    );
  }
}

class VehicleInfo {
  final String model;
  final String plate;
  final String color;

  VehicleInfo({required this.model, required this.plate, required this.color});

  factory VehicleInfo.fromJson(Map<String, dynamic> json) {
    return VehicleInfo(
      model: json['car_model'] ?? 'N/A',
      plate: json['car_plate'] ?? 'N/A',
      color: json['car_color'] ?? 'N/A',
    );
  }
}

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
    // Handle the case where vehicle_info is a JSON string
    VehicleInfo? vehicle;
    if (json['vehicle_info'] is String) {
      try {
        final vehicleMap = jsonDecode(json['vehicle_info']);
        vehicle = VehicleInfo.fromJson(vehicleMap);
      } catch (e) {
        vehicle = null;
      }
    } else if (json['vehicle_info'] is Map<String, dynamic>) {
      vehicle = VehicleInfo.fromJson(json['vehicle_info']);
    }

    return AssignedDriver(
      driverId: json['driver_id'] ?? 'N/A',
      driverName: json['driver_name'] ?? 'Unknown Driver',
      driverPhone: json['driver_phone'],
      driverEmail: json['driver_email'],
      vehicleInfo: vehicle,
    );
  }
}
