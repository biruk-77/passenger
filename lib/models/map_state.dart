// lib/models/map_state.dart
enum MapState {
  initial,              // App is just starting up
  discovery,            // Default state: User can see nearby drivers and search
  planning,             // User has selected a destination, viewing routes/prices
  searchingForDriver,   // "Request Ride" pressed, waiting for a match
  driverOnTheWay,       // A driver has accepted the ride
  ongoingTrip,          // Passenger is in the car, heading to the destination
  postTripRating,       // The trip is finished, awaiting a rating
}