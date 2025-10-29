// lib/models/passenger.dart

import 'dart:convert';

class Passenger {
  final String id;
  final String name;
  final String phone;
  final String email;
  final List<EmergencyContact>? emergencyContacts;
  final String? photoUrl;
  final double? rating;
  final int? ratingCount;
  final double? walletBalance;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // ✅ --- FIX: The missing field has been added ---
  final bool otpRegistered;

  Passenger({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.emergencyContacts,
    this.photoUrl,
    this.rating,
    this.ratingCount,
    this.walletBalance,
    this.status,
    this.createdAt,
    this.updatedAt,
    // ✅ --- FIX: Added to the constructor ---
    this.otpRegistered = false,
  });

  factory Passenger.fromJson(Map<String, dynamic> json) {
    List<EmergencyContact>? parsedEmergencyContacts;
    if (json['emergencyContacts'] is String) {
      try {
        final List<dynamic> decodedList = jsonDecode(json['emergencyContacts']);
        parsedEmergencyContacts = decodedList
            .map((e) => EmergencyContact.fromJson(e))
            .toList();
      } catch (e) {
        parsedEmergencyContacts = null;
      }
    } else if (json['emergencyContacts'] is List) {
      parsedEmergencyContacts = (json['emergencyContacts'] as List)
          .map((e) => EmergencyContact.fromJson(e))
          .toList();
    }

    double? parsedWalletBalance;
    if (json['wallet'] is String) {
      parsedWalletBalance = double.tryParse(json['wallet']);
    } else if (json['wallet'] is num) {
      parsedWalletBalance = (json['wallet'] as num).toDouble();
    } else if (json['wallet'] is Map && json['wallet']['balance'] != null) {
      parsedWalletBalance = (json['wallet']['balance'] as num?)?.toDouble();
    }

    return Passenger(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unnamed User',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      emergencyContacts: parsedEmergencyContacts,
      photoUrl: json['photoUrl'],
      rating: (json['rating'] as num?)?.toDouble(),
      ratingCount:
          (json['rewardPoints'] as num?)?.toInt() ??
          (json['ratingCount'] as num?)?.toInt(),
      walletBalance: parsedWalletBalance,
      status: json['status'],
      createdAt: json.containsKey('createdAt') && json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json.containsKey('updatedAt') && json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      // ✅ --- FIX: Logic to determine if user is OTP-based ---
      // This checks for a specific flag from the backend, but also has a
      // fallback to check if the password field is missing from the JSON.
      otpRegistered: json['otpRegistered'] ?? json['password'] == null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'emergencyContacts': emergencyContacts?.map((e) => e.toJson()).toList(),
      'photoUrl': photoUrl,
      'rating': rating,
      'ratingCount': ratingCount,
      'wallet': {'balance': walletBalance},
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'otpRegistered':
          otpRegistered, // Good practice to include it when serializing
    };
  }

  Passenger copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    List<EmergencyContact>? emergencyContacts,
    String? photoUrl,
    double? rating,
    int? ratingCount,
    double? walletBalance,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? otpRegistered, // ✅ --- FIX: Added to copyWith ---
  }) {
    return Passenger(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
      photoUrl: photoUrl ?? this.photoUrl,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      walletBalance: walletBalance ?? this.walletBalance,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      otpRegistered: otpRegistered ?? this.otpRegistered,
    );
  }
}

class EmergencyContact {
  final String name;
  final String phone;

  EmergencyContact({required this.name, required this.phone});

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name'] ?? 'Unknown',
      phone: json['phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'phone': phone};
  }
}

// --- The rest of the file remains unchanged ---

class RegisterPassengerRequest {
  final String name;
  final String phone;
  final String email;
  final String password;
  final List<EmergencyContact>? emergencyContacts;

  RegisterPassengerRequest({
    required this.name,
    required this.phone,
    required this.email,
    required this.password,
    this.emergencyContacts,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'password': password,
      if (emergencyContacts != null && emergencyContacts!.isNotEmpty)
        'emergencyContacts': emergencyContacts!.map((e) => e.toJson()).toList(),
    };
  }
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}

class UpdatePassengerProfileRequest {
  final String? name;
  final String? phone;
  final String? email;
  final String? password;
  final List<EmergencyContact>? emergencyContacts;
  final String? photoUrl;

  UpdatePassengerProfileRequest({
    this.name,
    this.phone,
    this.email,
    this.password,
    this.emergencyContacts,
    this.photoUrl,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (phone != null) data['phone'] = phone;
    if (email != null) data['email'] = email;
    if (password != null) data['password'] = password;
    if (emergencyContacts != null) {
      data['emergencyContacts'] = emergencyContacts!
          .map((e) => e.toJson())
          .toList();
    }
    if (photoUrl != null) data['photoUrl'] = photoUrl;
    return data;
  }
}

class AuthResponse {
  final String token;
  final Passenger passenger;

  AuthResponse({required this.token, required this.passenger});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      passenger: Passenger.fromJson(json['passenger']),
    );
  }
}

class PassengerSubscription {
  final String subscriptionId;
  final String passengerId;
  final String passengerName;
  final String passengerPhone;
  final String contractType;
  final String pickupLocation;
  final String dropoffLocation;
  final String paymentStatus;
  final String subscriptionStatus;

  PassengerSubscription({
    required this.subscriptionId,
    required this.passengerId,
    required this.passengerName,
    required this.passengerPhone,
    required this.contractType,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.paymentStatus,
    required this.subscriptionStatus,
  });

  factory PassengerSubscription.fromJson(Map<String, dynamic> json) {
    return PassengerSubscription(
      subscriptionId: json['subscription_id'] as String? ?? '',
      passengerId: json['passenger_id'] as String? ?? '',
      passengerName: json['passenger_name'] as String? ?? 'N/A',
      passengerPhone: json['passenger_phone'] as String? ?? 'N/A',
      contractType: json['contract_type'] as String? ?? 'N/A',
      pickupLocation: json['pickup_location'] as String? ?? 'N/A',
      dropoffLocation: json['dropoff_location'] as String? ?? 'N/A',
      paymentStatus: json['payment_status'] as String? ?? 'PENDING',
      subscriptionStatus: json['subscription_status'] as String? ?? 'PENDING',
    );
  }
}
