import 'package:flutter/material.dart';

class RideOption {
  final String name;
  final IconData icon;
  final double priceMultiplier;

  RideOption({
    required this.name,
    required this.icon,
    required this.priceMultiplier,
  });
}

// Dummy data for the ride options
final List<RideOption> rideOptions = [
  RideOption(
    name: 'Standard',
    icon: Icons.directions_car,
    priceMultiplier: 1.0,
  ),
  RideOption(name: 'Comfort', icon: Icons.local_taxi, priceMultiplier: 1.2),
  RideOption(name: 'XL', icon: Icons.airport_shuttle, priceMultiplier: 1.5),
  RideOption(name: 'Luxury', icon: Icons.star, priceMultiplier: 2.0),
];
