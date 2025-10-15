// models/ride_request.dart
class RideRequest {
  final String name;
  final String pickup;
  final String destination;
  final DateTime timestamp;

  RideRequest({
    required this.name,
    required this.pickup,
    required this.destination,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'pickup': pickup,
      'destination': destination,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  bool get isValid => 
      name.trim().isNotEmpty && 
      pickup.trim().isNotEmpty && 
      destination.trim().isNotEmpty;
}