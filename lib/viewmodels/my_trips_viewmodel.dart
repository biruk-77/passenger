// FILE: lib/viewmodels/my_trips_viewmodel.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/contract/trip.dart'; // Import your Trip model
import '../utils/api_exception.dart'; // Assuming you have this custom exception

class MyTripsViewModel extends ChangeNotifier {
  final ApiService _apiService;
  final AuthService _authService;

  MyTripsViewModel(this._apiService, this._authService);

  bool _isLoading = false;
  String? _errorMessage;
  List<Trip> _trips = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Trip> get trips => _trips;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> fetchMyTrips() async {
    _setLoading(true);
    setErrorMessage(null);
    try {
      _trips = await _apiService.getMyContractTrips();
      // Optionally, sort trips by date, newest first
      _trips.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } on ApiException catch (e) {
      setErrorMessage("Failed to load trips: ${e.message}");
    } catch (e) {
      setErrorMessage("An unexpected error occurred: $e");
    } finally {
      _setLoading(false);
    }
  }
}