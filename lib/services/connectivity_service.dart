// lib/services/connectivity_service.dart
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  // Provide a stream of connectivity changes
  Stream<ConnectivityResult> get connectionStream =>
      _connectivity.onConnectivityChanged;

  // Check the current status
  Future<ConnectivityResult> get currentStatus async =>
      await _connectivity.checkConnectivity();
}
