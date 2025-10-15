// lib/models/vehicle_type.dart
import 'package:flutter/material.dart';

class VehicleType {
  final String name;
  final IconData icon;
  final String imagePath; // for in-app UI (assets)
  final String? description;

  VehicleType({
    required this.name,
    required this.icon,
    required this.imagePath,
    this.description,
  });

  // Remote image URLs used for notifications
  String get notificationIconUrl {
    switch (name.toLowerCase()) {
      case 'mini':
        return "https://img.icons8.com/color/512/hatchback.png"; // Compact car for mini rides
      case 'sedan':
        return "https://img.icons8.com/color/512/sedan.png"; // Standard sedan for regular rides
      case 'suv':
        return "https://img.icons8.com/color/512/suv.png"; // SUV for premium or spacious rides
      case 'van':
        return "https://img.icons8.com/color/512/van.png"; // Van for group rides
      case 'bajaj':
        return "https://img.icons8.com/color/512/auto-rickshaw.png"; // Auto-rickshaw for Bajaj/tuk-tuk rides
      case 'motorbike':
        return "https://img.icons8.com/color/512/motorcycle.png"; // Motorbike for quick rides
      default:
        return "https://img.icons8.com/color/512/car.png"; // Generic car icon
    }
  }

  static const String genericCarIconUrl =
      "https://img.icons8.com/color/512/car.png"; // Generic car icon for fallback
  static const String driverIconUrl =
      "https://img.icons8.com/color/512/driver.png"; // Realistic driver icon// Realistic driver silhouette icon from Flaticon
  factory VehicleType.fromName(String name) {
    return VehicleType(
      name: name,
      icon: _getIconForVehicle(name),
      imagePath: _getImagePathForVehicle(name),
    );
  }

  factory VehicleType.fromJson(Map<String, dynamic> json) {
    final name = (json['name'] ?? '').toString();
    return VehicleType(
      name: name,
      description: json['description']?.toString(),
      icon: _getIconForVehicle(name),
      imagePath: _getImagePathForVehicle(name),
    );
  }

  static IconData _getIconForVehicle(String? name) {
    switch (name?.toLowerCase()) {
      case 'mini':
        return Icons.directions_car;
      case 'sedan':
        return Icons.local_taxi;
      case 'van':
        return Icons.airport_shuttle;
      case 'suv':
        return Icons.car_rental;
      case 'motorbike':
        return Icons.motorcycle;
      case 'bajaj':
        return Icons.electric_moped;
      default:
        return Icons.drive_eta;
    }
  }

  static String _getImagePathForVehicle(String? name) {
    switch (name?.toLowerCase()) {
      case 'sedan':
        return 'assets/images/sedan_car.png';
      case 'mini':
        return 'assets/images/mini_car.png';
      case 'van':
        return 'assets/images/van_car.png';
      case 'suv':
        return 'assets/images/suv_car.png';
      case 'motorbike':
        return 'assets/images/motorbike.png';
      case 'bajaj':
        return 'assets/images/bajaj.png';
      default:
        return 'assets/images/car_icon.png';
    }
  }

  String get notificationIconResourceName {
    switch (name.toLowerCase()) {
      case 'sedan':
        return 'sedan_car';
      case 'mini':
        return 'mini_car';
      case 'van':
        return 'van_car';
      case 'bajaj':
        return 'bajaj';
      default:
        return 'sedan_car';
    }
  }
}
