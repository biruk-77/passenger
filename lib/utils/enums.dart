// lib/utils/enums.dart
enum MapPickingMode {
  none,
  setHome,
  setWork,
  addFavorite,
  setDestination,
  setPickup, // Use a dedicated value for picking the start point.
  // Represents the state where the user can choose either start or end.
}

enum MapState {
  discovery,
  planning,
  searchingForDriver,
  driverOnTheWay,
  ongoingTrip,
  postTripRating,
  search, // <-- ADD THIS NEW STATE
  contractSelection, // ✅ ADD: For showing the list of user's subscriptions
  contractRideConfirmation, // ✅ ADD: For confirming the pre-defined ride
  contractRoutePicking,
  contractDriverOnTheWay,

}

// This is the function signature that uses the enum
typedef OnEnterPickingMode = void Function(MapPickingMode mode);

enum AppPanel { discovery, search, locationPreview, routePreview }

enum AppPanelState { open, closed }

enum PaymentMode { manual, automatic }
