// lib/utils/nearby_driver_simulator_manager.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/nearby_driver.dart';
import '../models/simulated_driver.dart';
import '../services/google_maps_service.dart';
import 'driver_simulator.dart';
import '../models/driver_types.dart'; // ADD THIS IMPORT

typedef OnDriversUpdated = void Function(List<NearbyDriver> drivers);

class NearbyDriverSimulatorManager {
  final GoogleMapsService _googleMapsService;
  final OnDriversUpdated onDriversUpdated;

  final List<SimulatedDriver> _simulatedDrivers = [];
  final List<DriverSimulator?> _simulators = [];
  bool _isRunning = false;
  int _nextDriverId = 0;

  late LatLng _areaCenter;
  late double _searchRadiusKm;

  // --- ✅ NEW: List of Ethiopian names ---
  final List<String> _ethiopianNames = [
    'Abebe',
    'Bekele',
    'Meselech',
    'Fatuma',
    'Kebede',
    'Taye',
    'Almaz',
    'Worknesh',
    'Getachew',
    'Tsehay',
    'Berhanu',
    'Genet',
    'Haile',
    'Meseret',
    'Dawit',
    'Sofia',
    'Yohannes',
    'Hana',
    'Daniel',
    'Sara',
  ];

  // Realistic driver types with different behaviors
  final List<DriverProfile> _driverProfiles = [
    DriverProfile('Standard', 0.6, 0.3, 0.1),
    DriverProfile('Premium', 0.2, 0.7, 0.1),
    DriverProfile('Economy', 0.2, 0.1, 0.7),
  ];

  Timer? _uiUpdateTimer;
  bool _hasPendingUiUpdate = false;
  static const Duration _uiUpdateInterval = Duration(milliseconds: 500);

  NearbyDriverSimulatorManager({
    required GoogleMapsService googleMapsService,
    required this.onDriversUpdated,
  }) : _googleMapsService = googleMapsService;

  void start({
    required LatLng centerPoint,
    required double searchRadiusKm,
    int numberOfDrivers = 15,
  }) {
    if (_isRunning) return;
    _isRunning = true;
    _areaCenter = centerPoint;
    _searchRadiusKm = searchRadiusKm;
    _nextDriverId = 0;

    debugPrint(
      "🗺️ Starting ULTRA-REALISTIC driver simulation with $numberOfDrivers drivers",
    );

    _simulatedDrivers.clear();
    _simulators.clear();
    for (int i = 0; i < numberOfDrivers; i++) {
      _spawnNewDriver();
    }

    _uiUpdateTimer = Timer.periodic(_uiUpdateInterval, (_) {
      if (_hasPendingUiUpdate && _isRunning) {
        final driversForUi = _simulatedDrivers
            .map((sim) => sim.toNearbyDriver())
            .toList();
        onDriversUpdated(driversForUi);
        _hasPendingUiUpdate = false;
      }
    });
  }

  void stop() {
    if (!_isRunning) return;
    debugPrint("🛑 Stopping all driver simulations.");
    _uiUpdateTimer?.cancel();
    for (var simulator in _simulators) {
      simulator?.stop();
    }
    _simulators.clear();
    _simulatedDrivers.clear();
    _isRunning = false;
    onDriversUpdated([]);
  }

  void updateSearchRadius(double newRadiusKm) {
    if (!_isRunning) return;
    debugPrint("✅ Radius updated to ${newRadiusKm.toStringAsFixed(1)}km.");
    _searchRadiusKm = newRadiusKm;
  }

  void _spawnNewDriver() {
    final vehicleType = _getRandomVehicleType();

    // --- ✅ FIX: Generate a random Ethiopian name ---
    final driverName =
        _ethiopianNames[Random().nextInt(_ethiopianNames.length)];

    // --- ✅ FIX: Spawn drivers on "bigger" roads more often ---
    final startPoint = _getPointOnMajorRoad();
    final driverState = _getInitialDriverState();

    final driver = SimulatedDriver(
      id: 'sim_driver_${_nextDriverId++}',
      name: driverName, // Assign the name
      position: startPoint,
      bearing: Random().nextDouble() * 360,
      vehicleType: vehicleType,
      state: driverState,
      speedKmh: driverState == DriverState.moving
          ? _getRealisticSpeed(
              vehicleType,
              'primary',
            ) // Assume starting on a primary road
          : 0.0,
    );

    _simulatedDrivers.add(driver);
    _simulators.add(null);

    if (driverState == DriverState.moving) {
      _assignNewRouteToDriver(_simulatedDrivers.length - 1);
    } else {
      Future.delayed(Duration(seconds: Random().nextInt(120) + 30), () {
        if (_isRunning && _simulatedDrivers.contains(driver)) {
          final index = _simulatedDrivers.indexOf(driver);
          if (index != -1) {
            _simulatedDrivers[index] = driver.copyWith(
              state: DriverState.moving,
            );
            _assignNewRouteToDriver(index);
          }
        }
      });
    }
  }

