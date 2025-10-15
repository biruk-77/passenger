// lib/models/active_booking_state.dart
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pasenger/utils/enums.dart'; // <-- ADD THIS LINE // <-- FIX: ADD THIS IMPORT LINE
import 'booking.dart';


class ActiveBookingState {
  final Booking booking;

  final MapState mapState; // <-- This will now work correctly
  final List<LatLng> polylinePoints;

  ActiveBookingState({
    required this.booking,

    required this.mapState,
    required this.polylinePoints,
  });
}
