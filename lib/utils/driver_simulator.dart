// lib/utils/driver_simulator.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/driver_types.dart';

typedef OnDriverLocationUpdate =
    void Function(
      LatLng position,
      double bearing,
      double speedKmh,
      DriverState state,
    );
typedef OnSimulationDone = void Function();

class DriverSimulator {
  final List<LatLng> routePoints;
  final String vehicleType;
  final String roadType;
  final double baseSpeedKmh;
  final DriverBehavior driverBehavior;
  final OnDriverLocationUpdate onUpdate;
  final OnSimulationDone onDone;

  Timer? _timer;
  int _elapsedMilliseconds = 0;
  final double _totalDistanceKm;
  late int _simulationDurationSeconds;

  double _currentSpeedKmh;
  DriverState _currentState = DriverState.moving;
  final Random _random = Random();
  List<SimulationEvent> _scheduledEvents = [];

  int _lastCheckedTurnIndex = 1; // Start at 1 to avoid the error
  bool _isSlowingForTurn = false;

  DriverSimulator({
    required this.routePoints,
    required this.vehicleType,
    required this.roadType,
    required this.baseSpeedKmh,
    required this.driverBehavior,
    required this.onUpdate,
    required this.onDone,
  }) : _totalDistanceKm = _calculateTotalDistance(routePoints),
       _currentSpeedKmh = baseSpeedKmh {
    _calculateRealisticDuration();
    _scheduleRealisticEvents();
  }

  static double _calculateTotalDistance(List<LatLng> points) {
    if (points.length < 2) return 0.0;
    double totalDistance = 0.0;
    for (int i = 1; i < points.length; i++) {
      totalDistance += _haversineDistance(points[i - 1], points[i]);
    }
    return totalDistance;
  }

