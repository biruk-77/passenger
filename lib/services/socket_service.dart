import 'dart:async';
import 'dart:convert'; // Required for jsonEncode
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../l10n/l10n.dart';
import '../models/vehicle_type.dart';
import '../utils/constants.dart';
import '../utils/logger.dart';
import '../models/socket_models.dart';
import '../models/booking.dart';
import '../models/nearby_driver.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import 'auth_service.dart';

enum SocketConnectionStatus {
  connecting,
  connected,
  disconnected,
  error,
  reconnecting,
}

/// A singleton service responsible for managing all WebSocket communications.
/// This is the central nervous system for all real-time data in the application.
class SocketService {
  static const String _source = "SocketService";
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;

  SocketService._internal(); // Private constructor for the singleton pattern.

  IO.Socket? _socket;
  late ApiService _apiService;
  NotificationService? _notificationService;

  late AuthService _authService;
  Future<bool>? _ongoingRefresh; // coordinate single-flight refresh

  void setAuthService(AuthService authService) {
    _authService = authService;
  }

  // --- PUBLIC DATA STREAMS ---
  // Stream for passenger's own booking request status (initial acknowledgment from server)
  final _bookingRequestedController = StreamController<Booking>.broadcast();
  Stream<Booking> get bookingRequestedStream =>
      _bookingRequestedController.stream;

  final _connectionStatusController =
      StreamController<SocketConnectionStatus>.broadcast();
  Stream<SocketConnectionStatus> get connectionStatusStream =>
      _connectionStatusController.stream;

  final _nearbyDriversController =
      StreamController<List<NearbyDriver>>.broadcast();
  Stream<List<NearbyDriver>> get nearbyDriversStream =>
      _nearbyDriversController.stream;

  final _bookingStatusController =
      StreamController<BookingStatusUpdate>.broadcast();
  Stream<BookingStatusUpdate> get bookingStatusStream =>
      _bookingStatusController.stream;

  // Stream for when a driver *accepts* the booking. This carries the full Booking object.
  final _bookingMatchedController = StreamController<Booking>.broadcast();
  Stream<Booking> get bookingMatchedStream => _bookingMatchedController.stream;

  final _etaUpdateController = StreamController<EtaUpdate>.broadcast();
  Stream<EtaUpdate> get etaUpdateStream => _etaUpdateController.stream;

  final _bookingRatingUpdateController =
      StreamController<BookingRatingUpdate>.broadcast();
  Stream<BookingRatingUpdate> get bookingRatingUpdateStream =>
      _bookingRatingUpdateController.stream;

  final _driverLocationController =
      StreamController<DriverLocationUpdate>.broadcast();
  Stream<DriverLocationUpdate> get driverLocationStream =>
      _driverLocationController.stream;

  final _bookingNoteController = StreamController<BookingNote>.broadcast();
  Stream<BookingNote> get bookingNoteStream => _bookingNoteController.stream;

  final _bookingNotesHistoryController =
      StreamController<List<BookingNote>>.broadcast();
  Stream<List<BookingNote>> get bookingNotesHistoryStream =>
      _bookingNotesHistoryController.stream;

  final _socketErrorController = StreamController<String>.broadcast();
  Stream<String> get socketErrorStream => _socketErrorController.stream;

  final _tripStartedController =
      StreamController<TripStartedUpdate>.broadcast();
  Stream<TripStartedUpdate> get onTripStarted => _tripStartedController.stream;

  final _tripOngoingController =
      StreamController<DriverLocationUpdate>.broadcast();
  Stream<DriverLocationUpdate> get onTripOngoing =>
      _tripOngoingController.stream;

  bool get isConnected => _socket?.connected ?? false;

  void setApiService(ApiService apiService) {
    _apiService = apiService;
  }

  void setNotificationService(NotificationService notificationService) {
    _notificationService = notificationService;
  }

  void connect(String token) {
    if (_socket != null) {
      Logger.info(
        _source,
        "🔌 Previous socket instance found. Forcing disconnect and disposal...",
      );
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null; // Set to null to be certain
    }

    _connectionStatusController.add(SocketConnectionStatus.connecting);
    Logger.info(_source, "🔌 Creating a BRAND NEW socket instance...");

    _socket = IO.io(ApiConstants.socketIOUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'forceNew': true,
      'auth': {'token': token},
    });

