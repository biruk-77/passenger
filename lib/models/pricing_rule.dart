// lib/models/pricing_rule.dart
import 'package:flutter/foundation.dart';

// --- This is the wrapper for the API response ---
class FareEstimateResponse {
  final FareEstimate estimate;

  FareEstimateResponse({required this.estimate});

  factory FareEstimateResponse.fromJson(Map<String, dynamic> json) {
    return FareEstimateResponse(
      estimate: FareEstimate.fromJson(json['estimate'] as Map<String, dynamic>),
    );
  }
}

// --- This is the actual data model your UI will use ---
@immutable
class FareEstimate {
  // All the properties your UI needs are here:
  final double fare;
  final double? originalFare; // <-- ADD THIS LINE
  final String distanceText;
  final String durationText;
  final String currency;
  final double distanceKm;
  final int durationMinutes;

  const FareEstimate({
    required this.fare,
    this.originalFare, // <-- ADD THIS LINE
    required this.distanceText,
    required this.durationText,
    required this.currency,
    required this.distanceKm,
    required this.durationMinutes,
  });

  // This factory correctly parses the nested JSON object from the API
  factory FareEstimate.fromJson(Map<String, dynamic> json) {
    return FareEstimate(
      // The API uses 'estimatedFare' for the price
      fare: (json['estimatedFare'] as num?)?.toDouble() ?? 0.0,

      // Assumes the API will send 'originalFare' when there's a discount
      originalFare: (json['originalFare'] as num?)
          ?.toDouble(), // <-- ADD THIS LINE
      // These were the missing pieces
      distanceText: json['distanceText'] as String? ?? '...',
      durationText: json['durationText'] as String? ?? '...',

      // Other useful data
      currency: json['currency'] as String? ?? 'USD',
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0.0,
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 0,
    );
  }
}
