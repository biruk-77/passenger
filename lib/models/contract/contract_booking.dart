//lib/models/contract/contract_booking.dart
import 'driver.dart';

// This is the new, independent model for a contract ride in progress.
class ContractBooking {
  final String id;
  final String subscriptionId;
  final String status;
  final AssignedDriver assignedDriver;

  ContractBooking({
    required this.id,
    required this.subscriptionId,
    required this.status,
    required this.assignedDriver,
  });

  // A factory to create this object from the two API calls we make
  factory ContractBooking.create({
    required String bookingId,
    required String subscriptionId,
    required String status,
    required AssignedDriver driverDetails,
  }) {
    return ContractBooking(
      id: bookingId,
      subscriptionId: subscriptionId,
      status: status,
      assignedDriver: driverDetails,
    );
  }
}