  String _getRandomVehicleType() {
    final rand = Random().nextDouble();
    double cumulative = 0.0;
    for (final profile in _driverProfiles) {
      cumulative += profile.probability;
      if (rand <= cumulative) return profile.vehicleType;
    }
    return 'Standard';
  }

  DriverState _getInitialDriverState() {
    final rand = Random().nextDouble();
    if (rand < 0.7) return DriverState.moving;
    if (rand < 0.9) return DriverState.stopped;
    return DriverState.paused;
  }

  Future<void> _assignNewRouteToDriver(int driverIndex) async {
    if (!_isRunning || driverIndex >= _simulatedDrivers.length) return;

    final driver = _simulatedDrivers[driverIndex];

    // --- ✅ FIX: Make the destination also likely to be on a major road ---
    final destination = _getPointOnMajorRoad();

    final routeDetails = await _googleMapsService.getDirectionsInfo(
      driver.position,
      destination,
    );

    if (routeDetails != null && routeDetails.points.isNotEmpty && _isRunning) {
      final roadType = _analyzeRouteRoadType(routeDetails.points);
      final baseSpeed = _getRealisticSpeed(driver.vehicleType, roadType);
      final speedVariation = 0.8 + Random().nextDouble() * 0.4;
      final driverSpeed = baseSpeed * speedVariation;

      final newSimulator = DriverSimulator(
        routePoints: routeDetails.points,
        vehicleType: driver.vehicleType,
        roadType: roadType,
        baseSpeedKmh: driverSpeed,
        driverBehavior: _getDriverBehavior(driver.vehicleType),
        onUpdate: (position, bearing, speed, state) {
          if (_isRunning && driverIndex < _simulatedDrivers.length) {
            final updatedDriver = _simulatedDrivers[driverIndex].copyWith(
              position: position,
              bearing: bearing,
              speedKmh: speed,
              state: state,
            );
            _simulatedDrivers[driverIndex] = updatedDriver;
            _hasPendingUiUpdate = true;
          }
        },
        onDone: () => _handleDriverCompletion(driverIndex),
      );

      if (driverIndex < _simulators.length) {
        _simulators[driverIndex] = newSimulator;
        newSimulator.start();
      }
    } else {
      await Future.delayed(const Duration(seconds: 10));
      if (_isRunning) _assignNewRouteToDriver(driverIndex);
    }
  }

  // --- ✅ NEW: Helper to get points on bigger roads ---
  LatLng _getPointOnMajorRoad() {
    // Bias the random point generation. 80% of the time,
    // generate a point in the outer ring of the circle, where major
    // roads are more likely to be. 20% of the time, use the whole area.
    final rand = Random();
    double minRadius = rand.nextDouble() < 0.8 ? _searchRadiusKm * 0.5 : 0.0;
    double maxRadius = _searchRadiusKm;

    return _getRandomPointInRing(_areaCenter, minRadius, maxRadius);
  }

  double _getRealisticSpeed(String vehicleType, String roadType) {
    final baseSpeeds = {
      'motorway': {'Standard': 90.0, 'Premium': 110.0, 'Economy': 80.0},
      'trunk': {'Standard': 70.0, 'Premium': 85.0, 'Economy': 65.0},
      'primary': {'Standard': 60.0, 'Premium': 70.0, 'Economy': 55.0},
      'secondary': {'Standard': 50.0, 'Premium': 55.0, 'Economy': 45.0},
      'tertiary': {'Standard': 40.0, 'Premium': 45.0, 'Economy': 35.0},
      'residential': {'Standard': 25.0, 'Premium': 30.0, 'Economy': 20.0},
      'local': {'Standard': 30.0, 'Premium': 35.0, 'Economy': 25.0},
    };
    return baseSpeeds[roadType]?[vehicleType] ?? 40.0;
  }