  static double _haversineDistance(LatLng p1, LatLng p2) {
    const R = 6371.0; // Earth's radius in kilometers
    final lat1 = p1.latitude * pi / 180;
    final lat2 = p2.latitude * pi / 180;
    final dLat = (p2.latitude - p1.latitude) * pi / 180;
    final dLng = (p2.longitude - p1.longitude) * pi / 180;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  void _calculateRealisticDuration() {
    double baseTimeHours = _totalDistanceKm / baseSpeedKmh;
    final behaviorFactor = 0.9 + (driverBehavior.aggression * 0.2);
    baseTimeHours *= behaviorFactor;
    final roadFactor = _getRoadTypeFactor(roadType);
    baseTimeHours *= roadFactor;
    final variation = 0.9 + _random.nextDouble() * 0.2;
    baseTimeHours *= variation;
    _simulationDurationSeconds = (baseTimeHours * 3600).toInt();
    if (_simulationDurationSeconds < 10) _simulationDurationSeconds = 10;
    debugPrint(
      "🚗 $vehicleType on $roadType road: "
      "${_totalDistanceKm.toStringAsFixed(2)} km, "
      "Base speed: ${baseSpeedKmh.toStringAsFixed(0)} km/h, "
      "Est. time: ${_simulationDurationSeconds ~/ 60}m ${_simulationDurationSeconds % 60}s",
    );
  }

  double _getRoadTypeFactor(String roadType) {
    const factors = {
      'motorway': 0.95,
      'trunk': 1.0,
      'primary': 1.05,
      'secondary': 1.1,
      'tertiary': 1.2,
      'residential': 1.4,
      'local': 1.3,
    };
    return factors[roadType] ?? 1.0;
  }

  void _scheduleRealisticEvents() {
    _scheduledEvents.clear();
    final stopProbability = _getStopProbability();
    final numPotentialStops = (_totalDistanceKm * stopProbability).toInt();
    for (int i = 0; i < numPotentialStops; i++) {
      _scheduledEvents.add(
        SimulationEvent(
          type: SimulationEventType.trafficStop,
          position: _random.nextDouble(),
          duration: _getStopDuration(),
        ),
      );
    }
    final numSpeedChanges = (_totalDistanceKm * 2).toInt();
    for (int i = 0; i < numSpeedChanges; i++) {
      _scheduledEvents.add(
        SimulationEvent(
          type: SimulationEventType.speedChange,
          position: _random.nextDouble(),
          duration: 0,
        ),
      );
    }
    _scheduledEvents.sort((a, b) => a.position.compareTo(b.position));
  }

  double _getStopProbability() {
    double baseProbability;
    switch (roadType) {
      case 'motorway':
        baseProbability = 0.1;
        break;
      case 'primary':
        baseProbability = 0.3;
        break;
      case 'secondary':
        baseProbability = 0.5;
        break;
      case 'tertiary':
        baseProbability = 0.8;
        break;
      case 'residential':
        baseProbability = 1.2;
        break;
      default:
        baseProbability = 0.6;
    }
    return baseProbability * (1.3 - driverBehavior.patience);
  }

  int _getStopDuration() {
    final baseDuration = 5000 + _random.nextInt(25000);
    return (baseDuration * (1.3 - driverBehavior.patience)).toInt();
  }

  void start() {
    stop();
    _elapsedMilliseconds = 0;
    _currentSpeedKmh = baseSpeedKmh;
    _currentState = DriverState.moving;
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_handleEvents()) return;
      _checkForTurns();
      if (!_isSlowingForTurn) {
        _updatePosition();
      }
    });
  }

  void _checkForTurns() {
    if (routePoints.length < 3 || _isSlowingForTurn) return;
    final currentPosition = _getPositionAtProgress(
      _elapsedMilliseconds / (_simulationDurationSeconds * 1000),
    );

    // --- ✅ THE FIX IS HERE ---
    // The loop must always start from index 1 to safely access `i - 1`.
    // We already use `_lastCheckedTurnIndex` to prevent re-checking old turns.
    for (int i = _lastCheckedTurnIndex; i < routePoints.length - 1; i++) {
      final turnPoint = routePoints[i];
      final distanceToTurn = _calculateDistance(currentPosition, turnPoint);

      if (distanceToTurn < 0.05) {
        // Since i is guaranteed to be >= 1, this is now safe.
        final prevPoint = routePoints[i - 1];
        final nextPoint = routePoints[i + 1];

        final bearingIn = calculateBearing(prevPoint, turnPoint);
        final bearingOut = calculateBearing(turnPoint, nextPoint);
        final turnAngle = (bearingOut - bearingIn).abs();

        if (turnAngle > 30 && turnAngle < 330) {
          _handleSharpTurn();
          _lastCheckedTurnIndex = i + 1;
          return;
        }
      }
    }
  }

  void _handleSharpTurn() {
    _isSlowingForTurn = true;
    final shouldStop = _random.nextDouble() > 0.6;
    final originalSpeed = _currentSpeedKmh;
    final targetSpeed = shouldStop ? 0.0 : originalSpeed * 0.3;
    final slowdownDuration = shouldStop ? 2000 : 1500;
    _currentState = shouldStop ? DriverState.stopped : DriverState.moving;

    _animateSpeedChange(
      originalSpeed,
      targetSpeed,
      (originalSpeed - targetSpeed) / (slowdownDuration / 1000.0),
      () {
        final pauseDuration = shouldStop
            ? _random.nextInt(3000) + 2000
            : _random.nextInt(1500) + 500;
        Future.delayed(Duration(milliseconds: pauseDuration), () {
          _currentState = DriverState.moving;
          _animateSpeedChange(
            targetSpeed,
            originalSpeed,
            (originalSpeed - targetSpeed) / 2.0,
            () {
              _isSlowingForTurn = false;
            },
          );
        });
      },
    );
  }

  bool _handleEvents() {
    final progress = _simulationDurationSeconds == 0
        ? 1.0
        : _elapsedMilliseconds / (_simulationDurationSeconds * 1000);
    while (_scheduledEvents.isNotEmpty &&
        _scheduledEvents.first.position <= progress) {
      final event = _scheduledEvents.removeAt(0);
      switch (event.type) {
        case SimulationEventType.trafficStop:
          _handleTrafficStop(event);
          return false;
        case SimulationEventType.speedChange:
          _handleSpeedChange();
          break;
      }
    }
    return true;
  }

  void _handleTrafficStop(SimulationEvent event) {
    _currentState = DriverState.stopped;
    _currentSpeedKmh = 0.0;
    final currentProgress =
        _elapsedMilliseconds / (_simulationDurationSeconds * 1000);
    final currentPoint = _getPositionAtProgress(
      currentProgress.clamp(0.0, 1.0),
    );
    onUpdate(currentPoint, _getBearing(), 0.0, DriverState.stopped);
    Future.delayed(Duration(milliseconds: event.duration), () {
      if (_timer?.isActive ?? false) {
        _currentState = DriverState.moving;
        _currentSpeedKmh = baseSpeedKmh;
      }
    });
  }

  void _handleSpeedChange() {
    final aggressionFactor = 0.8 + driverBehavior.aggression * 0.4;
    final consistencyFactor = 0.5 + driverBehavior.consistency * 0.5;
    double targetSpeed = baseSpeedKmh * aggressionFactor;
    targetSpeed +=
        (_random.nextDouble() - 0.5) *
        baseSpeedKmh *
        (1.0 - consistencyFactor) *
        0.5;
    targetSpeed = targetSpeed.clamp(baseSpeedKmh * 0.5, baseSpeedKmh * 1.5);
    final double accelerationRate = (driverBehavior.aggression * 7.0) + 3.0;
    _animateSpeedChange(_currentSpeedKmh, targetSpeed, accelerationRate, () {});
  }

  void _animateSpeedChange(
    double from,
    double to,
    double acceleration,
    VoidCallback onDone,
  ) {
    if ((to - from).abs() < 1.0) {
      _currentSpeedKmh = to;
      onDone();
      return;
    }
    final durationSeconds = (to - from).abs() / acceleration;
    final int steps = (durationSeconds * 10).round().clamp(1, 100);
    var currentStep = 0;
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      currentStep++;
      final progress = currentStep / steps;
      _currentSpeedKmh = from + (to - from) * progress;
      if (currentStep >= steps || !(_timer?.isActive ?? false)) {
        timer.cancel();
        _currentSpeedKmh = to;
        onDone();
      }
    });
  }

  void _updatePosition() {
    if (_simulationDurationSeconds <= 0) {
      _completeJourney();
      return;
    }
    _elapsedMilliseconds += 100;
    final double progress =
        _elapsedMilliseconds / (_simulationDurationSeconds * 1000);
    if (progress >= 1.0) {
      _completeJourney();
      return;
    }
    final newPosition = _getPositionAtProgress(progress);
    final bearing = _getBearing();
    onUpdate(newPosition, bearing, _currentSpeedKmh, _currentState);
  }

  LatLng _getPositionAtProgress(double progress) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final targetDistance = _totalDistanceKm * clampedProgress;
    
    if (routePoints.isEmpty) return const LatLng(0, 0);
    if (routePoints.length == 1) return routePoints.first;
    if (clampedProgress <= 0.0) return routePoints.first;
    if (clampedProgress >= 1.0) return routePoints.last;
    
    double accumulatedDistance = 0.0;
    
    for (int i = 1; i < routePoints.length; i++) {
      final segmentDistance = _haversineDistance(routePoints[i - 1], routePoints[i]);
      
      if (accumulatedDistance + segmentDistance >= targetDistance) {
        // The target point is within this segment
        final remainingDistance = targetDistance - accumulatedDistance;
        final segmentProgress = remainingDistance / segmentDistance;
        
        return _interpolateLatLng(
          routePoints[i - 1],
          routePoints[i],
          segmentProgress,
        );
      }
      
      accumulatedDistance += segmentDistance;
    }
    
    return routePoints.last;
  }

  LatLng _interpolateLatLng(LatLng start, LatLng end, double progress) {
    final lat = start.latitude + (end.latitude - start.latitude) * progress;
    final lng = start.longitude + (end.longitude - start.longitude) * progress;
    return LatLng(lat, lng);
  }

  double _getBearing() {
    if (_elapsedMilliseconds < 200 || _totalDistanceKm == 0) return 0.0;
    final currentProgress =
        _elapsedMilliseconds / (_simulationDurationSeconds * 1000);
    final prevProgress =
        (_elapsedMilliseconds - 100) / (_simulationDurationSeconds * 1000);
    final currentPoint = _getPositionAtProgress(
      currentProgress.clamp(0.0, 1.0),
    );
    final prevPoint = _getPositionAtProgress(prevProgress.clamp(0.0, 1.0));
    if (currentPoint.latitude == prevPoint.latitude &&
        currentPoint.longitude == prevPoint.longitude)
      return 0.0;
    return calculateBearing(prevPoint, currentPoint);
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

  double calculateBearing(LatLng from, LatLng to) {
    final lat1 = from.latitude * pi / 180;
    final lat2 = to.latitude * pi / 180;
    final lng1 = from.longitude * pi / 180;
    final lng2 = to.longitude * pi / 180;
    final y = sin(lng2 - lng1) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(lng2 - lng1);
    final bearing = atan2(y, x) * 180 / pi;
    return (bearing + 360) % 360;
  }

  void _completeJourney() {
    final endPoint = routePoints.isNotEmpty ? routePoints.last : const LatLng(0, 0);
    onUpdate(
      endPoint,
      0.0,
      0.0,
      DriverState.stopped,
    );
    stop();
    onDone();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _scheduledEvents.clear();
  }
}

enum SimulationEventType { trafficStop, speedChange }

class SimulationEvent {
  final SimulationEventType type;
  final double position;
  final int duration;

  SimulationEvent({
    required this.type,
    required this.position,
    required this.duration,
  });
}
