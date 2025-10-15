// lib/services/sms_service.dart

/// A simple service class whose only responsibility is to format the
/// ride request message string.
class SmsService {
  /// Formats the ride request details into a consistent string format.
  String formatRideRequestMessage({
    required String name,
    required String pickup,
    required String destination,
  }) {
    // The current timestamp is included for logging and tracking purposes.
    final timestamp = DateTime.now().toUtc().toIso8601String();

    // Using a multiline string for readability and to ensure newlines are handled correctly.
    return '''
RIDE-REQUEST-OFFLINE
Timestamp: $timestamp
Name: $name
Pickup: $pickup
Destination: $destination

Please call me back to confirm my booking.
''';
  }
}