  String _analyzeRouteRoadType(List<LatLng> routePoints) {
    final distance = _calculateRouteDistance(routePoints);
    final straightness = _calculateRouteStraightness(routePoints);

    if (distance > 10.0 && straightness > 0.85) return 'motorway';
    if (distance > 5.0 && straightness > 0.7) return 'primary';
    if (distance > 2.0) return 'secondary';
    if (distance > 0.8) return 'tertiary';
    return 'residential';
  }

  double _calculateRouteDistance(List<LatLng> points) {
    double total = 0.0;
    for (int i = 1; i < points.length; i++) {
      total += _calculateDistance(points[i - 1], points[i]);
    }
    return total;
  }

  double _calculateRouteStraightness(List<LatLng> points) {
    if (points.length < 3) return 1.0;
    final straightLineDistance = _calculateDistance(points.first, points.last);
    final actualDistance = _calculateRouteDistance(points);
    if (actualDistance == 0) return 1.0;
    return straightLineDistance / actualDistance;
  }

  double _calculateDistance(LatLng p1, LatLng p2) {
    const R = 6371.0;
    final lat1 = p1.latitude * pi / 180;
    final lat2 = p2.latitude * pi / 180;
    final dLat = (p2.latitude - p1.latitude) * pi / 180;
    final dLng = (p2.longitude - p1.longitude) * pi / 180;
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  DriverBehavior _getDriverBehavior(String vehicleType) {
    return DriverBehavior(
      aggression: vehicleType == 'Premium'
          ? 0.7 + Random().nextDouble() * 0.2
          : vehicleType == 'Economy'
          ? 0.3 - Random().nextDouble() * 0.2
          : 0.5 + (Random().nextDouble() - 0.5) * 0.2,
      patience: vehicleType == 'Premium'
          ? 0.4 - Random().nextDouble() * 0.2
          : vehicleType == 'Economy'
          ? 0.8 + Random().nextDouble() * 0.2
          : 0.6 + (Random().nextDouble() - 0.5) * 0.2,
      consistency: 0.5 + Random().nextDouble() * 0.3,
    );
  }

  void _handleDriverCompletion(int driverIndex) {
    if (!_isRunning || driverIndex >= _simulatedDrivers.length) return;
    final rand = Random().nextDouble();
    if (rand < 0.6) {
      _assignNewRouteToDriver(driverIndex);
    } else if (rand < 0.85) {
      final driver = _simulatedDrivers[driverIndex];
      _simulatedDrivers[driverIndex] = driver.copyWith(
        state: DriverState.stopped,
        speedKmh: 0.0,
      );
      _hasPendingUiUpdate = true;
      Future.delayed(Duration(minutes: Random().nextInt(10) + 5), () {
        if (_isRunning && driverIndex < _simulatedDrivers.length) {
          if (_simulatedDrivers[driverIndex].id == driver.id) {
            _simulatedDrivers[driverIndex] = driver.copyWith(
              state: DriverState.moving,
            );
            _assignNewRouteToDriver(driverIndex);
          }
        }
      });
    } else {
      if (driverIndex < _simulatedDrivers.length) {
        _simulators[driverIndex]?.stop();
        _simulatedDrivers.removeAt(driverIndex);
        _simulators.removeAt(driverIndex);
        _spawnNewDriver();
      }
    }
  }

  LatLng _getRandomPointInRing(
    LatLng center,
    double minRadiusKm,
    double maxRadiusKm,
  ) {
    final random = Random();
    final minRadiusDeg = minRadiusKm / 111.32;
    final maxRadiusDeg = maxRadiusKm / 111.32;

    // Generate a random radius between min and max
    final radiusInDegrees =
        minRadiusDeg +
        (maxRadiusDeg - minRadiusDeg) * sqrt(random.nextDouble());
    final t = 2 * pi * random.nextDouble();
    final x = radiusInDegrees * cos(t);
    final y = radiusInDegrees * sin(t);

    final newX = x / cos(center.latitude * pi / 180);
    return LatLng(center.latitude + y, center.longitude + newX);
  }
}
