// lib/models/driver_types.dart

enum DriverState {
  moving,
  stopped, // Temporary stop (traffic, pickup)
  paused, // Longer break
}

class DriverBehavior {
  final double aggression; // 0.0-1.0: affects speed and lane changes
  final double patience; // 0.0-1.0: affects stopping behavior
  final double consistency; // 0.0-1.0: affects speed maintenance

  DriverBehavior({
    required this.aggression,
    required this.patience,
    required this.consistency,
  });
}

class DriverProfile {
  final String vehicleType;
  final double probability;
  final double
  highwayPreference; // Not directly used in the provided code, but good for future expansion
  final double
  localRoadPreference; // Not directly used in the provided code, but good for future expansion

  DriverProfile(
    this.vehicleType,
    this.probability,
    this.highwayPreference,
    this.localRoadPreference,
  );
}
