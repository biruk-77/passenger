// lib/models/discovery_response.dart

import 'package:flutter/foundation.dart';
import 'nearby_driver.dart'; // Assumes you have this model
import 'pricing_rule.dart'; // Assumes your FareEstimate model is here

/// A composite data model representing the response from the driver discovery
/// and fare estimation endpoint.
///
/// This object encapsulates both the list of available drivers nearby and the
/// calculated fare estimate for the proposed trip, allowing the UI to be
/// built from a single, efficient API call.
@immutable
class DiscoveryResponse {
  /// A list of drivers that are currently available within the specified radius.
  final List<NearbyDriver> drivers;

  /// The estimated fare details for the trip from pickup to dropoff.
  final FareEstimate estimate;

  const DiscoveryResponse({required this.drivers, required this.estimate});

  /// Creates a [DiscoveryResponse] instance from a JSON map.
  ///
  /// This factory constructor includes robust parsing with type checking and
  /// default values to prevent runtime errors from malformed API responses.
  factory DiscoveryResponse.fromJson(Map<String, dynamic> json) {
    try {
      // Safely parse the 'drivers' list. If it's null or not a list, default to an empty list.
      final driversData = json['drivers'];
      final List<NearbyDriver> parsedDrivers = (driversData is List)
          ? driversData
                .map(
                  (driverJson) =>
                      NearbyDriver.fromJson(driverJson as Map<String, dynamic>),
                )
                .toList()
          : <NearbyDriver>[];

      // Safely parse the 'estimate' object.
      // Throws an error if 'estimate' is null or not a map, as it's essential.
      final estimateData = json['estimate'];
      if (estimateData == null || estimateData is! Map<String, dynamic>) {
        throw const FormatException(
          "Missing or invalid 'estimate' data in DiscoveryResponse JSON",
        );
      }
      final FareEstimate parsedEstimate = FareEstimate.fromJson(estimateData);

      return DiscoveryResponse(
        drivers: parsedDrivers,
        estimate: parsedEstimate,
      );
    } catch (e) {
      debugPrint("🚨 Error parsing DiscoveryResponse: $e");
      // Depending on your error handling strategy, you might want to rethrow
      // or return a default/error state object. Rethrowing is often better.
      rethrow;
    }
  }

  /// Creates a copy of this [DiscoveryResponse] instance with optional new values.
  DiscoveryResponse copyWith({
    List<NearbyDriver>? drivers,
    FareEstimate? estimate,
  }) {
    return DiscoveryResponse(
      drivers: drivers ?? this.drivers,
      estimate: estimate ?? this.estimate,
    );
  }

  @override
  String toString() =>
      'DiscoveryResponse(drivers: ${drivers.length} drivers, estimate: $estimate)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DiscoveryResponse &&
        listEquals(other.drivers, drivers) &&
        other.estimate == estimate;
  }

  @override
  int get hashCode => drivers.hashCode ^ estimate.hashCode;
}
