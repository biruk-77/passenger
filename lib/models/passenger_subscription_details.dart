// FILE: lib/models/passenger_subscription_details.dart
/* CRITICAL: DO NOT REMOVE OR ABBREVIATE. 
      This file must be delivered complete. 
      Any changes must preserve the exported public API. */
import 'contract/driver.dart'; // Re-uses the existing Vehicle model

class PassengerSubscriptionDetails {
  final String id;
  final String contractType;
  final String pickupLocation;
  final String dropoffLocation;
  final DateTime? expirationDate;
  final int daysUntilExpiry;
  final String? driverName;
  final String? driverPhone;
  final Vehicle? vehicleInfo;

  PassengerSubscriptionDetails({
    required this.id,
    required this.contractType,
    required this.pickupLocation,
    required this.dropoffLocation,
    this.expirationDate,
    required this.daysUntilExpiry,
    this.driverName,
    this.driverPhone,
    this.vehicleInfo,
  });

  factory PassengerSubscriptionDetails.fromJson(Map<String, dynamic> json) {
    return PassengerSubscriptionDetails(
      id: json['id'] as String? ?? '',
      contractType: json['contract_type'] as String? ?? 'N/A',
      pickupLocation: json['pickup_location'] as String? ?? 'N/A',
      dropoffLocation: json['dropoff_location'] as String? ?? 'N/A',
      expirationDate: DateTime.tryParse(json['expiration_date'] ?? ''),
      daysUntilExpiry: json['days_until_expiry'] as int? ?? 0,
      driverName: json['driver_name'] as String?,
      driverPhone: json['driver_phone'] as String?,
      vehicleInfo: json['vehicle_info'] != null
          ? Vehicle.fromJson(json['vehicle_info'])
          : null,
    );
  }
}
