// lib/models/rewards.dart
// This file defines models for rewards and fare estimations.

/// Represents a passenger's earned reward.
class PassengerReward {
  final String id;
  final String description;
  final double value; // The monetary value of the reward
  final DateTime expiryDate;

  PassengerReward({
    required this.id,
    required this.description,
    required this.value,
    required this.expiryDate,
  });

  /// Factory constructor to create a [PassengerReward] from a JSON map.
  factory PassengerReward.fromJson(Map<String, dynamic> json) {
    return PassengerReward(
      id: json['id'] ?? json['_id'], // Backend might use 'id' or '_id'
      description: json['description'] ?? 'No description',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'])
          : DateTime.now().add(
              const Duration(days: 30),
            ), // Default expiry if none
    );
  }

  // Optional: Convert to JSON if needed for sending reward data back
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'description': description,
      'value': value,
      'expiryDate': expiryDate.toIso8601String(),
    };
  }
}

/// Represents a fare estimate response from the API.
class FareEstimateResponse {
  final double estimatedFare;
  final String currency;
  final String? fareBreakdown; // Optional detailed breakdown string

  FareEstimateResponse({
    required this.estimatedFare,
    this.currency = 'USD', // Default currency
    this.fareBreakdown,
  });

  /// Factory constructor to create a [FareEstimateResponse] from a JSON map.
  factory FareEstimateResponse.fromJson(Map<String, dynamic> json) {
    return FareEstimateResponse(
      estimatedFare: (json['estimatedFare'] as num).toDouble(),
      currency: json['currency'] ?? 'USD',
      fareBreakdown: json['fareBreakdown'],
    );
  }

  // Optional: Convert to JSON if needed
  Map<String, dynamic> toJson() {
    return {
      'estimatedFare': estimatedFare,
      'currency': currency,
      'fareBreakdown': fareBreakdown,
    };
  }
}

class FareEstimate {
  final double estimatedFare;
  final String currency;
  final String? fareBreakdown;

  FareEstimate({
    required this.estimatedFare,
    this.currency = 'USD',
    this.fareBreakdown,
  });

  factory FareEstimate.fromJson(Map<String, dynamic> json) {
    return FareEstimate(
      estimatedFare: (json['estimatedFare'] as num).toDouble(),
      currency: json['currency'] ?? 'Birr',
      fareBreakdown: json['fareBreakdown'],
    );
  }
}
