// lib/models/simulated_driver.dart
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'nearby_driver.dart';
import 'driver_types.dart'; // Import the new types

/// A model specifically for managing the state of a single simulated driver.
/// It is not used for real API data, only for the demo simulation.
class SimulatedDriver {
  final String id;
  final String name; // ✅ ADDED THIS
  final LatLng position;
  final double bearing;
  final String vehicleType;
  final DriverState state;
  final double speedKmh;

  SimulatedDriver({
    required this.id,
    required this.name, // ✅ ADDED THIS
    required this.position,
    required this.bearing,
    required this.vehicleType,
    required this.state,
    required this.speedKmh,
  });

  /// Creates an updated copy of this driver. Essential for state management.
  SimulatedDriver copyWith({
    String? name, // ✅ ADDED THIS
    LatLng? position,
    double? bearing,
    DriverState? state,
    double? speedKmh,
  }) {
    return SimulatedDriver(
      id: id,
      name: name ?? this.name, // ✅ ADDED THIS
      position: position ?? this.position,
      bearing: bearing ?? this.bearing,
      vehicleType: vehicleType,
      state: state ?? this.state,
      speedKmh: speedKmh ?? this.speedKmh,
    );
  }

  /// Converts this simulated driver into a `NearbyDriver` that the UI can display.
  NearbyDriver toNearbyDriver() {
    return NearbyDriver(
      id: id,
      name: name, // ✅ USE THE NEW NAME PROPERTY
      position: position,
      bearing: bearing,
      vehicleType: vehicleType,
      available: state != DriverState.paused,
      rating: 4.5 + (int.parse(id.split('_').last) % 5) / 10,
      speedKmh: speedKmh,
      state: state,
    );
  }
}