    _registerEventListeners();
    _socket!.connect();
  }

  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      Logger.info(_source, "🔌 Socket disconnected.");
    }
  }

  void dispose() {
    Logger.info(_source, "--- 🗑️ DISPOSING SOCKET SERVICE ---");
    _socket?.disconnect();
    _socket?.dispose();
    _connectionStatusController.close();
    _nearbyDriversController.close();
    _bookingStatusController.close();
    _bookingMatchedController.close();
    _driverLocationController.close();
    _bookingNoteController.close();
    _bookingNotesHistoryController.close();
    _socketErrorController.close();
    _etaUpdateController.close();
    _bookingRatingUpdateController.close();
    _tripStartedController.close();
    _tripOngoingController.close();
    _bookingRequestedController.close();
    Logger.success(_source, "✅ Dispose complete. All resources released.");
  }

  // --- MASTER EVENT REGISTRATION ---
  void _registerEventListeners() {
    if (_socket == null) return;

    // --- Connection Lifecycle ---
    _socket!.onConnect((_) {
      Logger.success(
        _source,
        "✅✅✅ [CONNECTED] Socket is live! ID: ${_socket!.id}",
      );
      _connectionStatusController.add(SocketConnectionStatus.connected);
    });
    _socket!.onConnectError((data) {
      Logger.error(_source, "❌❌❌ [CONNECTION ERROR] Failed to connect.", data);
      _connectionStatusController.add(SocketConnectionStatus.error);
      _socketErrorController.add("Connection error: $data");
    });
    _socket!.onDisconnect((reason) {
      Logger.warning(_source, "🔌🔌🔌 [DISCONNECTED] Reason: $reason");
      _connectionStatusController.add(SocketConnectionStatus.disconnected);
    });
    _socket!.on('reconnecting', _handleReconnecting);
    _socket!.on('reconnect', _handleReconnect);
    _socket!.on('reconnect_failed', _handleReconnectFailed);

    // --- Booking Errors ---
    _socket!.on('booking_error', _handleBookingError);
    _socket!.on('auth_error', _handleBookingError); // Per docs
    _socket!.on('booking:no_drivers_available', _handleNoDriversAvailable);

    // --- Booking Creation & Confirmation ---
    _socket!.on('booking:created', _handleBookingCreated); // Per docs
    _socket!.on('booking:joined', (data) {
      // Per docs
      Logger.info(_source, "🚪 Joined booking room: ${jsonEncode(data)}");
    });

    // --- Booking Lifecycle & Updates ---
    // Note: The backend docs say `booking:update` covers all state changes.
    // We listen for specific events here which might still be sent for convenience.
    // The main handler `_handleBookingStatusUpdate` is the primary listener.
    _socket!.on('booking:update', _handleBookingStatusUpdate); // Per docs

    // ✅ FIX: Renamed event to match backend docs ('trip:started')
    _socket!.on('trip:started', _handleTripStarted);

    // ✅ FIX: Renamed event to match backend docs ('trip:ongoing')
    _socket!.on('trip:ongoing', _handleTripOngoing);

    // ✅ FIX: Renamed event to match backend docs ('trip:completed')
    _socket!.on('trip:completed', _handleBookingCompleted);

    _socket!.on('booking:cancelled', _handleBookingCancelled);

    // --- Live Data Feeds ---
    // ✅ FIX: Listening to the single, correct event for live driver location per docs.
    _socket!.on('booking:driver_location', _handleDriverLocationUpdate);

    _socket!.on('booking:ETA_update', _handleEtaUpdate); // Per docs
    _socket!.on('pricing:update', (data) {
      Logger.info(_source, "💰 Pricing update received: ${jsonEncode(data)}");
    });
    _socket!.on('nearby:drivers', _handleNearbyDriversUpdate);

    // --- Chat/Notes ---
    _socket!.on('booking:note', _handleNewBookingNote);
    _socket!.on('booking:notes_history', _handleBookingNotesHistory);

    // --- Other ---
    _socket!.on('booking:status', _handleBookingStatusResponse);
    _socket!.on('booking:rating', _handleBookingRatingUpdate);
    _socket!.on('booking:active_snapshot', _handleBookingStatusResponse);
    Logger.success(
      _source,
      "--- ✅ All socket event listeners registered successfully. ---",
    );
  }

  void _handleReconnecting(dynamic attempt) {
    Logger.info(_source, "--- ⏳ [RECONNECTING] Attempt #${attempt} ---");
    _connectionStatusController.add(SocketConnectionStatus.reconnecting);
  }

  void _handleReconnect(dynamic attempt) {
    Logger.success(
      _source,
      "--- ✅♻️ [RECONNECTED] Successfully reconnected on attempt #${attempt} ---",
    );
    _connectionStatusController.add(SocketConnectionStatus.connected);
  }

  void _handleReconnectFailed(dynamic data) {
    Logger.error(
      _source,
      "--- 🚨♻️ [RECONNECT FAILED] Could not reconnect. --- Data: $data",
    );
    _socketErrorController.add("Failed to reconnect to the server.");
  }

  void _handleBookingError(dynamic data) async {
    const eventName = 'booking_error/auth_error';
    Logger.error(
      _source,
      "--- 🚨 [CAPTURED] Server-side Auth/Booking Error --- Data: ${jsonEncode(data)}",
    );
    String errorMessage = "An unknown booking error occurred.";
    if (data is Map && data.containsKey('message')) {
      errorMessage = data['message'];
    } else if (data is String) {
      errorMessage = data;
    }

    // Try a token refresh before forcing logout
    Logger.warning(
      _source,
      "   L-- Attempting session refresh due to socket auth/booking error...",
    );
    _ongoingRefresh ??= _authService.refreshToken();
    final bool refreshed = await _ongoingRefresh!.whenComplete(() {
      _ongoingRefresh = null;
    });

    if (refreshed) {
      Logger.success(
        _source,
        "   L-- ✅ Session refresh succeeded. Reconnecting socket with new token...",
      );
      final newToken = await _authService.storage.getAccessToken();
      if (newToken != null && newToken.isNotEmpty) {
        connect(newToken);
      } else {
        Logger.error(
          _source,
          "   L-- Refresh returned without a token. Logging out.",
        );
        await _authService.logout(hard: true);
      }
    } else {
      Logger.warning(
        _source,
        "   L-- ❌ Session refresh failed. Logging out to clear invalid session.",
      );
      await _authService.logout(hard: true);
    }

    _socketErrorController.add(errorMessage);
    if (l10n != null && _notificationService != null) {
      _notificationService!.showRideUpdateNotification(
        title: l10n!.notificationBookingErrorTitle,
        body:
            "Your session has expired. Please log in again.", // Provide a clear message
        isOngoing: false,
      );
    }
  }

  void _handleNoDriversAvailable(dynamic data) {
    const eventName = 'booking:no_drivers_available';
    Logger.warning(
      _source,
      "--- 🙅 [CAPTURED] No Drivers Available --- Data: ${jsonEncode(data)}",
    );
    _socketErrorController.add(
      "We couldn't find any drivers nearby. Please try again in a few moments.",
    );
    if (l10n != null && _notificationService != null) {
      _notificationService!.showRideUpdateNotification(
        title: l10n!.notificationNoDriversTitle,
        body: l10n!.notificationNoDriversBody,
        isOngoing: false,
      );
    }
  }

  void _handleBookingCreated(dynamic data) {
    const eventName = 'booking:created';
    Logger.info(
      _source,
      "--- ✨ [CAPTURED] $eventName --- Data: ${jsonEncode(data)}",
    );

    try {
      if (data is! Map<String, dynamic>) {
        throw FormatException("Payload is not a valid JSON object.", data);
      }

      // 1. Parse the incoming data to get the booking details, including the ID.
      final newBooking = Booking.fromJson(data);

      // 2. Stream the new booking object to the UI (e.g., to show "Searching...").
      _bookingRequestedController.add(newBooking);
      Logger.success(
        _source,
        "   L-- ✅ Streamed new Booking ${newBooking.id} to _bookingRequestedController",
      );

      // 3. ✅ NEW: Automatically join the socket room for this specific booking.
      // This ensures we start receiving live updates (like driver location or status changes) immediately.
      joinRideRoom(newBooking.id);
      // 4. Trigger a system notification that the booking request has been received.
      if (l10n != null && _notificationService != null) {
        _notificationService!.showRideUpdateNotification(
          title: l10n!.notificationRequestSentTitle,
          body: l10n!.notificationRequestSentBody,
          payload: newBooking.id,
          imageUrl: VehicleType.genericCarIconUrl,
        );
      }
    } catch (e, s) {
      Logger.error(
        _source,
        "[$eventName] 💥 Booking Created Parsing Failed!",
        e,
        s,
      );
      _socketErrorController.add(
        "Failed to process booking creation confirmation.",
      );
    }
  }

  void _handleTripStarted(dynamic data) {
    // ✅ FIX: Use the correct event name from docs for logging
    const eventName = 'trip:started';
    Logger.info(
      _source,
      "🚀 [CAPTURED] Trip Started --- Data: ${jsonEncode(data)}",
    );

    if (l10n != null && _notificationService != null) {
      _notificationService!.showRideUpdateNotification(
        title: l10n!.notificationTripStartedTitle,
        body: l10n!.notificationTripStartedBody,
        payload: (data is Map) ? data['bookingId'] : null,
        imageUrl: VehicleType.genericCarIconUrl,
      );
    }

    try {
      final update = TripStartedUpdate.fromJson(data);
      _tripStartedController.add(update);
      Logger.success(
        _source,
        "   L-- ✅ Streamed Trip Started for Booking ${update.bookingId}",
      );
    } catch (e, s) {
      Logger.error(_source, "[$eventName] 💥 Parsing Failed!", e, s);
      _socketErrorController.add("Received malformed trip started data.");
    }
  }

  void _handleTripOngoing(dynamic data) {
    // ✅ FIX: Use the correct event name from docs for logging
    const eventName = 'trip:ongoing';
    Logger.info(
      _source,
      "🔄 [CAPTURED] Trip Ongoing --- Data: ${jsonEncode(data)}",
    );
    try {
      if (data != null && data['location'] is Map) {
        final locationData = data['location'] as Map<String, dynamic>;
        final payload = {
          'driverId': null,
          'bookingId': data['bookingId'],
          'latitude': locationData['lat'],
          'longitude': locationData['lng'],
          'bearing': locationData['bearing'],
          'timestamp': locationData['timestamp'],
        };
        final update = DriverLocationUpdate.fromJson(payload);
        _tripOngoingController.add(update);
        Logger.success(
          _source,
          "   L-- ✅ Streamed Trip Ongoing location for Booking ${update.bookingId}",
        );
      } else {
        throw FormatException(
          "Payload or 'location' field is malformed.",
          data,
        );
      }
    } catch (e, s) {
      Logger.error(_source, "[$eventName] 💥 Parsing Failed!", e, s);
      _socketErrorController.add(
        "Received malformed trip ongoing location data.",
      );
    }
  }

  void _handleBookingStatusUpdate(dynamic data) {
    const eventName = 'booking:update';
    Logger.info(
      _source,
      "--- 🔄 [CAPTURED] $eventName --- Data: ${jsonEncode(data)}",
    );
    try {
      // First, do a lightweight parse to check the status field.
      // This is efficient and avoids full parsing if not needed.
      final update = BookingStatusUpdate.fromJson(data);
      final status = update.status.toLowerCase();

      // --- ✅ NEW LOGIC: SPECIAL HANDLING for 'accepted' status ---
      // This is the new entry point for when a driver is matched.
      if (status == 'accepted') {
        Logger.success(
          _source,
          "   L-- 🎉 Driver Matched! Status is 'accepted'.",
        );

        // The payload for 'accepted' is the full Booking object. Parse it.
        final acceptedBooking = Booking.fromJson(data);

        // Join the room to get live location updates for this specific ride.
        joinRideRoom(acceptedBooking.id);

        // Push the complete Booking object to the dedicated stream for the UI.
        _bookingMatchedController.add(acceptedBooking);
        Logger.success(
          _source,
          "   L-- ✅ Streamed full Booking object for ${acceptedBooking.id}",
        );

        // Trigger a system notification that the driver is on the way.
        if (l10n != null && _notificationService != null) {
          final vehicle = VehicleType.fromName(acceptedBooking.vehicleType);
          _notificationService!.showRideUpdateNotification(
            title: l10n!.notificationRideConfirmedTitle,
            body: l10n!.notificationRideConfirmedBody(
              acceptedBooking.assignedDriverName ?? 'Your Driver',
            ),
            payload: acceptedBooking.id,
            imageUrl: vehicle.notificationIconUrl,
          );
        }

        // IMPORTANT: Stop further execution for this specific status.
        return;
      }

      // --- EXISTING LOGIC for all other statuses ---
      // For statuses like 'driver_arrived', 'cancelled', etc., we push the
      // simple update to the generic status stream.
      _bookingStatusController.add(update);
      Logger.success(
        _source,
        "   L-- ✅ Streamed status '$status' for Booking ${update.bookingId}",
      );

      // Handle notifications for other key statuses
      if (l10n != null && _notificationService != null) {
        String? title, body;
        if (status == 'driver_arrived') {
          title = l10n!.notificationDriverArrivedTitle;
          body = l10n!.notificationDriverArrivedBody;
        } else if (status == 'cancelled') {
          title = l10n!.notificationRideCanceledTitle;
          body = l10n!.notificationRideCanceledBody;
        }

        if (title != null && body != null) {
          _notificationService!.showRideUpdateNotification(
            title: title,
            body: body,
            payload: update.bookingId,
            isOngoing: status != 'cancelled',
          );
        }
      }
    } catch (e, s) {
      Logger.error(
        _source,
        "[$eventName] 💥 Status Update Parsing Failed!",
        e,
        s,
      );
      _socketErrorController.add("Received malformed booking status data.");
    }
  }

  void _handleBookingCancelled(dynamic data) {
    const eventName = 'booking:cancelled';
    Logger.warning(
      _source,
      "--- 🚫 [CAPTURED] Booking Cancelled Event --- Data: ${jsonEncode(data)}",
    );

    try {
      if (data is! Map<String, dynamic>) {
        throw FormatException("Payload is not a valid JSON object.", data);
      }
      final update = BookingStatusUpdate.fromJson(data);
      _bookingStatusController.add(update);
      Logger.info(
        _source,
        "   L-- ✅ Streamed cancellation for Booking ${update.bookingId}",
      );

      if (l10n != null && _notificationService != null) {
        _notificationService!.showRideUpdateNotification(
          title: l10n!.notificationRideCanceledTitle,
          body: l10n!.notificationRideCanceledBody,
          payload: update.bookingId,
          isOngoing: false,
        );
      }
    } catch (e, s) {
      Logger.error(
        _source,
        "[$eventName] 💥 Cancellation Event Parsing Failed!",
        e,
        s,
      );
      _socketErrorController.add("Received malformed cancellation data.");
    }
  }

  void _handleNewBookingNote(dynamic data) {
    const eventName = 'booking:note';
    Logger.info(
      _source,
      "--- 💬 [CAPTURED] New Booking Note --- Data: ${jsonEncode(data)}",
    );
    try {
      if (data is! Map<String, dynamic>)
        throw FormatException("Note is not a map.", data);
      final note = BookingNote.fromJson(data);
      final senderName = data['senderName'] ?? '';
      _bookingNoteController.add(note);

      if (note.senderType == 'driver' &&
          l10n != null &&
          _notificationService != null) {
        _notificationService!.showRideUpdateNotification(
          title: l10n!.notificationNewMessageTitle(senderName),
          body: note.message,
          payload: note.bookingId,
          imageUrl: VehicleType.driverIconUrl,
          isOngoing: false,
        );
      }
    } catch (e, s) {
      Logger.error(_source, "[$eventName] 💥 Note Parsing Failed!", e, s);
      _socketErrorController.add("Received malformed booking note data.");
    }
  }

  void _handleBookingNotesHistory(dynamic data) {
    const eventName = 'booking:notes_history';
    Logger.info(
      _source,
      "--- 📚 [CAPTURED] Booking Notes History --- Data: ${jsonEncode(data)}",
    );
    try {
      if (data is! List) throw FormatException("History is not a list.", data);
      final history = data
          .map((noteData) => BookingNote.fromJson(noteData))
          .toList();
      _bookingNotesHistoryController.add(history);
      Logger.success(
        _source,
        "   L-- ✅ Streamed ${history.length} booking notes.",
      );
    } catch (e, s) {
      Logger.error(_source, "[$eventName] 💥 History Parsing Failed!", e, s);
      _socketErrorController.add(
        "Received malformed booking notes history data.",
      );
    }
  }

  void _handleDriverLocationUpdate(dynamic data) {
    // ✅ FIX: Use correct event name for logging
    const eventName = 'booking:driver_location';
    print("\n\n\n\n\n\n👆👆👆👆👆😂⚠️😢😒🚫😆👍😊🌙$data\\n\n\n\n\n\n\n\n\n");
    Logger.info(
      _source,
      "--- 📍 [CAPTURED] Driver Location Update --- Data: ${jsonEncode(data)}",
      verbose: true,
    );
    try {
      if (data is! Map<String, dynamic>) {
        throw FormatException("Payload is not a map.", data);
      }
      final update = DriverLocationUpdate.fromJson(data);
      _driverLocationController.add(update);
      Logger.info(
        _source,
        "   L-- ✅ Streamed driver location for driver ${update.driverId} at ${update.position.latitude}, ${update.position.longitude}",
        verbose: true,
      );
    } catch (e, s) {
      Logger.error(_source, "[$eventName] 💥 Location Parsing Failed!", e, s);
      _socketErrorController.add("Received malformed driver location data.");
    }
  }

  void _handleNearbyDriversUpdate(dynamic data) {
    const eventName = 'nearby:drivers';
    Logger.info(
      _source,
      "--- 🚗 [CAPTURED] Nearby Drivers Update --- Data: ${jsonEncode(data)}",
      verbose: true,
    );
    try {
      if (data is! List) throw FormatException("Payload is not a list.", data);
      final drivers = data.map((d) => NearbyDriver.fromJson(d)).toList();
      _nearbyDriversController.add(drivers);
      Logger.info(
        _source,
        "   L-- ✅ Streamed ${drivers.length} nearby drivers.",
        verbose: true,
      );
    } catch (e, s) {
      Logger.error(_source, "[$eventName] 💥 Parsing Failed!", e, s);
      _socketErrorController.add("Received malformed nearby drivers data.");
    }
  }

  void _handleBookingStatusResponse(dynamic data) {
    const eventName = 'booking:active_snapshot';
    Logger.info(
      _source,
      "--- ℹ️ [CAPTURED] $eventName --- Data: ${jsonEncode(data)}",
    );

    // ✅ --- TEMPORARY DIAGNOSTIC DELAY ---
    // We are adding a 2-second delay here. If this fixes the issue,
    // it confirms that the HomeScreen is initializing too slowly.
    Logger.warning(
      _source,
      "   L-- ⏳ Applying a 5-second diagnostic delay before processing snapshot...",
    );
    Future.delayed(const Duration(seconds: 5), () {
      Logger.info(
        _source,
        "   L-- ✅ Delay finished. Processing active snapshot now.",
      );

      try {
        if (data is! Map<String, dynamic> || data['bookings'] is! List) {
          throw FormatException(
            "Payload is not a map with a 'bookings' list.",
            data,
          );
        }

        final List<dynamic> bookingsList = data['bookings'];

        if (bookingsList.isEmpty) {
          Logger.info(
            _source,
            "   L-- Active booking snapshot is empty. No session to restore.",
          );
          return;
        }

        // Process the first active booking found.
        final activeBookingData = bookingsList.first;

        Logger.success(
          _source,
          "   L-- ✅ Found active booking in snapshot. Processing as a matched booking.",
        );
        final acceptedBooking = Booking.fromJson(activeBookingData);

        joinRideRoom(acceptedBooking.id);

        // This is the stream that HomeScreen listens to.
        _bookingMatchedController.add(acceptedBooking);
      } catch (e, s) {
        Logger.error(
          _source,
          "[$eventName] 💥 Parsing Failed after delay!",
          e,
          s,
        );
        _socketErrorController.add(
          "Received malformed active booking snapshot.",
        );
      }
    });
  }

  void _handleEtaUpdate(dynamic data) {
    const eventName = 'booking:ETA_update';
    Logger.info(
      _source,
      "--- ⏱️ [CAPTURED] ETA Update --- Data: ${jsonEncode(data)}",
    );
    try {
      final update = EtaUpdate.fromJson(data);
      _etaUpdateController.add(update);
      Logger.success(
        _source,
        "   L-- ✅ Streamed ETA update for Booking ${update.bookingId}:  mins.",
      );
    } catch (e, s) {
      Logger.error(_source, "[$eventName] 💥 Parsing Failed!", e, s);
      _socketErrorController.add("Received malformed ETA data.");
    }
  }

  void _handleBookingCompleted(dynamic data) {
    // ✅ FIX: Use correct event name for logging
    const eventName = 'trip:completed';
    Logger.info(
      _source,
      "--- ✅ [CAPTURED] Booking Completed --- Data: ${jsonEncode(data)}",
    );
    try {
      final bookingId = (data['bookingId'] ?? data['id']) as String?;
      if (bookingId == null) {
        throw FormatException(
          "Booking ID is missing in trip_completed event.",
          data,
        );
      }
      _bookingStatusController.add(
        BookingStatusUpdate.fromJson({
          'bookingId': bookingId,
          'status': 'completed',
          'fareFinal': data['amount'],
          'distanceTraveled': data['distance'],
        }),
      );
      Logger.success(
        _source,
        "   L-- ✅ Streamed completion for Booking $bookingId",
      );

      if (l10n != null && _notificationService != null) {
        _notificationService!.showRideUpdateNotification(
          title: l10n!.notificationTripCompletedTitle,
          body: l10n!.notificationTripCompletedBody,
          payload: bookingId,
          imageUrl: VehicleType.genericCarIconUrl,
          isOngoing: false,
        );
      }
    } catch (e, s) {
      Logger.error(_source, "[$eventName] 💥 Parsing Failed!", e, s);
      _socketErrorController.add(
        "Received malformed booking completion event.",
      );
    }
  }

  void _handleBookingRatingUpdate(dynamic data) {
    const eventName = 'booking:rating';
    Logger.info(
      _source,
      "--- ⭐ [CAPTURED] Booking Rating Update --- Data: ${jsonEncode(data)}",
    );
    try {
      final update = BookingRatingUpdate.fromJson(data);
      _bookingRatingUpdateController.add(update);
      Logger.success(
        _source,
        "   L-- ✅ Streamed rating update for Booking ${update.bookingId}: ${update.rating} stars.",
      );
    } catch (e, s) {
      Logger.error(_source, "[$eventName] 💥 Parsing Failed!", e, s);
      _socketErrorController.add("Received malformed rating update.");
    }
  }

  // --- EMIT METHODS (Aligned with backend docs) ---

  void requestBooking({
    required LatLng pickupCoordinates,
    required String pickupAddress,
    required LatLng dropoffCoordinates,
    required String dropoffAddress,
    String? vehicleType,
  }) {
    // ✅ This event name matches the docs
    const eventName = 'booking:request';
    if (!isConnected) {
      _socketErrorController.add("Cannot request ride. Not connected.");
      Logger.error(
        _source,
        "🚨 Cannot emit '$eventName'. Socket is disconnected.",
      );
      return;
    }

    Logger.info(
      _source,
      "--- 🚀 [EMITTING] '$eventName' --- Data: ${jsonEncode({
        'pickup': {'latitude': pickupCoordinates.latitude, 'longitude': pickupCoordinates.longitude, 'address': pickupAddress},
        'dropoff': {'latitude': dropoffCoordinates.latitude, 'longitude': dropoffCoordinates.longitude, 'address': dropoffAddress},
        if (vehicleType != null) 'vehicleType': vehicleType,
      })}",
    );

    debugPrint("🔌 [SOCKET] Sending to backend:");
    debugPrint(
      "🔌 [SOCKET] Pickup: $pickupAddress at ${pickupCoordinates.latitude}, ${pickupCoordinates.longitude}",
    );
    debugPrint(
      "🔌 [SOCKET] Dropoff: $dropoffAddress at ${dropoffCoordinates.latitude}, ${dropoffCoordinates.longitude}",
    );

    final payload = {
      'pickup': {
        'latitude': pickupCoordinates.latitude,
        'longitude': pickupCoordinates.longitude,
        'address': pickupAddress,
      },
      'dropoff': {
        'latitude': dropoffCoordinates.latitude,
        'longitude': dropoffCoordinates.longitude,
        'address': dropoffAddress,
      },
      if (vehicleType != null) 'vehicleType': vehicleType,
    };
    debugPrint("payload: $payload");
    _socket!.emit(eventName, payload);
    Logger.info(
      _source,
      "--- 🚀 [EMITTED] '$eventName' --- Data: ${jsonEncode(payload)}",
    );
  }

  void cancelBooking({required String bookingId, String? reason}) {
    // ✅ This event name matches the docs
    const eventName = 'booking:cancel';
    if (!isConnected) {
      _socketErrorController.add("Cannot cancel ride. Not connected.");
      Logger.error(
        _source,
        "🚨 Cannot emit '$eventName'. Socket is disconnected.",
      );
      return;
    }
    final payload = {
      'bookingId': bookingId,
      if (reason != null) 'reason': reason,
    };
    _socket!.emit(eventName, payload);
    Logger.info(
      _source,
      "--- 🚫 [EMITTED] '$eventName' for $bookingId --- Data: ${jsonEncode(payload)}",
    );
  }

  void sendBookingNote({required String bookingId, required String message}) {
    const eventName = 'booking_note';
    if (!isConnected) return;
    final payload = {'bookingId': bookingId, 'message': message};
    _socket!.emit(eventName, payload);
    Logger.info(
      _source,
      "--- 💬 [EMITTED] '$eventName' --- Data: ${jsonEncode(payload)}",
    );
  }

  void fetchBookingNotes({required String bookingId}) {
    const eventName = 'booking_notes_fetch';
    if (!isConnected) return;
    final payload = {'bookingId': bookingId};
    _socket!.emit(eventName, payload);
    Logger.info(
      _source,
      "--- 📚 [EMITTED] '$eventName' --- Data: ${jsonEncode(payload)}",
    );
  }

  void startNearbyDriverUpdates(LatLng location) {
    const eventName = 'nearby:subscribe';
    if (!isConnected) return;
    final payload = {
      'latitude': location.latitude,
      'longitude': location.longitude,
    };
    _socket!.emit(eventName, payload);
    Logger.info(
      _source,
      "--- 📡 [EMITTED] '$eventName' --- Data: ${jsonEncode(payload)}",
    );
  }

  void stopNearbyDriverUpdates() {
    const eventName = 'nearby:unsubscribe';
    if (!isConnected) return;
    _socket!.emit(eventName);
    Logger.info(_source, "--- 📡 [EMITTED] '$eventName' ---");
  }

  void joinRideRoom(String bookingId) {
    // ✅ This event name matches the docs
    const eventName = 'booking:join_room';
    if (!isConnected || bookingId.isEmpty) return;
    final payload = {'bookingId': bookingId};
    _socket!.emit(eventName, payload);
    Logger.info(
      _source,
      "--- 🚪 [EMITTED] '$eventName' for booking $bookingId --- Data: ${jsonEncode(payload)}",
    );
  }

  void pushPassengerLocation(LatLng location, {String? bookingId}) {
    const eventName = 'passenger:location';
    if (!isConnected) return;
    final payload = {
      'latitude': location.latitude,
      'longitude': location.longitude,
      if (bookingId != null) 'bookingId': bookingId,
    };
    _socket!.emit(eventName, payload);
    Logger.info(
      _source,
      "--- 📍 [EMITTED] '$eventName' --- Data: ${jsonEncode(payload)}",
      verbose: true,
    );
  }

  void requestBookingStatus({required String bookingId}) {
    // ✅ This event name matches the docs
    const eventName = 'booking:status_request';
    if (!isConnected) return;
    _socket!.emit(eventName, {'bookingId': bookingId});
    Logger.info(_source, "--- ❓ [EMITTED] '$eventName' for $bookingId ---");
  }
}
