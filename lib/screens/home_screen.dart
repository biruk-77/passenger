// lib/screens/home_screen.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:animate_do/animate_do.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/contract/contract_ride.dart'; // ✅ ADD THIS IMPORT
import 'passenger/create_subscription_screen.dart'; // ✅ ADD THIS IMPORT
import '../l10n/app_localizations.dart';
import '../models/active_booking_state.dart';
import '../models/booking.dart';
import '../models/location.dart';
import '../models/nearby_driver.dart';
// Add this import to home_screen.dart
import '../models/contract/driver.dart' as driver_model;
import '../models/passenger.dart';
import '../models/pricing_rule.dart';
import '../models/route.dart';
import '../models/route_details.dart';
import '../models/search_result.dart';
import '../models/socket_models.dart';
import '../models/vehicle_type.dart';
import '../models/contract/contract_booking.dart';
import '../models/contract/trip.dart';

import '../providers/saved_places_provider.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/google_maps_service.dart';
import '../services/notification_service.dart';
import '../services/socket_service.dart';
import '../theme/color.dart';
import '../utils/api_exception.dart';
import '../utils/constants.dart';
import '../utils/enums.dart';
import '../utils/logger.dart';
import '../utils/map_style.dart';
import '../utils/nearby_driver_simulator_manager.dart';
import '../widgets/advanced_driver_info_window.dart';
import '../widgets/app_drawer.dart';
import '../widgets/radius_slider.dart';
import '../utils/nearby_driver_simulator_manager.dart';
// Screen Imports
import 'edit_profile_screen.dart';
import 'history_screen/history.dart';
import 'offline_sms_screen.dart';
import 'passenger_login_screen.dart';

// Panel Widget Imports
import '../widgets/home_screen_panels/discovery_panel.dart';
import '../widgets/home_screen_panels/driver_on_the_way_panel.dart';
import '../widgets/home_screen_panels/ongoing_trip_panel.dart';
import '../widgets/home_screen_panels/planning_panel.dart';
import '../widgets/home_screen_panels/post_trip_rating_panel.dart';
import '../widgets/home_screen_panels/search_panel.dart';
import '../widgets/home_screen_panels/searching_panel.dart';
import '../widgets/home_screen_panels/contract_mode_panel.dart';
import '../widgets/home_screen_panels/contract_ride_confirmation_panel.dart';
import '../widgets/home_screen_panels/contract_driver_on_the_way_panel.dart';
import '../widgets/home_screen_panels/contract_location_picker_panel.dart';

import '../widgets/location_preview_panel.dart';
import 'passenger/my_subscriptions_screen.dart';

class HomeScreen extends StatefulWidget {
  final SearchResult? initialRoute;
  const HomeScreen({super.key, this.initialRoute});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();
  late ApiService _apiService;
  late AuthService _authService;
  late SocketService _socketService;
  bool _isInitialized = false;
  StreamSubscription? _bookingRequestedSubscription;
  final GoogleMapsService _googleMapsService = GoogleMapsService(
    apiKey: ApiConstants.googleApiKey,
  );
  MapState _currentMapState = MapState.discovery;
  double? _finalFare;
  double? _finalDistanceKm;
  final Duration _passengerLocationPushInterval = const Duration(seconds: 10);
  NearbyDriverSimulatorManager? _nearbyDriverSimulatorManager;
  Map<String, FareEstimate> _fareEstimates = {};
  // --- State Variables ---
  Passenger? _passengerProfile;
  Contract? _selectedContractForCreation;
  String _contractPickStage = 'pickup';
  MapType _currentMapType = MapType.normal;
  LatLng? _startPoint;
  LatLng? _destinationPoint;
  String _startAddress = "Current Location";
  String _destinationAddress = "";
  Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  List<NearbyDriver> _nearbyDrivers = [];
  PlaceDetails? _startPlace;
  PlaceDetails? _endPlace;
  String _fieldBeingSet = 'start';
  String? _currentMapStyle = lightMapStyle;
  List<Contract> _availableContracts = [];
  bool _isLoadingContracts = false;
  String? _contractsError;
  Subscription? _selectedSubscription;
  BitmapDescriptor? _carIcon;
  bool _isMapLoading = true;
  bool _isLoadingProfile = true;
  String? _profileErrorMessage;
  String _estimatedTime = "";
  String _estimatedDistance = "";
  static const MethodChannel _smsChannel = MethodChannel(
    'com.dailytransport.pasenger/sms',
  );
  int _selectedRideOptionIndex = 0;
  List<VehicleType> _vehicleTypes = [];
  bool _isLoadingRideOptions = false;
  MapPickingMode _pickingMode = MapPickingMode.none;
  String? _mapPickFieldToFill;
  String? _rideOptionsError;
  // This will hold the details of the location the user tapped on the map.
  PlaceDetails? _tappedPlaceDetails;
  ContractBooking? _activeContractBooking;
  // A temporary marker to show the user where they tapped.
  Marker? _tappedPointMarker;
  bool _isBooking = false;
  String? _currentBookingId;
  Booking? _activeBooking;
  NearbyDriver? _assignedDriverDetails;
  Map<String, dynamic>? _assignedVehicleDetails;
  LatLng? _driverPosition;
  String _etaToPickup = "...";
  AnimationController? _markerAnimationController;
  LatLng? _lastMarkerPosition;
  double? _lastMarkerBearing;
  StreamSubscription<Position>? _passengerLocationSubscription;
  DateTime? _lastPassengerLocationPush;
  bool _isPanelVisible = false;
  double _searchRadiusKm = 1.0;
  bool _isContractTripOngoing = false;
  Animation<double>? _pulseAnimation;
  static const LatLng _addisAbabaCenter = LatLng(9.02497, 38.74689);
  StreamSubscription? _nearbyDriversSubscription;
  StreamSubscription? _bookingStatusSubscription;
  StreamSubscription? _driverLocationSubscription;
  StreamSubscription? _bookingMatchedSubscription;
  StreamSubscription? _socketErrorSubscription;
  List<BookingNote> _bookingNotes = [];
  StreamSubscription? _bookingNoteSubscription;
  StreamSubscription? _bookingNotesHistorySubscription;
  StreamSubscription? _tripStartedSubscription;
  StreamSubscription? _tripOngoingSubscription;
  bool _isMapMoving = false;
  bool _showContactDriverPanel = false;
  double _selectedTipAmount = 0.0;
  final Set<String> _selectedFeedbackTags = {};
  // ✅ ADD THESE STREAM SUBSCRIPTIONS
  StreamSubscription? _etaSubscription;
  StreamSubscription? _ratingSubscription;
  String? _errorMessage;
  final ValueNotifier<NearbyDriver?> _selectedDriverNotifier = ValueNotifier(
    null,
  );
  PlaceDetails? _unconfirmedTappedPlace;
  Timer? _infoWindowDismissTimer;
  double _postTripRating = 5.0;
  final TextEditingController _postTripCommentController =
      TextEditingController();
  String _etaToDestination = "...";
  bool _isRatingSubmitting = false;

  final Map<int, bool> _proximityAlertsTriggered = {
    100: false,
    50: false,
    20: false,
    10: false,
    0: false,
  };
  @override
  void initState() {
    super.initState();
    // Animation controllers are context-independent and can be initialized here.

    // _locationPulseController.repeat();

    // REMOVED _loadUserProfile() call from here to prevent duplicate network requests.
    // Initialization is now handled entirely in _initializeHomeScreen.

    _markerAnimationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(
            reverse: true,
          ); // This is for the driver marker, let's reuse for pulse

    _pulseAnimation = CurvedAnimation(
      parent: _markerAnimationController!,
      curve: Curves.easeInOut,
    );
  }

  late final NotificationService _notificationService;
  // This method is your hero. It connects the services.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _apiService = Provider.of<ApiService>(context, listen: false);
      _authService = Provider.of<AuthService>(context, listen: false);
      _socketService = Provider.of<SocketService>(context, listen: false);
      _socketService.setApiService(_apiService);
      _nearbyDriverSimulatorManager = NearbyDriverSimulatorManager(
        googleMapsService: _googleMapsService,
        onDriversUpdated: (drivers) {
          if (!mounted || _currentMapState != MapState.discovery) return;
          // This callback receives the list of moving drivers
          setState(() {
            _nearbyDrivers = drivers;
          });
          // We don't call _updateMarkers() here because it's called
          // by the build method, which is triggered by setState.
        },
      );
      _initializeHomeScreen();

      _notificationService = Provider.of<NotificationService>(
        context,
        listen: false,
      );
      _isInitialized = true;
    }
  }
  // lib/screens/home_screen.dart -> dispose()

  @override
  void dispose() {
    // --- REPLACE the entire old dispose method body with this ---
    _nearbyDriversSubscription?.cancel();
    _bookingStatusSubscription?.cancel();
    _driverLocationSubscription?.cancel();
    _bookingMatchedSubscription?.cancel();
    _socketErrorSubscription?.cancel();
    _passengerLocationSubscription?.cancel();
    _etaSubscription?.cancel();
    _ratingSubscription?.cancel();
    _bookingNoteSubscription?.cancel();
    _bookingNotesHistorySubscription?.cancel();

    _markerAnimationController?.dispose();
    _postTripCommentController.dispose();
    _infoWindowDismissTimer?.cancel();
    _selectedDriverNotifier.dispose();
    _bookingRequestedSubscription?.cancel();
    _nearbyDriverSimulatorManager?.stop();

    super.dispose();
  }

  /// Starts polling for nearby drivers. This is called when the map is in the discovery state.
  // In lib/screens/home_screen.dart -> _HomeScreenState

  // In lib/screens/home_screen.dart -> _HomeScreenState class
  void _initializeSocketListeners() {
    // -------------------------------------------------------------------------
    // ðŸŽ§ STEP 1: PRE-FLIGHT CHECK
    // -------------------------------------------------------------------------
    // Before we do anything, let's confirm the state of our services.
    // This helps debug initialization order problems.
    // -------------------------------------------------------------------------
    Logger.info("HomeScreen", "--- ðŸš¦ Initializing Socket Listeners ---");

    if (!_socketService.isConnected) {
      Logger.warning(
        "HomeScreen",
        "   L-- âš ï¸  WARNING: Socket is not connected yet. Listeners will attach, but may not receive data until connection is established.",
      );
    } else {
      Logger.success(
        "HomeScreen",
        "   L-- âœ… Socket is already connected. Proceeding to bind listeners.",
      );
    }

    if (_isInitialized == false) {
      Logger.warning(
        "HomeScreen",
        "   L-- âš ï¸  WARNING: HomeScreen reports it is not fully initialized. This might be a race condition.",
      );
    }

    // --- ðŸš— Booking Requested Listener ---
    _bookingRequestedSubscription = _socketService.bookingRequestedStream.listen(
      (booking) {
        if (!mounted) return;
        Logger.info(
          "HomeScreen",
          "   L-- ðŸš— [SOCKET EVENT] Ride request confirmed by server. Booking ID: ${booking.id}",
        );
        // This is the crucial step that was missing.
        // We now have the booking ID before the driver accepts.
        setState(() {
          _currentBookingId = booking.id;
        });
      },
      onError: (error) {
        if (!mounted) return;
        Logger.error(
          "HomeScreen",
          "   L-- ðŸš¨ [STREAM ERROR] in 'bookingRequestedStream'",
          error,
        );
        _showErrorSnackBar("A real-time error occurred with ride requests.");
      },
    );

    // --- ðŸš— Nearby Driver Updates Listener ---
    _nearbyDriversSubscription = _socketService.nearbyDriversStream.listen(
      (driverData) {
        // Add a mounted check as the first line in every listener
        if (!mounted) return;

        Logger.info(
          "HomeScreen",
          "   L-- ðŸš— [SOCKET EVENT] Received 'nearbyDriversUpdate'. Processing...",
        );
        // ... rest of your existing logic for this listener
        if (_currentMapState != MapState.discovery) return;
        // ...
      },
      onError: (error) {
        if (!mounted) return;
        Logger.error(
          "HomeScreen",
          "   L-- ðŸš¨ [STREAM ERROR] in 'nearbyDriversStream'",
          error,
        );
        _showErrorSnackBar("A real-time error occurred with driver updates.");
      },
    );
    Logger.success(
      "HomeScreen",
      "   L-- âœ… Listener attached for 'nearbyDriversUpdate'.",
    );

    // --- ðŸ”” Booking Status Change Listener ---
    _bookingStatusSubscription = _socketService.bookingStatusStream.listen(
      (update) {
        if (!mounted) return;
        Logger.info(
          "HomeScreen",
          "   L-- ðŸ”” [SOCKET EVENT] Received 'bookingStatusChanged' to '${update.status}'.",
        );
        if (update.bookingId != _currentBookingId) return;
        _handleBookingStatusUpdate(update);
      },
      onError: (error) {
        if (!mounted) return;
        Logger.error(
          "HomeScreen",
          "   L-- ðŸš¨ [STREAM ERROR] in 'bookingStatusStream'",
          error,
        );
        _showErrorSnackBar("A real-time error occurred with booking status.");
      },
    );
    Logger.success(
      "HomeScreen",
      "   L-- âœ… Listener attached for 'bookingStatusChanged'.",
    );

    // --- ðŸŽ‰ Ride Accepted / Driver Matched Listener ---
    _bookingMatchedSubscription = _socketService.bookingMatchedStream.listen(
      (acceptedBooking) {
        // <-- It receives the full Booking object directly
        if (!mounted) return;
        Logger.success(
          "HomeScreen",
          "   😒😒😒😒😒😒 [SOCKET EVENT] Received 'booking:accepted' for booking ${acceptedBooking}! Processing...",
        );
        // It correctly calls your existing handler with the full, parsed data.
        // No extra API call is needed!
        _handleDriverAssigned(acceptedBooking);
      },
      onError: (error) {
        if (!mounted) return;
        Logger.error(
          "HomeScreen",
          "   L-- ðŸš¨ [STREAM ERROR] in 'bookingMatchedStream'",
          error,
        );
        _showErrorSnackBar("An error occurred while assigning your driver.");
        _resetMapState(); // Reset state on error
      },
    );
    Logger.success(
      "HomeScreen",
      "   L-- âœ… Listener attached for 'booking:accepted'.",
    );
    // In lib/screens/home_screen.dart -> _initializeSocketListeners()

    // --- ðŸ“  Live Driver Location Listener (High-End Error Handling Version) ---
    _driverLocationSubscription = _socketService.driverLocationStream.listen(
      (update) {
        // 🛰️ Incoming update
        Logger.info(
          "HomeScreen",
          "📡 [INCOMING] Driver Location Update: driverId=${update.driverId}, pos=${update.position}, bearing=${update.bearing}",
        );

        // 🚫 Guard 1: Empty driverId
        if (update.driverId.isEmpty) {
          Logger.warning(
            "HomeScreen",
            "⚠️ [IGNORED] Received location update with an EMPTY driverId. Data: $update",
          );
          return;
        }

        // ✅ Case 1: Assigned driver updates
        if (_assignedDriverDetails != null &&
            update.driverId == _assignedDriverDetails!.id) {
          try {
            setState(() {
              _driverPosition = update.position;
              _lastMarkerPosition = update.position;
              _lastMarkerBearing = update.bearing;

              _updateSingleMarker(
                'driver-${_assignedDriverDetails!.id}',
                update.position,
                update.bearing,
              );

              if (_currentMapState == MapState.driverOnTheWay &&
                  _startPoint != null) {
                _drawPolyline(
                  'driver_to_pickup',
                  update.position,
                  _startPoint!,
                  Colors.blueAccent,
                );
                _animateCameraToFitBounds(update.position, _startPoint!);
                Logger.success(
                  "HomeScreen",
                  "✅ [ROUTE] Updated polyline: driver ➝ pickup",
                );
              } else if (_currentMapState == MapState.ongoingTrip &&
                  _destinationPoint != null) {
                _drawPolyline(
                  'ongoing_trip',
                  update.position,
                  _startPoint!,
                  Colors.deepPurple,
                );
                _animateCameraToFitBounds(update.position, _startPoint!);
                Logger.success(
                  "HomeScreen",
                  "✅ [ROUTE] Updated polyline: driver ➝ destination",
                );
              } else {
                Logger.info(
                  "HomeScreen",
                  "ℹ️ [NO-POLYLINE] State=$_currentMapState. Skipped drawing.",
                );
              }
            });

            _checkDriverProximity(update.position);
          } catch (e, st) {
            Logger.error(
              "HomeScreen",
              "🚨 [ERROR] Failed to update assigned driver location",
              e,
              st,
            );
          }
          return;
        }
        if (_currentMapState == MapState.driverOnTheWay) {
          _checkDriverProximity(update.position);
        }

        // ✅ Case 2: Discovery mode → update nearby drivers
        if (_currentMapState == MapState.discovery) {
          try {
            setState(() {
              final driverIndex = _nearbyDrivers.indexWhere(
                (d) => d.id == update.driverId,
              );

              if (driverIndex != -1) {
                final oldDriver = _nearbyDrivers[driverIndex];
                final updatedDriver = NearbyDriver(
                  id: oldDriver.id,
                  name: oldDriver.name,
                  position: update.position,
                  bearing: update.bearing,
                  vehicleType: oldDriver.vehicleType,
                  available: oldDriver.available,
                  photoUrl: oldDriver.photoUrl,
                  rating: oldDriver.rating,
                  phone: oldDriver.phone,
                );

                _nearbyDrivers[driverIndex] = updatedDriver;
                _updateMarkers();

                Logger.success(
                  "HomeScreen",
                  "✅ [UPDATED] Nearby driver ${update.driverId} position refreshed.",
                );
              } else {
                Logger.info(
                  "HomeScreen",
                  "👻 [RACE] Received location for unknown driver '${update.driverId}'. Ignored safely.",
                );
              }
            });
          } catch (e, st) {
            Logger.error(
              "HomeScreen",
              "🚨 [ERROR] Failed to update nearby driver markers",
              e,
              st,
            );
          }
          return;
        }

        // ⚠️ Case 3: Irrelevant states
        Logger.warning(
          "HomeScreen",
          "⚠️ [IGNORED] Location update for driver '${update.driverId}' during state=$_currentMapState. No action taken.",
        );
      },
      onError: (error, stackTrace) {
        Logger.error(
          "HomeScreen",
          "🚨 [FATAL] Driver Location Stream crashed!",
          error,
          stackTrace,
        );
        if (mounted) {
          _showErrorSnackBar(
            "🔥 Real-time error: Driver locations may not update.",
          );
        }
      },
      onDone: () {
        Logger.warning(
          "HomeScreen",
          "⚠️ [DONE] Driver Location Stream closed unexpectedly!",
        );
      },
      cancelOnError: false,
    );

    Logger.success(
      "HomeScreen",
      "✅ Listener attached for driver location updates.",
    );

    _etaSubscription = _socketService.etaUpdateStream.listen(
      (update) {
        if (!mounted || update.bookingId != _currentBookingId) return;

        setState(() {
          // ✅ FIX: This now works perfectly because the model is correct.
          // We are displaying the exact "8 m mins" string from the server.
          _etaToPickup = update.etaText;
        });

        Logger.info(
          "HomeScreen",
          "ETA updated to '${update.etaText}' for booking ${update.bookingId}",
        );
      },
      onError: (error) {
        // Log the error to see if parsing fails for any reason
        Logger.error("HomeScreen", "Error in ETA stream subscription", error);
        if (mounted) _showErrorSnackBar("Error receiving ETA updates.");
      },
    );
    _tripStartedSubscription = _socketService.onTripStarted.listen(
      (update) {
        if (!mounted || update.bookingId != _currentBookingId) return;

        Logger.success(
          "HomeScreen",
          "🚀 [SOCKET EVENT] Trip has started for booking ${update.bookingId}!",
        );

        // First, update the app's state to reflect that the trip is ongoing.
        setState(() {
          _currentMapState = MapState.ongoingTrip;
        });

        // CRITICAL FIX:
        // The 'trip:started' event doesn't contain the driver's location.
        // So, we use the most recent `_driverPosition` we have in our state.
        // This value was updated just moments ago by the 'driver:location_update' event.
        if (_driverPosition != null && _destinationPoint != null) {
          // Now, with the guaranteed latest position, calculate the initial ETA.
          _updateLiveEta(_driverPosition!);

          // Clean up the old polyline from pickup.
          _polylines.removeWhere(
            (p) => p.polylineId.value == 'driver_to_pickup',
          );

          // Draw the new polyline for the ongoing trip.
          _drawPolyline(
            'ongoing_trip',
            _driverPosition!,
            _destinationPoint!,
            Colors.deepPurple,
          );

          // Animate the camera to fit the new route.
          _animateCameraToFitBounds(_driverPosition!, _destinationPoint!);

          // Send a notification to the user.
        }
      },

      onError: (error) => Logger.error(
        "HomeScreen",
        "🚨 [STREAM ERROR] in 'onTripStarted'",
        error,
      ),
    );
    _tripOngoingSubscription = _socketService.onTripOngoing.listen(
      (update) {
        if (!mounted || update.bookingId != _currentBookingId) return;

        // This is the core logic for moving the car
        if (_assignedDriverDetails != null) {
          setState(() {
            _driverPosition = update.position;
            _lastMarkerPosition = update.position;
            _lastMarkerBearing = update.bearing;

            _updateSingleMarker(
              'driver-${_assignedDriverDetails!.id}',
              update.position,
              update.bearing,
            );

            if (_destinationPoint != null) {
              _drawPolyline(
                'ongoing_trip',
                update.position,
                _startPoint!,
                Colors.deepPurple,
              );
            }
          });
        }
      },
      onError: (error) {
        Logger.error(
          "HomeScreen",
          "🚨 [STREAM ERROR] in 'onTripOngoing'",
          error,
        );
      },
    );
    _ratingSubscription = _socketService.bookingRatingUpdateStream.listen(
      (update) {
        if (!mounted) return;
        // This is mostly for confirmation, as the UI resets immediately after sending.
        Logger.success(
          "HomeScreen",
          "Rating confirmed by server for booking ${update.bookingId}",
        );
      },
      onError: (error) {
        if (mounted) _showErrorSnackBar("Error with rating confirmation.");
      },
    );
    _bookingNoteSubscription = _socketService.bookingNoteStream.listen(
      (note) {
        if (!mounted || note.bookingId != _currentBookingId) return;
        setState(() {
          // Add the new note to the end of the list
          _bookingNotes.add(note);
        });
        Logger.info("HomeScreen", "💬 New chat message received!");
      },
      onError: (e) {
        Logger.error("HomeScreen", "Error on bookingNoteStream", e);
      },
    );

    _bookingNotesHistorySubscription = _socketService.bookingNotesHistoryStream.listen(
      (history) {
        if (!mounted) return;
        // The first item in history is the bookingId, which we can ignore here
        // The payload is { bookingId: "...", notes: [...] }
        // We need to extract the notes list. Let's assume the model is corrected or
        // that the stream provides List<BookingNote>
        setState(() {
          _bookingNotes = history;
        });
        Logger.info(
          "HomeScreen",
          "📚 Chat history loaded with ${history.length} messages.",
        );
      },
      onError: (e) {
        Logger.error("HomeScreen", "Error on bookingNotesHistoryStream", e);
      },
    );

    _bookingNotesHistorySubscription?.pause();
    _bookingNotesHistorySubscription?.resume();
  }

  void _startNewContractCreationFlow(Contract contract) {
    setState(() {
      // Store the contract that we are creating a subscription for.
      _selectedContractForCreation = contract;

      // CRITICAL: Switch the state to show the standard SearchPanel.
      _currentMapState = MapState.contractRoutePicking;
      _isPanelVisible = true; // Make sure the panel is visible

      // Clear any previous route planning data.
      _startPlace = null;
      _endPlace = null;
      _startPoint = null;
      _destinationPoint = null;
      _polylines.clear();
      _updateMarkers();
    });

    _showSuccessSnackBar("Select your pickup location on the map.");
  }

  Future<void> _contactDriverViaSms() async {
    // 1. Guard against missing driver details
    if (_assignedDriverDetails?.phone == null ||
        _assignedDriverDetails!.phone!.isEmpty) {
      _showErrorSnackBar("Driver's phone number is not available.");
      return;
    }
    final String driverPhone = _assignedDriverDetails!.phone!;

    // 2. Check for SMS permission
    final status = await Permission.sms.request();
    if (!status.isGranted) {
      _showErrorSnackBar('SMS permission is required to contact the driver.');
      return;
    }

    // 3. Show a confirmation dialog to the user
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Contact Driver via SMS"),
        content: Text(
          "This will send a standard SMS message to your driver at $driverPhone. Standard messaging rates may apply.",
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text("Send SMS"),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    // 4. If confirmed, send the SMS via the platform channel
    if (confirm == true) {
      try {
        // You can customize this message as needed
        const String messageBody =
            "Hello, this is your passenger. I'm trying to reach you regarding our ride.";

        await _smsChannel.invokeMethod<void>('sendSms', {
          'phone': driverPhone,
          'message': messageBody,
        });

        _showSuccessSnackBar("SMS sent to the driver.");
      } on PlatformException catch (e) {
        _showErrorSnackBar('Failed to send SMS (Code: ${e.code}).');
      } catch (e) {
        _showErrorSnackBar(
          'An unexpected error occurred while sending the SMS.',
        );
      }
    }
  }

  Future<PlaceDetails> _getPlaceDetailsFromTap(LatLng position) async {
    try {
      final address = await _googleMapsService.getAddressFromCoordinates(
        position,
        useNearbySearch: true, // ✅ Use nearby search for map taps
      );
      return PlaceDetails(
        primaryText: address.name,
        secondaryText: address.fullAddress,
        coordinates: position,
        placeId: 'map_tapped_${position.latitude}_${position.longitude}',
      );
    } catch (e) {
      // Fallback if the address lookup fails
      return PlaceDetails(
        primaryText: 'Selected Location',
        secondaryText:
            'Coordinates: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
        coordinates: position,
        placeId: 'map_tapped_${position.latitude}_${position.longitude}',
      );
    }
  }

  Future<void> _updateLiveEta(LatLng driverPosition) async {
    if (!mounted) return;

    // --- Case 1: Driver is on the way to PICKUP ---
    if (_currentMapState == MapState.driverOnTheWay && _startPoint != null) {
      try {
        final RouteDetails? routeDetails = await _googleMapsService
            .getDirectionsInfo(driverPosition, _startPoint!);
        if (routeDetails != null && mounted) {
          setState(() => _etaToPickup = routeDetails.durationText);
        }
      } catch (e) {
        Logger.warning("HomeScreen", "Failed to calculate ETA to pickup");
      }
    }
    // --- Case 2: Trip is ONGOING to DESTINATION ---
    else if (_currentMapState == MapState.ongoingTrip &&
        _destinationPoint != null) {
      try {
        final RouteDetails? routeDetails = await _googleMapsService
            .getDirectionsInfo(driverPosition, _destinationPoint!);
        if (routeDetails != null && mounted) {
          setState(() => _etaToDestination = routeDetails.durationText);
        }
      } catch (e) {
        Logger.warning("HomeScreen", "Failed to calculate ETA to destination");
      }
    }
  }

  void _navigateToOfflineSmsScreen() {
    _nearbyDriverSimulatorManager?.stop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OfflineSmsScreen(), // <-- CORRECTED LINE
      ),
    );
  }

  Future<void> _findCurrentUserLocation() async {
    try {
      // 1. Check if location services are enabled on the device.
      print("ðŸ›°ï¸   Checking if location services are enabled...");
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled && mounted) {
        print("ðŸš« Location services are disabled.");
        _showErrorSnackBar(
          "Location services are disabled. Please enable them.",
        );
        setState(() => _startPoint = _addisAbabaCenter); // Use fallback
        return;
      }

      print("ðŸ‘  Location services are enabled.");

      // 2. Check and request permissions.
      if (!(await _requestLocationPermission())) {
        print("ðŸš« Location permission was denied.");
        setState(() => _startPoint = _addisAbabaCenter); // Use fallback
        return;
      }
      print("ðŸ‘  Location permission granted.");

      // 3. Get location with a timeout.
      print("ðŸŒ  Attempting to get current location (10s timeout)...");
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 20));

      print(
        "âœ… Location found: ${jsonEncode({'latitude': position.latitude, 'longitude': position.longitude, 'bearing': 45.0})}",
      );
      if (mounted) {
        // CRITICAL: This ONLY updates the state variable. No map interaction here.
        setState(() {
          _startPoint = LatLng(position.latitude, position.longitude);
        });
        print("ðŸ“  State updated with new start point: $_startPoint");
      }
    } on TimeoutException {
      print("â ³â Œ ERROR: Location request timed out after 10 seconds.");
      if (mounted) {
        _showErrorSnackBar(
          "Could not get your location in time. Showing default area.",
        );
        setState(() => _startPoint = _addisAbabaCenter); // Use fallback
      }
    } catch (e) {
      print("ðŸ”¥â Œ ERROR during location finding: $e");
      if (mounted) {
        _showErrorSnackBar(
          'Could not get current location. Showing default area.',
        );
        setState(() => _startPoint = _addisAbabaCenter); // Use fallback
      }
    }
  }

  Future<void> _fetchAvailableContracts() async {
    setState(() {
      _isLoadingContracts = true;
      _contractsError = null;
    });
    try {
      final contracts = await _apiService.getAvailableContracts();
      if (mounted) {
        setState(() {
          _availableContracts = contracts;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _contractsError = "Failed to load contract options.";
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingContracts = false);
      }
    }
  }

  // ✅ THIS IS THE METHOD TO FIND AND REPLACE
  void _handleContractSelected(Contract contract) {
    // 1. Add a safety check to ensure a route has been planned.
    if (_startPoint == null || _destinationPoint == null) {
      _showErrorSnackBar(
        'Cannot create subscription without a selected route.',
      );
      return; // Stop execution if there's no route.
    }

    // 2. Navigate to the CreateSubscriptionScreen with all the required data.
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateSubscriptionScreen(
          contractId: contract.id,
          contractType: contract.contractType,
          // Pass the current route information from the HomeScreen's state
          startAddress: _startAddress,
          destinationAddress: _destinationAddress,
          startPoint: _startPoint!, // Safe to use ! due to the check above
          destinationPoint: _destinationPoint!, // Safe to use !
        ),
      ),
    );
  }

  Future<bool> _requestPermissions() async {
    await Permission.notification.request();

    var locationStatus = await Permission.location.request();
    if (locationStatus.isDenied) {
      _showErrorSnackBar('Location permission is required to use the map.');
      return false;
    }
    if (locationStatus.isPermanentlyDenied) {
      _showErrorSnackBar(
        'Location permission is permanently denied. Please enable it from app settings.',
      );
      openAppSettings();
      return false;
    }

    // Request Notification Permission (for Android 13+)
    if (Platform.isAndroid) {
      var notificationStatus = await Permission.notification.request();
      if (notificationStatus.isDenied) {
        print(
          "Notification permission denied. User will not receive ride updates.",
        );
      }
      if (notificationStatus.isPermanentlyDenied) {
        print("Notification permission permanently denied.");
      }
    }

    return true;
  }

  /// âœ… NEW: A much faster, non-blocking initialization method.
  /// ✅ NEW: A much faster, non-blocking initialization method.
  Future<void> _initializeHomeScreen() async {
    print("🚀 Initializing HomeScreen...");
    try {
      await _requestPermissions();
      // Load non-essential UI data in the background
      _loadUserProfile();
      _fetchVehicleTypes();
      _loadCustomMarkers();

      // Initialize socket listeners
      _initializeSocketListeners();

      // Check for an active booking first
      // final bool wasBookingRestored = await _checkForActiveBooking();
      // if (wasBookingRestored) {
      //   print("✅ Active booking restored, skipping location fetch.");
      //   return;
      // }

      // Wait for the map controller to be ready
      if (!_mapController.isCompleted) {
        print("🗺 Waiting for map controller...");
        await _mapController.future;
      }

      // Fetch and navigate to the user's current location
      await _goToCurrentUserLocation();

      // Handle initial route if provided
      if (widget.initialRoute != null &&
          widget.initialRoute!.end != null &&
          mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _planOrUpdateRoute(
              widget.initialRoute!.end!.coordinates,
              start: widget.initialRoute!.start?.coordinates,
            );
          }
        });
      }
    } catch (e, stack) {
      print("💥 Error initializing HomeScreen: $e\n$stack");
      if (mounted) {
        setState(
          () => _errorMessage = "Failed to initialize the app. Please restart.",
        );
        Logger.error("HomeScreen", "Fatal initialization error", e, stack);
      }
    } finally {
      if (mounted) {
        setState(() => _isMapLoading = false);
      }
    }
    print("✅ HomeScreen initialized.");
    // Stop simulation when navigating to the CreateSubscriptionScreen
  }
  // Helper for "Get and Listen"

  // In _HomeScreenState class inside lib/screens/home_screen.dart
  // --- COPY AND PASTE THIS ENTIRE METHOD INTO YOUR _HomeScreenState CLASS ---

  // ✅ --- UPDATE THE onPlaceSelectedFromSearch FUNCTION ---
  // This function is called when the user selects a location from the SearchPanel.
  void _onPlaceSelectedFromSearch(PlaceDetails place, String field) {
    debugPrint(
      "🏠 [HOME SCREEN] Place selected from search: ${place.primaryText}",
    );
    debugPrint("🏠 [HOME SCREEN] Field: $field");
    debugPrint("🏠 [HOME SCREEN] Coordinates: ${place.coordinates}");
    // --- NEW LOGIC FOR CONTRACT CREATION ---
    // If we are in the middle of creating a contract, handle it here.
    if (_selectedContractForCreation != null) {
      if (field == 'start') {
        // User has selected the pickup location.
        setState(() {
          _startPlace = place;
          _startPoint = place.coordinates;
          _startAddress = place.primaryText;
        });
        // Now, the SearchPanel will show the pickup is set and ask for the destination.
      } else {
        // field == 'end'
        // User has selected the destination. We have everything we need!
        setState(() {
          _endPlace = place;
          _destinationPoint = place.coordinates;
          _destinationAddress = place.primaryText;
        });

        // Navigate to the final confirmation screen.
        Navigator.of(context)
            .push(
              MaterialPageRoute(
                builder: (context) => CreateSubscriptionScreen(
                  contractId: _selectedContractForCreation!.id,
                  contractType: _selectedContractForCreation!.contractType,
                  startAddress: _startAddress,
                  destinationAddress: _destinationAddress,
                  startPoint: _startPoint!,
                  destinationPoint: _destinationPoint!,
                ),
              ),
            )
            .then((_) {
              // After the user comes back, reset everything.
              _resetMapState();
            });
      }
      return; // Stop execution here for contract flow.
    }

    // --- Your existing logic for regular ride booking ---
    setState(() {
      if (field == 'start') {
        _startPoint = place.coordinates;
        _startAddress = place.primaryText;
        _currentMapState = MapState.search;
        _isPanelVisible = true;
      } else {
        _planOrUpdateRoute(
          place.coordinates,
          start: _startPoint,
          startName: _startAddress,
          destinationName: place.primaryText,
        );
      }
    });
  }

  Future<void> _submitDriverRating() async {
    if (_currentBookingId == null) {
      _showErrorSnackBar("Cannot submit rating: booking info is missing.");
      return;
    }

    final driverId = _activeBooking?.driverId;
    if (driverId == null || driverId.isEmpty) {
      _showErrorSnackBar("Cannot submit rating: driver info is missing.");
      return;
    }

    setState(() => _isRatingSubmitting = true);

    try {
      // ✅ FIX: Call the ratebooking method from _apiService
      await _apiService.ratebooking(
        bookingId: _currentBookingId!,
        rating: _postTripRating.toInt(),
        feedback: _postTripCommentController.text.trim().isNotEmpty
            ? _postTripCommentController.text.trim()
            : null,
      );
      Logger.success(
        "HomeScreen",

        "Rating submitted successfully. Rated {_postTripRating} stars and left feedback: {_postTripCommentController.text.trim().isNotEmpty ? _postTripCommentController.text.trim() : 'No comment'}",
      );
      _showSuccessSnackBar("Thank you for your feedback!");

      _resetMapState();
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(
          "An unexpected error occurred while submitting rating.",
        );
        setState(() => _isRatingSubmitting = false);
      }
    }
  }

  Future<void> _handleDriverAssigned(Booking acceptedBooking) async {
    if (!mounted) return;
    Logger.success(
      "HomeScreen",
      "🎉 DRIVER ASSIGNED! Processing booking: ${acceptedBooking.id}",
    );

    // --- THE FIX: RESET PROXIMITY FLAGS FOR THE NEW TRIP ---
    _proximityAlertsTriggered.updateAll((key, value) => false);

    _nearbyDriverSimulatorManager?.stop();

    // --- ✨ THE CORE FIX IS HERE: Populate state from the incoming booking object ---
    // This ensures that even when restoring a session, the HomeScreen's state
    // is correctly initialized with the active ride's details.
    setState(() {
      _currentBookingId = acceptedBooking.id;
      _startPoint = acceptedBooking.pickup.coordinates;
      _destinationPoint = acceptedBooking.dropoff.coordinates;
      _startAddress = acceptedBooking.pickup.address ?? "Pickup Location";
      _destinationAddress = acceptedBooking.dropoff.address ?? "Destination";
    });
    // --- End of Core Fix ---

    if (acceptedBooking.driverId == null || acceptedBooking.driverId!.isEmpty) {
      _resetMapState();
      return;
    }
    _showSuccessSnackBar("Your driver is on the way!");

    // Now this part is safe because _startPoint and _destinationPoint are guaranteed to be non-null.
    _activeBooking = acceptedBooking.copyWith(
      pickup: LocationPoint(
        coordinates: _startPoint!,
        address: _startAddress,
        name: _startAddress,
      ),
      dropoff: LocationPoint(
        coordinates: _destinationPoint!,
        address: _destinationAddress,
        name: _destinationAddress,
      ),
      vehicleType:
          acceptedBooking.vehicleType == 'unknown' &&
              _vehicleTypes.isNotEmpty &&
              _selectedRideOptionIndex < _vehicleTypes.length
          ? _vehicleTypes[_selectedRideOptionIndex].name
          : acceptedBooking.vehicleType,
    );

    final assignedDriver = NearbyDriver(
      id: _activeBooking!.driverId!,
      name: _activeBooking!.assignedDriverName ?? 'Assigned Driver',
      position: _activeBooking!.pickup.coordinates,
      vehicleType: _activeBooking!.vehicleType,
      rating: _activeBooking!.driverRating,
      photoUrl: _activeBooking!.driverPhotoUrl,
      phone: _activeBooking!.driverPhone,
      vehicle: _activeBooking!.assignedVehicleDetails,
    );

    setState(() {
      _currentMapState = MapState.driverOnTheWay;
      _assignedDriverDetails = assignedDriver;
      _assignedVehicleDetails = _activeBooking!.assignedVehicleDetails;
      _nearbyDrivers = [];
      _isPanelVisible = true;
    });

    _socketService.fetchBookingNotes(bookingId: _activeBooking!.id);
    _startPassengerLocationUpdates();
    _notificationService.showRideUpdateNotification(
      title: AppLocalizations.of(context)!.notificationRideConfirmedTitle,
      body: AppLocalizations.of(context)!.notificationRideConfirmedBody(
        acceptedBooking.assignedDriverName ?? 'Your Driver',
      ),
      payload: acceptedBooking.id,
      imageUrl: VehicleType.fromName(
        acceptedBooking.vehicleType,
      ).notificationIconUrl,
    );
    try {
      Logger.info(
        "HomeScreen",
        "   L-- fetching initial driver position and ETA...",
      );
      final progress = await _apiService.getBookingProgress(_activeBooking!.id);
      if (!mounted) return;

      if (progress.driverLocation != null && _startPoint != null) {
        final driverCurrentPos = progress.driverLocation!;
        setState(() {
          _driverPosition = driverCurrentPos;
          _etaToPickup = "${progress.etaMinutes ?? '...'} min";
        });

        await _drawPolyline(
          'driver_to_pickup',
          driverCurrentPos,
          _startPoint!,
          Colors.blueAccent,
        );
        _animateCameraToFitBounds(driverCurrentPos, _startPoint!);
      }
      _updateMarkers();
    } catch (e) {
      Logger.error(
        "HomeScreen",
        "Error fetching booking progress after assignment",
        e,
      );
    }
  }

  void _showMapTypeSelector() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // For checking the current style, we'll store it as a simple string.
        // We can't ask the controller for its current style, so we manage it ourselves.
        // Let's assume the default is the dark mapStyle.
        // We need to manage a state variable for the current style to make the check mark work.

        // We'll pass the style string directly to the tile builder.
        return AlertDialog(
          backgroundColor: const Color(0xFF2a3a4a),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            l10n.mapLayersTitle,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildMapTypeTile(
                l10n.mapLayersDark,
                Icons.dark_mode,
                MapType.normal,
                mapStyle,
              ),
              const Divider(color: Colors.white24, height: 1),
              // ✅ THE FIX IS HERE: We pass the imported constant 'lightMapStyle' directly.
              _buildMapTypeTile(
                l10n.mapLayersLight,
                Icons.light_mode,
                MapType.normal,
                lightMapStyle,
              ),
              const Divider(color: Colors.white24, height: 1),
              _buildMapTypeTile(
                l10n.mapLayersSatellite,
                Icons.satellite_alt,
                MapType.hybrid,
                null,
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleBookingStatusUpdate(BookingStatusUpdate update) {
    if (!mounted) return;
    final status = update.status.toLowerCase();
    Logger.info(
      "HomeScreen",
      "[STATUS CHANGE] Received new booking status: '$status'",
    );

    if (status == 'completed') {
      try {
        // 🎉 Show success feedback to user
        _notificationService.cancelRideNotification();
        setState(() {
          // 1. Change the UI state to show the rating panel
          _currentMapState = MapState.postTripRating;
          _isPanelVisible = true; // 👀 Ensure rating panel is visible

          // 2. Store the final trip data from the event payload
          _finalFare = update.fareFinal;
          _finalDistanceKm = update.distanceTraveled;

          // 3. Clean up the map for the summary view
          _polylines.clear(); // 🗑️ Clean up the map route safely

          // 4. Ensure addresses are user-friendly for the summary panel
          if (_startAddress.isEmpty || _startAddress == "Current Location") {
            _startAddress = "📍 Start Point";
          }
          if (_destinationAddress.isEmpty) {
            _destinationAddress = "🏁 Destination";
          }
        });

        // 5. Update the map markers to only show the start and end points
        try {
          _updateMarkers();
        } catch (e) {
          debugPrint("⚠️ Marker update failed: $e");
          _showErrorSnackBar("⚠️ Could not update trip markers.");
        }

        return; // ✅ Stop further execution after completion
      } catch (e, stack) {
        // 🔴 Global fail-safe error catch
        debugPrint("❌ Error in trip completion block: $e\n$stack");
        _showErrorSnackBar("❌ Something went wrong finishing the trip.");
        _resetMapState(); // Reset if something goes wrong
      }
    }

    if (status == 'driver_arrived') {
      if (_currentMapState != MapState.driverOnTheWay) return;
      _showSuccessSnackBar("Your driver has arrived!");
      setState(() => _etaToPickup = "Arrived");
      if (status == 'driver_arrived') {
        if (_currentMapState != MapState.driverOnTheWay) return;

        final l10n = AppLocalizations.of(context)!;
        _showSuccessSnackBar(l10n.notificationDriverArrivedTitle);
        setState(() => _etaToPickup = l10n.arrived);

        // --- Send System Notification ---
        _notificationService.showRideUpdateNotification(
          title: l10n.notificationDriverArrivedTitle,
          body: l10n.notificationDriverArrivedBody,
          payload: _currentBookingId,
          imageUrl: VehicleType.driverIconUrl, // Use the special driver icon
        );
      }
    } else if (status == 'ongoing') {
      setState(() => _currentMapState = MapState.ongoingTrip);
    } else if (status == 'canceled' || status == 'rejected') {
      _showErrorSnackBar('Your booking was cancelled.');
      _resetMapState();
    }
    // (The rest of the method for 'accepted', 'ongoing', etc., is correct)
    if (status == 'accepted') {
      if (_currentMapState == MapState.searchingForDriver &&
          _currentBookingId != null) {
        _apiService
            .getBookingDetails(_currentBookingId!)
            .then((booking) {
              if (mounted) _handleDriverAssigned(booking);
            })
            .catchError((e) {
              if (mounted) {
                _showErrorSnackBar("Could not load driver details.");
                _resetMapState();
              }
            });
      }
      return;
    }
    if (status == 'driver_arrived') {
      if (_currentMapState != MapState.driverOnTheWay) return;
      _showSuccessSnackBar("Your driver has arrived!");
      setState(() => _etaToPickup = "Arrived");
    } else if (status == 'ongoing') {
      setState(() => _currentMapState = MapState.ongoingTrip);
    } else if (status == 'canceled' || status == 'rejected') {
      _showErrorSnackBar('Your booking was cancelled.');
      _resetMapState();
    }
  }

  // --- 2. FIND AND REPLACE THIS METHOD ---
  void _checkDriverProximity(LatLng driverPosition) {
    if (_startPoint == null) return;

    final l10n = AppLocalizations.of(context)!;
    final double distanceInMeters = Geolocator.distanceBetween(
      driverPosition.latitude,
      driverPosition.longitude,
      _startPoint!.latitude,
      _startPoint!.longitude,
    );

    // Check for 100 meters
    if (distanceInMeters <= 100 && !_proximityAlertsTriggered[100]!) {
      // ✅ FIX: The 'id' parameter has been removed.
      _notificationService.showRideUpdateNotification(
        title: l10n.notificationDriverNearbyTitle,
        body: l10n.notificationDriverNearbyBody("100"),
        payload: _currentBookingId,
        imageUrl: VehicleType.driverIconUrl,
      );
      setState(() => _proximityAlertsTriggered[100] = true);
    }

    // Check for 50 meters
    if (distanceInMeters <= 50 && !_proximityAlertsTriggered[50]!) {
      // ✅ FIX: The 'id' parameter has been removed.
      _notificationService.showRideUpdateNotification(
        title: l10n.notificationDriverVeryCloseTitle,
        body: l10n.notificationDriverVeryCloseBody,
        payload: _currentBookingId,
        imageUrl: VehicleType.driverIconUrl,
      );
      setState(() => _proximityAlertsTriggered[50] = true);
    }

    // Check for 10 meters (arrival)
    if (distanceInMeters <= 10 && !_proximityAlertsTriggered[10]!) {
      // ✅ FIX: The 'id' parameter has been removed.
      _notificationService.showRideUpdateNotification(
        title: l10n.notificationDriverArrivedTitle,
        body: l10n.notificationDriverArrivedBody,
        payload: _currentBookingId,
        imageUrl: VehicleType.driverIconUrl,
      );
      setState(() => _proximityAlertsTriggered[10] = true);
    }
  }

  // Helper method for zooming the map to fit two points
  Future<void> _animateCameraToFitBounds(LatLng pos1, LatLng pos2) async {
    if (!mounted || !_mapController.isCompleted) return;

    final GoogleMapController controller = await _mapController.future;

    // Calculate the bounds
    LatLng southwest = LatLng(
      math.min(pos1.latitude, pos2.latitude),
      math.min(pos1.longitude, pos2.longitude),
    );
    LatLng northeast = LatLng(
      math.max(pos1.latitude, pos2.latitude),
      math.max(pos1.longitude, pos2.longitude),
    );

    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(southwest: southwest, northeast: northeast),
        100.0, // Padding around the route (in pixels)
      ),
    );
    Logger.info(
      "HomeScreen",
      "   L-- Map camera zoomed to fit passenger and driver.",
    );
  }

  // Helper method for zooming the map

  void _joinRideTrackingRoom(String bookingId) {
    print("ðŸ“¡ [Socket] Emitting 'joinRideRoom' for booking: $bookingId");
    _socketService.joinRideRoom(bookingId); // Use the correct method
  }

  void _startLiveDriverTracking(String bookingId) {
    _joinRideTrackingRoom(bookingId);
  }

  void _stopLiveDriverTracking() {
    _driverLocationSubscription?.cancel();
    _driverLocationSubscription = null;
  }

  // --- Initialization & Permissions ---
  Future<void> _initializeMapAndLocation() async {
    if (await _requestLocationPermission()) {
      await _goToCurrentUserLocation();
    } else {
      if (mounted) setState(() => _isMapLoading = false);
    }
  }

  Future<bool> _requestLocationPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied && mounted) {
      _showErrorSnackBar(
        'Location permission permanently denied. Please enable from app settings.',
      );
      openAppSettings();
    } else if (status.isDenied && mounted) {
      _showErrorSnackBar(
        'Location permission denied. Map features may be limited.',
      );
    }
    return false;
  }

  /// âœ… MODIFIED: This is now the single source of truth for locating the user,
  /// animating the camera, AND fetching relevant data for that location.

  // --- Find and REPLACE this entire method ---
  Future<void> _goToCurrentUserLocation() async {
    debugPrint(" 🎯 Locating user and preparing map...");

    // First, get the latest GPS coordinates.
    await _findCurrentUserLocation();

    // --- 🧠 CORE FIX: Get a high-quality address for the current location ---
    if (_startPoint != null) {
      try {
        debugPrint(" 🔄 Fetching high-quality address for current location...");
        // Get the current map zoom to help the service find the best address.
        // final GoogleMapController controller = await _mapController.future;
        // final zoom = await controller.getZoomLevel();

        final PlaceAddress place = await _googleMapsService
            .getAddressFromCoordinates(
              _startPoint!,
              currentZoomLevel: 20,
              useNearbySearch: true, // ✅ Use nearby search for current location
            );

        if (mounted) {
          // Update the state with the REAL address name.
          setState(() {
            _startAddress = place.name;
          });
          debugPrint("✅ Current location address resolved to: '${place.name}'");
        }
      } catch (e) {
        if (mounted)
          _showErrorSnackBar(
            "Could not get address for your current location.",
          );
        // Keep the default as a fallback
        setState(() {
          _startAddress = "Current Location";
        });
      }

      // Now, with the address resolved, animate the camera and fetch drivers.
      try {
        final GoogleMapController controller = await _mapController.future;
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _startPoint!,
              zoom: 16.0,
            ), // Zoom in a bit closer
          ),
        );
        debugPrint(" ✅ Camera animated to $_startPoint");

        if (_currentMapState == MapState.discovery && mounted) {
          _nearbyDriverSimulatorManager?.start(
            centerPoint: _startPoint!,
            searchRadiusKm: _searchRadiusKm,
            numberOfDrivers: 10,
          );
        }
      } catch (e) {
        if (mounted) _showErrorSnackBar("Map is not ready yet. Please wait.");
      }
    }
  }

  Future<void> _loadCustomMarkers() async {
    _carIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(64, 64)),
      'assets/images/car_icon.png',
    );
  }

  // --- Passenger Profile & Auth ---
  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoadingProfile = true;
      _profileErrorMessage = null;
    });
    try {
      final result = await _authService.getPassengerProfile();

      if (mounted && result['success'] == true) {
        setState(() {
          _passengerProfile = result['data'] as Passenger;
        });
      } else if (mounted) {
        throw ApiException(result['message'] ?? "Failed to load profile.");
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _profileErrorMessage = e.message;
      });
      if (e.statusCode == 401) {
        _logout();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _profileErrorMessage = 'An unexpected error occurred.';
      });
    } finally {
      if (mounted) setState(() => _isLoadingProfile = false);
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const PassengerLoginScreen()),
      (route) => false,
    );
  }

  void _navigateToEditProfile() async {
    if (_passengerProfile == null) {
      _showErrorSnackBar('Cannot edit profile: user data not loaded.');
      return;
    }
    _nearbyDriverSimulatorManager?.stop();
    final bool? updated = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            EditProfileScreen(initialProfileData: _passengerProfile!),
      ),
    );
    if (updated == true) {
      await _loadUserProfile();
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.profileUpdateSuccess),
          ),
        );
    }
  }

  void _navigateToHistory() {
    _nearbyDriverSimulatorManager?.stop();
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const HistoryScreen()));
  }

  // --- Map State Management ---
  void _resetMapState() {
    print("ðŸ”„ Resetting map state to discovery mode...");
    print("🔂 Resetting map state to discovery mode...");
    _nearbyDriverSimulatorManager?.stop();
    // Stop any ongoing listeners to prevent old data from coming in.
    _socketService.stopNearbyDriverUpdates();
    _stopPassengerLocationUpdates();
    _selectedDriverNotifier.value = null;
    _nearbyDriverSimulatorManager?.stop();

    // Reset all UI and state variables back to their defaults.
    setState(() {
      _isPanelVisible = false;
      _currentMapState = MapState.discovery;
      _destinationPoint = null;
      _selectedSubscription = null;
      _polylines.clear();
      _markers
          .clear(); // Explicitly clear markers to remove old destination pins
      _estimatedDistance = "";
      _estimatedTime = "";
      _startAddress = "Current Location";
      _destinationAddress = "";
      _currentBookingId = null;
      _assignedDriverDetails = null;
      _assignedVehicleDetails = null;
      _driverPosition = null;
      _lastMarkerPosition = null;
      _isBooking = false;
      _isContractTripOngoing = false;

      // ✅ FIX 1: Reset contract-specific state here
      _contractPickStage = 'pickup';
      _selectedContractForCreation = null;

      // Reset post-trip state
      _postTripCommentController.clear();
      _postTripRating = 5.0;
      _finalFare = null;
      _finalDistanceKm = null;

      // Reset new tipping and tag state
      _selectedTipAmount = 0.0;
      _selectedFeedbackTags.clear();
    });
    _bookingNotes = [];
    // Re-center the map on the user's current location.
    _goToCurrentUserLocation();

    // --- âœ… THE CRUCIAL FIX IS HERE ---
    // After resetting, we MUST restart the driver discovery "Get and Listen" pattern.
    // We add a small delay to ensure the user's location has been re-fetched.
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_startPoint != null && mounted) {
        print("   L-- Restarting driver discovery around $_startPoint");

        // 1. LISTEN: Tell the socket to send us live updates again.
        _socketService.startNearbyDriverUpdates(_startPoint!);

        // 2. GET: Immediately fetch the current driver locations via API.
      } else {
        print(
          "   L-- âš ï¸  Cannot restart driver discovery: _startPoint is null after reset.",
        );
      }
    });
  }
  // lib/screens/home_screen.dart -> _HomeScreenState
  // lib/screens/home_screen.dart

  // --- 1. FIND AND REPLACE THIS METHOD ---
  void _updateSingleMarker(String markerId, LatLng position, double bearing) {
    if (!mounted) return;

    final Marker markerToUpdate = _markers.firstWhere(
      (m) => m.markerId == MarkerId(markerId),
      orElse: () => Marker(markerId: MarkerId(markerId), icon: _carIcon!),
    );

    // --- THE FIX: REMOVE THE LINE BELOW ---
    // _proximityAlertsTriggered.updateAll((key, value) => false); // <-- DELETE THIS LINE

    final Marker updatedMarker = markerToUpdate.copyWith(
      positionParam: position,
      rotationParam: bearing,
    );

    setState(() {
      _markers.remove(markerToUpdate);
      _markers.add(updatedMarker);
    });
  }

  void _updateMarkers() {
    final newMarkers = <Marker>{};

    if (_currentMapState == MapState.discovery && _carIcon != null) {
      for (var driver in _nearbyDrivers) {
        newMarkers.add(
          Marker(
            markerId: MarkerId('driver-${driver.id}'),
            position: driver.position,
            icon: _carIcon!,
            rotation: driver.bearing ?? 0.0,
            flat: true,
            anchor: const Offset(0.5, 0.5),
            onTap: () {
              _infoWindowDismissTimer?.cancel(); // Cancel any previous timer
              _selectedDriverNotifier.value = driver; // Show the new window

              // Start a new timer to hide the window after 4 seconds
              _infoWindowDismissTimer = Timer(const Duration(seconds: 4), () {
                _selectedDriverNotifier.value = null;
              });
            },
          ),
        );
      }
    } else {
      // --- MODIFIED LOGIC HERE ---
      // Only show the start marker if we are NOT in discovery or searching.
      // The blue "myLocation" dot is the source of truth in those states.
      if (_startPoint != null &&
          _currentMapState != MapState.discovery &&
          _currentMapState != MapState.searchingForDriver) {
        newMarkers.add(
          Marker(
            markerId: const MarkerId('startLocation'),
            position: _startPoint!,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
            infoWindow: const InfoWindow(title: 'Pickup Location'),
          ),
        );
      }

      if (_destinationPoint != null) {
        newMarkers.add(
          Marker(
            markerId: const MarkerId('destinationLocation'),
            position: _destinationPoint!,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
            infoWindow: const InfoWindow(title: 'Destination'),
          ),
        );
      }
      if ((_currentMapState == MapState.driverOnTheWay ||
              _currentMapState == MapState.ongoingTrip) &&
          _driverPosition != null &&
          _carIcon != null) {
        final driverId = _assignedDriverDetails?.id ?? 'assigned-driver';
        newMarkers.add(
          Marker(
            markerId: MarkerId('driver-$driverId'),
            position: _driverPosition!,
            icon: _carIcon!,
            rotation: _lastMarkerBearing ?? 0.0,
            flat: true,
            anchor: const Offset(0.5, 0.5),
          ),
        );
      }

      if ((_currentMapState == MapState.driverOnTheWay ||
              _currentMapState == MapState.ongoingTrip) &&
          _driverPosition != null &&
          _carIcon != null) {
        final driverId = _assignedDriverDetails?.id ?? 'assigned-driver';
        newMarkers.add(
          Marker(
            markerId: MarkerId('driver-$driverId'),
            position: _driverPosition!,
            icon: _carIcon!,
            rotation: _lastMarkerBearing ?? 0.0,
            flat: true,
            anchor: const Offset(0.5, 0.5),
          ),
        );
      }
    }

    if (mounted) {
      setState(() => _markers = newMarkers);
    }
  }

  void _animateCameraToFitPolyline() async {
    if (_polylines.isEmpty) return;
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        _createBounds(_polylines.first.points),
        100.0,
      ),
    );
  }

  LatLngBounds _createBounds(List<LatLng> positions) {
    if (positions.isEmpty)
      return LatLngBounds(
        southwest: const LatLng(0, 0),
        northeast: const LatLng(0, 0),
      );
    final southwestLat = positions.map((p) => p.latitude).reduce(math.min);
    final southwestLon = positions.map((p) => p.longitude).reduce(math.min);
    final northeastLat = positions.map((p) => p.latitude).reduce(math.max);
    final northeastLon = positions.map((p) => p.longitude).reduce(math.max);
    return LatLngBounds(
      southwest: LatLng(southwestLat, southwestLon),
      northeast: LatLng(northeastLat, northeastLon),
    );
  }

  // --- Location & Driver Updates ---
  Future<void> _startPassengerLocationUpdates() async {
    _stopPassengerLocationUpdates();
    _passengerLocationSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen((Position position) {
          if (!mounted) return;
          DateTime now = DateTime.now();
          bool shouldPush =
              _lastPassengerLocationPush == null ||
              now.difference(_lastPassengerLocationPush!) >=
                  _passengerLocationPushInterval;

          if (shouldPush) {
            String statusToSend = "requested";
            if (_currentMapState == MapState.driverOnTheWay)
              statusToSend = "accepted";
            if (_currentMapState == MapState.ongoingTrip)
              statusToSend = "ongoing";

            _socketService.pushPassengerLocation(
              LatLng(position.latitude, position.longitude),
              bookingId: _currentBookingId,
            );

            _lastPassengerLocationPush = now;
          }
        });
    if (kDebugMode) print("Passenger location updates started (via Socket).");
  }

  void _stopPassengerLocationUpdates() {
    _passengerLocationSubscription?.cancel();
    _passengerLocationSubscription = null;
    if (kDebugMode) print("Passenger location updates stopped.");
  }

  // lib/screens/home_screen.dart -> _HomeScreenState

  // In _HomeScreenState class, find and REPLACE _checkForActiveBooking

  // Future<bool> _checkForActiveBooking() async {
  //   // <-- Change return type to Future<bool>
  //   print(
  //     "ðŸŸ¡ [START] Checking for active booking using new service method...",
  //   );

  //   try {
  //     final ActiveBookingState? restoredState = await _apiService
  //         .restoreActiveBookingState();

  //     if (restoredState != null && mounted) {
  //       print("âœ… [SUCCESS] Active booking state restored. Applying to UI...");
  //       final booking = restoredState.booking;

  //       // --- CRITICAL FIX: Ensure all necessary state is restored ---
  //       setState(() {
  //         _currentMapState = restoredState.mapState;
  //         _currentBookingId = booking.id;
  //         _activeBooking = booking; // Set the full booking object

  //         // Restore pickup/dropoff points and addresses
  //         _startPoint = booking.pickup.coordinates;
  //         _startAddress = booking.pickup.address ?? "Current Location";
  //         _destinationPoint = booking.dropoff.coordinates;
  //         _destinationAddress = booking.dropoff.address ?? "Destination";

  //         // Restore assigned driver details using fields from the robust Booking model
  //         _assignedDriverDetails = NearbyDriver(
  //           id: booking.driverId ?? 'N/A', // Must be non-null
  //           // Use the assignedDriverName property, which should be populated by Booking.fromJson
  //           name: booking.assignedDriverName ?? 'Finding Driver...',
  //           position: progress.driverLocation ?? booking.pickup.coordinates,
  //           vehicleType: booking.vehicleType,
  //           rating: booking.driverRating,
  //           phone: booking.driverPhone,
  //           photoUrl: booking.driverPhotoUrl,
  //           // ✅ FIX: Use the new assignedDriverEmail field
  //           email: booking.assignedDriverEmail,
  //           vehicle: booking.assignedVehicleDetails,
  //         );

  //         _assignedVehicleDetails = booking.assignedVehicleDetails ?? {};
  //         _driverPosition = progress.driverLocation;
  //         _etaToPickup = "${progress.etaMinutes ?? '...'} min";

  //         // State flags
  //         _isBooking = true;
  //         _isPanelVisible = true;
  //         _polylines.clear(); // Clear any old polylines
  //         _polylines.clear(); // Clear any old polylines from previous states
  //         _polylines.add(
  //           Polyline(
  //             // Determine the route type based on the restored state
  //             polylineId: PolylineId(
  //               restoredState.mapState == MapState.ongoingTrip
  //                   ? 'ongoing_trip'
  //                   : 'driver_to_pickup',
  //             ),
  //             points: restoredState.polylinePoints, // Use the restored points
  //             color: restoredState.mapState == MapState.ongoingTrip
  //                 ? Colors
  //                       .deepPurple // Color for ongoing trip
  //                 : Colors.blueAccent, // Color for driver arriving
  //             width: 6,
  //           ),
  //         );
  //       });
  //       if (progress.driverLocation != null && _startPoint != null) {
  //         final LatLng start = progress.driverLocation!;
  //         final LatLng end = restoredState.mapState == MapState.ongoingTrip
  //             ? _destinationPoint!
  //             : _startPoint!;
  //         _animateCameraToFitBounds(start, end);
  //       }
  //       _socketService.fetchBookingNotes(bookingId: booking.id);
  //       _updateMarkers();
  //       _socketService.joinRideRoom(booking.id);

  //       if (restoredState.mapState == MapState.driverOnTheWay) {
  //         _startPassengerLocationUpdates();
  //       }
  //       print(
  //         "ðŸ—ºï¸  UI state successfully restored to '${restoredState.mapState}'.",
  //       );
  //       return true; // <-- RETURN true when a booking is restored
  //     } else {
  //       print(
  //         "ðŸ”µ [INFO] No active booking found. Starting in discovery mode.",
  //       );
  //       return false; // <-- RETURN false when no booking is found
  //     }
  //   } on ApiException catch (e) {
  //     print("â Œ API Error during booking restoration: ${e.message}");
  //     _showErrorSnackBar('Error restoring your active ride: ${e.message}');
  //     return false; // <-- RETURN false on error
  //   } catch (e) {
  //     print("ðŸ’¥ Unexpected error during booking restoration: $e");
  //     _showErrorSnackBar(
  //       'An unexpected error occurred while checking your session.',
  //     );
  //     return false; // <-- RETURN false on error
  //   } finally {
  //     if (mounted) {
  //       print("ðŸ”µ [END] Finished checking booking.");
  //     }
  //   }
  // }

  Future<void> _confirmRide() async {
    if (_startPoint == null ||
        _destinationPoint == null ||
        _vehicleTypes.isEmpty) {
      _showErrorSnackBar('Please select a valid destination.');
      return;
    }

    setState(() {
      _isBooking = true;
      _currentMapState = MapState.searchingForDriver;
      _isPanelVisible = true;
    });

    // Define selectedVehicle locally
    final selectedVehicle = _vehicleTypes[_selectedRideOptionIndex];
    debugPrint(
      "Passing to socket: selectedVehicle.name=${selectedVehicle.name}, pickupCoordinates=${_startPoint!.toJson()}, pickupAddress=$_startAddress, dropoffCoordinates=${_destinationPoint!.toJson()}, dropoffAddress=$_destinationAddress",
    );
    debugPrint("");
    _socketService.requestBooking(
      pickupCoordinates: _startPoint!,
      pickupAddress: _startAddress,
      dropoffCoordinates: _destinationPoint!,
      dropoffAddress: _destinationAddress,
      vehicleType: selectedVehicle.name,
    );

    _showSuccessSnackBar("Requesting ride... Searching for a nearby driver.");
    _startPassengerLocationUpdates();
  }

  Future<void> _cancelBooking() async {
    _stopPassengerLocationUpdates();

    if (_currentBookingId != null) {
      // The new logic: emit a socket event.
      _socketService.cancelBooking(
        bookingId: _currentBookingId!,
        reason: "Cancelled by passenger",
      );
      // The backend will confirm cancellation via 'booking:cancelled' event,
      // which triggers our _handleBookingStatusUpdate and resets the map.
      _showErrorSnackBar('Cancelling your booking...');
      _resetMapState();
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } else {
      // If there's no booking ID, just reset the map state locally.
      _resetMapState();
    }
  }

  void _navigateToSearchScreen() {
    _nearbyDriverSimulatorManager?.stop(); // Stop simulation when searching
    // Instead of navigating, we change the state to show the SearchPanel.
    setState(() {
      _currentMapState = MapState.search;
      _isPanelVisible = true; // Make sure the bottom panel is active
    });
  }

  Future<void> _getDirectionsAndFares() async {
    if (_startPoint == null || _destinationPoint == null) return;

    setState(() {
      _isLoadingRideOptions = true;
      _rideOptionsError = null;
      _fareEstimates = {};
      _polylines.clear();
    });

    try {
      // Step 1: Get the route visuals and text display from Google Maps.
      await _getPolylineAndRouteInfo(_startPoint!, _destinationPoint!);

      // Step 2: With the route confirmed, fetch fare estimates for all vehicle types from our backend.
      await _getFareEstimatesForAllTypes(_startPoint!, _destinationPoint!);

      // Step 3: get contrats
      await _fetchAvailableContracts();
    } catch (e) {
      Logger.error("HomeScreen", "Error in _getDirectionsAndFares", e);
      if (mounted) {
        _showErrorSnackBar(
          "Could not calculate route and fares. Please try again.",
        );
        setState(() {
          _rideOptionsError = "Failed to get trip details.";
          _estimatedDistance = "N/A";
          _estimatedTime = "N/A";
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingRideOptions = false);
      }
    }
  }

  void _showChatBottomSheet() {
    if (_currentBookingId == null) {
      _showErrorSnackBar("No active ride to chat about.");
      return;
    }

    // First, ensure we have the latest message history from the server.
    _socketService.fetchBookingNotes(bookingId: _currentBookingId!);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the sheet to take up more space
      backgroundColor: Colors.transparent,
      builder: (context) {
        // We use a StreamBuilder to automatically listen to new messages.
        // This is much cleaner and more reliable than manual subscriptions.
        return StreamBuilder<BookingNote>(
          // Listen directly to the stream of individual new notes
          stream: _socketService.bookingNoteStream.where(
            (note) => note.bookingId == _currentBookingId,
          ),
          builder: (context, snapshot) {
            // If a new note arrives, add it to our local list.
            if (snapshot.hasData &&
                !_bookingNotes.any(
                  (n) => n.timestamp == snapshot.data!.timestamp,
                )) {
              // Use a post-frame callback to avoid calling setState during a build
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _bookingNotes.add(snapshot.data!);
                  });
                }
              });
            }

            // The _ChatView now receives the always-up-to-date _bookingNotes list
            // from the HomeScreen's state.
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: _ChatView(
                bookingId: _currentBookingId!,
                // Pass the main screen's list of notes
                notes: _bookingNotes,
                passengerId: _passengerProfile?.id ?? '',
                onSend: (message) {
                  _socketService.sendBookingNote(
                    bookingId: _currentBookingId!,
                    message: message,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  // In lib/screens/home_screen.dart
  Future<void> _handleMapTapForSaving(LatLng position) async {
    setState(() {
      _tappedPlaceDetails = null; // Clear old details

      // Determine marker hue based on pickingMode
      BitmapDescriptor markerIcon;
      switch (_pickingMode) {
        case MapPickingMode.setPickup:
          markerIcon = BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueYellow,
          );
          break;
        case MapPickingMode.setDestination:
          markerIcon = BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed,
          );
          break;
        default:
          // For setHome, setWork, addFavorite, or general discovery taps
          markerIcon = BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          );
          break;
      }

      _tappedPointMarker = Marker(
        markerId: const MarkerId('tapped_location'),
        position: position,
        icon: markerIcon, // Use the dynamically chosen icon
      );
    });
    _updateMarkers(); // Show the new temporary marker

    try {
      final address = await _googleMapsService.getAddressFromCoordinates(
        position,
        useNearbySearch: true, // ✅ Use nearby search for map taps
      );
      if (mounted) {
        setState(() {
          _tappedPlaceDetails = PlaceDetails(
            primaryText: address.name,
            secondaryText: AppLocalizations.of(
              context,
            )!.setPickup, // Use localized string
            coordinates: position,
            placeId: 'map_tapped_${position.latitude}_${position.longitude}',
          );
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _tappedPlaceDetails = PlaceDetails(
            primaryText: 'Selected Location',
            secondaryText: AppLocalizations.of(
              context,
            )!.setPickup, // Use localized string
            coordinates: position,
            placeId: 'map_tapped_${position.latitude}_${position.longitude}',
          );
        });
      }
    }
  }

  Future<void> _confirmContractDropoff() async {
    if (_currentBookingId == null) {
      _showErrorSnackBar("Cannot confirm dropoff: trip ID is missing.");
      _resetMapState();
      return;
    }

    try {
      _showSuccessSnackBar("Confirming dropoff...");
      // This API call tells the backend that the trip has ended from the passenger's side.
      // The backend will then change the trip status to 'COMPLETED' and emit a
      // socket event, which will automatically trigger the rating panel to show up.
      await _apiService.confirmTripDropoff(
        _currentBookingId!,
        notes: "Trip completed by passenger.",
      );
      _resetMapState();
      // No need to manually reset state here, the socket event handler will do it.
    } catch (e) {
      _showErrorSnackBar("Failed to confirm dropoff. Please try again.");
      Logger.error("HomeScreen", "Error confirming contract dropoff", e);
    }
    _resetMapState();
  }

  Future<void> _planOrUpdateRoute(
    LatLng destination, {
    LatLng? start,
    String?
    destinationName, // This will have a value from search, but be null for map taps
    String? startName, // This will have a value from search
    double currentZoom = 16.0,
  }) async {
    _nearbyDriverSimulatorManager?.stop();
    debugPrint("--- 🗺️ _planOrUpdateRoute Activated ---");

    // --- Step 1: Immediately update UI to feel responsive ---
    setState(() {
      _currentMapState = MapState.planning;
      _isLoadingRideOptions = true;
      _isPanelVisible = true;
      _destinationPoint = destination;
      _polylines.clear(); // Clear old routes

      // Use the best name available right now. We will confirm/fetch below.
      _startAddress = startName ?? _startAddress;
      _destinationAddress = destinationName ?? "Loading Address...";

      if (start != null) {
        _startPoint = start;
      }
    });

    _updateMarkers(); // Show the new pins on the map immediately

    // --- ✅ THE CORE FIX IS HERE: Intelligently determine the final addresses ---
    String finalStartAddress = _startAddress;
    String finalDestAddress = _destinationAddress;

    // If a specific destinationName was passed from the search panel, USE IT.
    if (destinationName != null) {
      debugPrint(
        "✅ Using EXACT destination name from search: '$destinationName'",
      );
      finalDestAddress = destinationName;
    } else {
      // Otherwise, this was a map tap, so we MUST fetch the address from coordinates.
      debugPrint("🔄 Fetching destination name for map tap...");
      try {
        final destPlace = await _googleMapsService.getAddressFromCoordinates(
          destination,
          currentZoomLevel: currentZoom,
          useNearbySearch: true, // Good for map taps
        );
        finalDestAddress = destPlace.name;
      } catch (e) {
        finalDestAddress = "Selected Location"; // Fallback for map tap
      }
    }

    // If a specific startName was passed from the search panel, USE IT.
    if (startName != null) {
      debugPrint("✅ Using EXACT start name from search: '$startName'");
      finalStartAddress = startName;
    } else if (_startPoint != null) {
      // If no start name was given, it's likely the user's current location.
      // Let's get a proper name for it instead of just "Current Location".
      debugPrint("🔄 Fetching name for current start location...");
      try {
        final startPlace = await _googleMapsService.getAddressFromCoordinates(
          _startPoint!,
          currentZoomLevel: currentZoom,
          useNearbySearch: true,
        );
        finalStartAddress = startPlace.name;
      } catch (e) {
        finalStartAddress = "Current Location"; // Fallback
      }
    }

    // --- Step 2: Update the UI with the final, correct names ---
    if (mounted) {
      setState(() {
        _startAddress = finalStartAddress;
        _destinationAddress = finalDestAddress;
      });
      debugPrint(
        "✅ Final addresses confirmed: '$_startAddress' -> '$_destinationAddress'",
      );
    }

    // --- Step 3: With correct addresses set, get the route and fares ---
    if (mounted) {
      await _getDirectionsAndFares();
    }
  }

  Future<void> _getPolylineAndRouteInfo(LatLng start, LatLng end) async {
    try {
      final RouteDetails? routeDetails = await _googleMapsService
          .getDirectionsInfo(start, end);

      if (routeDetails != null && mounted) {
        setState(() {
          _polylines.clear();
          _polylines.add(
            Polyline(
              polylineId: const PolylineId('route'),
              points: routeDetails.points,
              color: const Color.fromARGB(255, 2, 39, 248),
              width: 6,
            ),
          );
          _estimatedDistance = routeDetails.distanceText;
          _estimatedTime = routeDetails.durationText;
        });

        // ✨ THE CORE FIX: REMOVE THE UNNECESSARY ADDRESS LOOKUP
        // await _getAddressesFromCoordinates(); // <--- DELETE OR COMMENT OUT THIS LINE
      } else {
        throw Exception("Failed to get route details from Google.");
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar("Could not get route details from Google Maps.");
        setState(() {
          _estimatedDistance = "N/A";
          _estimatedTime = "N/A";
        });
      }
    }
  }

  /// ✅ CORRECTED: Fetches fares from the backend using only start/end points.
  Future<void> _getFareEstimatesForAllTypes(LatLng start, LatLng end) async {
    final Map<String, FareEstimate> newFareEstimates = {};

    final List<Future<void>> fareFutures = _vehicleTypes.map((vehicle) async {
      try {
        final estimate = await _apiService.estimateFare(
          pickup: start,
          dropoff: end,
          vehicleType: vehicle.name.toLowerCase(),
        );
        newFareEstimates[vehicle.name.toLowerCase()] = estimate;
      } catch (e) {
        Logger.error(
          "HomeScreen",
          "Failed to get fare for '${vehicle.name}'",
          e,
        );
      }
    }).toList();

    await Future.wait(fareFutures);

    if (mounted) {
      setState(() {
        _fareEstimates = newFareEstimates;
        if (newFareEstimates.isEmpty && _vehicleTypes.isNotEmpty) {
          _rideOptionsError = "Could not load prices.";
        }
      });
    }
  }

  Future<void> _fetchVehicleTypes() async {
    // We no longer need the isLoadingRideOptions state here, as the main
    // screen's loading indicator is already active.
    try {
      print("ðŸš— Fetching vehicle types from API...");
      final List<VehicleType> types = await _apiService.getVehicleTypes();
      if (mounted) {
        setState(() => _vehicleTypes = types);
        print("âœ… Vehicle types fetched successfully. $types");
      }
    } on DioException catch (e) {
      // This will catch timeouts, network errors, etc.
      if (mounted) {
        print("â Œ DioException while fetching vehicle types: ${e.message}");
        _showErrorSnackBar(
          "Could not load vehicle types. Please check your connection.",
        );
        // IMPORTANT: Set vehicle types to an empty list on failure.
        setState(() {
          _vehicleTypes = [];
          print("â Œ Vehicle types set to empty list.");
        });
      }
    } catch (e) {
      // Catch any other unexpected errors.
      if (mounted) {
        print("â Œ Unexpected error fetching vehicle types: ${e.toString()}");
        _showErrorSnackBar("An error occurred while loading ride options.");
        setState(() {
          _vehicleTypes = [];
        });
      }
    }
  }

  void _onPickOnMapRequested(String field) {
    setState(() {
      _fieldBeingSet = field; // Can now be 'start', 'end', 'home', or 'work'
      if (field == 'start') {
        _pickingMode = MapPickingMode.setPickup;
      } else if (field == 'end') {
        _pickingMode = MapPickingMode.setDestination;
      } else if (field == 'home') {
        _pickingMode = MapPickingMode.setHome;
      } else if (field == 'work') {
        _pickingMode = MapPickingMode.setWork;
      }
      // Hide the panel to show the map picker UI
      _currentMapState = MapState.discovery; // Go back to the map view
      _isPanelVisible = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Move the map to choose your ${field.toLowerCase()} location",
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _getDirections() async {
    if (_startPoint == null ||
        _destinationPoint == null ||
        _vehicleTypes.isEmpty) {
      return;
    }

    final selectedVehicleType = _vehicleTypes[_selectedRideOptionIndex].name;
    final List<LatLng> polylineCoordinates = await _getPolylineFromGoogle(
      _startPoint!,
      _destinationPoint!,
    );

    if (polylineCoordinates.isEmpty) {
      return;
    }

    try {
      final BackendRouteResponse backendRoute = await _apiService.getRoute(
        from: _startPoint!,
        to: _destinationPoint!,
        vehicleType: selectedVehicleType,
      );

      if (mounted &&
          backendRoute.routes.isNotEmpty &&
          backendRoute.routes[0].firstLeg != null) {
        final RouteLeg leg = backendRoute.routes[0].firstLeg!;
        setState(() {
          _estimatedDistance = leg.distanceText;
          _estimatedTime = leg.durationText;
        });
      } else {
        if (mounted) {
          _showErrorSnackBar("Could not get trip details from backend");
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar("Error getting trip details: ${e.toString()}");
      }
    }

    if (mounted) {
      setState(() {
        _polylines.clear();
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            points: polylineCoordinates,
            color: const Color.fromARGB(255, 2, 39, 248),
            width: 6,
          ),
        );
      });

      _animateCameraToFitPolyline();
      await _getAddressesFromCoordinates();
    }
  }

  Future<void> _getAddressesFromCoordinates() async {
    String newStartAddress = "Current Location";
    String newDestAddress = "";

    try {
      // This list now correctly expects the powerful PlaceAddress object
      final List<Future<PlaceAddress>> addressFutures = []; // <-- FIX

      if (_startPoint != null) {
        addressFutures.add(
          _googleMapsService.getAddressFromCoordinates(_startPoint!),
        );
      }
      if (_destinationPoint != null) {
        addressFutures.add(
          _googleMapsService.getAddressFromCoordinates(_destinationPoint!),
        );
      }

      if (addressFutures.isEmpty) return;

      // Await the list of PlaceAddress objects
      final List<PlaceAddress> addresses = await Future.wait(
        addressFutures,
      ); // <-- FIX

      // Assign the .name property from each object
      if (_startPoint != null) {
        newStartAddress = addresses.first.name; // <-- FIX
        if (_destinationPoint != null) {
          newDestAddress = addresses.last.name; // <-- FIX
        }
      } else if (_destinationPoint != null) {
        newDestAddress = addresses.first.name; // <-- FIX
      }

      if (mounted) {
        setState(() {
          _startAddress = newStartAddress;
          _destinationAddress = newDestAddress;
        });
        Logger.success(
          "HomeScreen",
          "✅ Addresses updated: '$_startAddress' -> '$_destinationAddress'",
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error getting address from Google Maps Service: $e");
      }
      if (mounted) {
        setState(() {
          _startAddress = "Current Location";
          _destinationAddress = "Selected Destination";
        });
      }
    }
  }

  Future<void> _drawPolyline(
    String id,
    LatLng start,
    LatLng end,
    Color color,
  ) async {
    try {
      final RouteDetails? routeDetails = await _googleMapsService
          .getDirectionsInfo(start, end);

      if (routeDetails != null && mounted) {
        setState(() {
          _polylines.removeWhere((p) => p.polylineId == PolylineId(id));
          _polylines.add(
            Polyline(
              polylineId: PolylineId(id),
              points: routeDetails.points,
              color: color,
              width: 6,
            ),
          );
        });
      } else {
        throw Exception("Failed to get polyline for driver route.");
      }
    } catch (e) {
      if (mounted) {}
    }
  }

  Future<List<LatLng>> _getPolylineFromGoogle(LatLng start, LatLng end) async {
    List<LatLng> polylineCoordinates = [];
    try {
      PolylinePoints polylinePoints = PolylinePoints(
        apiKey: ApiConstants.googleApiKey,
      );

      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: PointLatLng(start.latitude, start.longitude),
          destination: PointLatLng(end.latitude, end.longitude),
          mode: TravelMode.driving,
        ),
      );

      if (result.points.isNotEmpty) {
        polylineCoordinates = result.points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();
      } else if (result.errorMessage != null && mounted) {
        _showErrorSnackBar("Google Directions Error: ${result.errorMessage}");
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(
          "Error fetching polyline from Google: ${e.toString()}",
        );
      }
    }
    return polylineCoordinates;
  }

  // Add this new method inside _HomeScreenState

  int _parseDurationInMinutes(String durationText) {
    try {
      final match = RegExp(r'(\d+)').firstMatch(durationText);
      if (match != null) return int.parse(match.group(1)!);
    } catch (e) {
      if (kDebugMode) print("Error parsing duration text '$durationText': $e");
    }
    return 20;
  }

  void _animateDriverMarker(LatLng newPosition, double newBearing) {
    // If this is the first time we're getting a position, just set it directly.
    if (_lastMarkerPosition == null) {
      setState(() {
        _driverPosition = newPosition;
        _lastMarkerPosition = newPosition;
        _lastMarkerBearing = newBearing;
      });
      _updateMarkers(); // Do a full update once
      return;
    }

    // --- THE NEW LOGIC ---
    // If the animation controller is already running, we don't need to do anything.
    if (_markerAnimationController?.isAnimating ?? false) {
      // We can optionally update the target position mid-animation if needed,
      // but for now, just letting it finish is fine.
    } else {
      // Start the animation from the last known position to the new position.
      _markerAnimationController?.dispose();
      _tripStartedSubscription?.cancel();
      _tripOngoingSubscription?.cancel(); // Dispose the old one first
      _markerAnimationController = AnimationController(
        duration: const Duration(seconds: 2), // Make animation last 2 seconds
        vsync: this,
      );

      final latTween = Tween<double>(
        begin: _lastMarkerPosition!.latitude,
        end: newPosition.latitude,
      );
      final lngTween = Tween<double>(
        begin: _lastMarkerPosition!.longitude,
        end: newPosition.longitude,
      );
      final bearingTween = Tween<double>(
        begin: _lastMarkerBearing ?? 0.0,
        end: newBearing,
      );

      // This is the important part: The listener updates the state variables
      // BUT DOES NOT CALL SETSTATE.
      _markerAnimationController!.addListener(() {
        _driverPosition = LatLng(
          latTween.evaluate(_markerAnimationController!),
          lngTween.evaluate(_markerAnimationController!),
        );
        _lastMarkerBearing = bearingTween.evaluate(_markerAnimationController!);

        // We still need to tell the UI to rebuild, but we'll do it differently.
        // Forcing a rebuild here would bring back the flood.
        // The AnimatedBuilder in the build method will handle this.
      });

      _markerAnimationController!.forward().whenComplete(() {
        // When the animation is done, update the final position.
        _lastMarkerPosition = newPosition;
        _markerAnimationController!.dispose();
        _markerAnimationController = null;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ✅ REPLACE THE ENTIRE METHOD

  Future<void> _handleMapTap(LatLng position) async {
    // --- 1. Log the initial state ---
    debugPrint(
      "🏁 [Map Tap] Tap detected → lat: ${position.latitude}, lng: ${position.longitude}",
    );
    debugPrint(
      "🔎 [Map Tap] Current State: $_currentMapState | PickingMode: $_pickingMode | Contract Stage: $_contractPickStage",
    );

    // --- 2. Handle Explicit "Pick on Map" Mode (e.g., for saving places) ---
    if (_pickingMode != MapPickingMode.none) {
      debugPrint(
        "🎯 [Map Tap] Handling explicit 'Pick on Map' mode: $_pickingMode",
      );
      if (_isPanelVisible) {
        setState(() => _isPanelVisible = false);
      }
      await _handleMapTapForSaving(position);
      return; // Stop further execution
    }

    // --- 3. Handle Taps during Contract Route Picking ---
    if (_currentMapState == MapState.contractRoutePicking) {
      debugPrint("📄 [Map Tap] Handling 'Contract Route Picking'...");
      try {
        final place = await _getPlaceDetailsFromTap(position);
        debugPrint("📍 [Map Tap] Fetched place: ${place.primaryText}");

        if (_contractPickStage == 'pickup') {
          debugPrint("🟢 [Contract Flow] Setting PICKUP location.");
          setState(() {
            _startPlace = place;
            _startPoint = place.coordinates;
            _startAddress = place.primaryText;
            _contractPickStage = 'destination'; // CRITICAL: Move to next stage
          });
          _updateMarkers();
          _showSuccessSnackBar(
            "✅ Pickup set! Now tap to select your destination.",
          );
          final controller = await _mapController.future;
          controller.animateCamera(
            CameraUpdate.newLatLngZoom(place.coordinates, 16.0),
          );
        } else if (_contractPickStage == 'destination') {
          debugPrint("🔴 [Contract Flow] Setting DESTINATION location.");
          // VALIDATION: Ensure we have the necessary data before proceeding.
          if (_startPoint == null || _selectedContractForCreation == null) {
            throw Exception(
              "Invalid state: _startPoint is null or no contract is selected for creation.",
            );
          }

          debugPrint(
            "✅ [Validation] State is valid. Navigating to CreateSubscriptionScreen...",
          );

          // Hide the picker panel before navigating to avoid UI glitches.
          setState(() {
            _currentMapState = MapState.discovery;
          });
          await Future.delayed(
            const Duration(milliseconds: 50),
          ); // Allow UI to update

          // Navigate and wait for the result.
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CreateSubscriptionScreen(
                contractId: _selectedContractForCreation!.id,
                contractType: _selectedContractForCreation!.contractType,
                startAddress: _startAddress,
                destinationAddress: place.primaryText,
                startPoint: _startPoint!,
                destinationPoint: place.coordinates,
              ),
            ),
          );

          debugPrint(
            "✅ [Contract Flow] Returned from CreateSubscriptionScreen. Resetting state.",
          );
          // CRITICAL: Reset the entire state ONLY after returning from the next screen.
          _resetMapState();
        }
      } catch (e, stackTrace) {
        debugPrint(
          "❌ [ERROR] An error occurred during contract route picking: $e",
        );
        debugPrint("🧩 Stacktrace: $stackTrace");
        _showErrorSnackBar("An error occurred. Please start over.");
        _resetMapState(); // Reset state on any failure
      }
      return; // Stop further execution
    }

    // --- 4. Handle Taps in Other Standard Modes (Planning, Discovery) ---
    try {
      if (_currentMapState == MapState.planning) {
        debugPrint("🗺️ [Map Tap] Updating destination in 'Planning' mode.");
        final GoogleMapController controller = await _mapController.future;
        final double currentZoom = await controller.getZoomLevel();
        await _planOrUpdateRoute(
          position,
          start: _startPoint,
          currentZoom: currentZoom,
        );
      } else if (_currentMapState == MapState.discovery) {
        debugPrint(" discovery mode.");
        if (_startPoint == null) {
          _showErrorSnackBar("Cannot plan route: current location is unknown.");
          return;
        }
        final GoogleMapController controller = await _mapController.future;
        final double currentZoom = await controller.getZoomLevel();
        await _planOrUpdateRoute(
          position,
          start: _startPoint,
          currentZoom: currentZoom,
        );
      }
    } catch (e, stackTrace) {
      debugPrint(
        "❌ [ERROR] An error occurred during standard map tap handling: $e",
      );
      debugPrint("🧩 Stacktrace: $stackTrace");
      _showErrorSnackBar("Could not process map tap. Please try again.");
    }
  }

  void _startContractRideFlow() {
    setState(() {
      _currentMapState = MapState.contractSelection;
      _isPanelVisible = true;
    });
  }

  Future<void> _onContractSelected(Subscription subscription) async {
    // --- ✅ CORRECTED DEBUGGING BLOCK ---
    final jsonEncoder = JsonEncoder.withIndent('  ');
    final prettyJson = jsonEncoder.convert(subscription.toJson());

    debugPrint("==========================================================");

    debugPrint(prettyJson);
    debugPrint("----------------------------------------------------------");
    debugPrint("  Start Point: ${subscription.startPoint}");
    debugPrint("  Destination Point: ${subscription.destinationPoint}");
    // ✅ STEP 1: Always check for location data first.
    if (subscription.startPoint == null ||
        subscription.destinationPoint == null) {
      _showErrorSnackBar(
        "This subscription is missing location data and cannot be used for booking.",
      );
      return;
    }

    // ✅ STEP 2: Now, check for the driver assignment.
    if (subscription.driverId == null || subscription.driverId!.isEmpty) {
      debugPrint("  Driver ID: ${subscription.driverId}");
      _showSuccessSnackBar(
        "Wait until a driver is assigned to this subscription.",
      );
      return;
    }

    // If both checks pass, we can proceed.
    debugPrint("  Driver ID: ${subscription.driverId}");
    debugPrint("==========================================================");

    setState(() {
      _selectedSubscription = subscription;
      _startPoint = subscription.startPoint;
      _destinationPoint = subscription.destinationPoint;
      _startAddress = subscription.pickupLocation;
      _destinationAddress = subscription.dropoffLocation;
      _currentMapState = MapState.contractRideConfirmation;
    });

    // Draw the pre-defined route on the map
    await _drawPolyline(
      'contract_route',
      _startPoint!,
      _destinationPoint!,
      Colors.purple,
    );
    _animateCameraToFitBounds(_startPoint!, _destinationPoint!);
    _updateMarkers();
  }

  void _printModelData() {
    debugPrint("=== MODEL DATA DEBUG PRINT ===");

    // Print selected subscription details
    if (_selectedSubscription == null) {
      debugPrint("❌ _selectedSubscription: NULL");
    } else {
      debugPrint("✅ _selectedSubscription:");
      debugPrint("  • ID: ${_selectedSubscription!.id}");
      debugPrint("  • Contract ID: ${_selectedSubscription!.contractId}");
      debugPrint(
        "  • Contract Type ID: ${_selectedSubscription!.contractTypeId}",
      );
      debugPrint("  • Passenger ID: ${_selectedSubscription!.passengerId}");
      debugPrint("  • Passenger Name: ${_selectedSubscription!.passengerName}");
      debugPrint(
        "  • Passenger Phone: ${_selectedSubscription!.passengerPhone}",
      );
      debugPrint(
        "  • Passenger Email: ${_selectedSubscription!.passengerEmail}",
      );
      debugPrint("  • Pickup: ${_selectedSubscription!.pickupLocation}");
      debugPrint("  • Dropoff: ${_selectedSubscription!.dropoffLocation}");
      debugPrint(
        "  • Pickup Coords: (${_selectedSubscription!.pickupLatitude}, ${_selectedSubscription!.pickupLongitude})",
      );
      debugPrint(
        "  • Dropoff Coords: (${_selectedSubscription!.dropoffLatitude}, ${_selectedSubscription!.dropoffLongitude})",
      );
      debugPrint("  • Contract Type: ${_selectedSubscription!.contractType}");
      debugPrint("  • Start Date: ${_selectedSubscription!.startDate}");
      debugPrint("  • End Date: ${_selectedSubscription!.endDate}");
      debugPrint("  • Fare: ${_selectedSubscription!.fare}");
      debugPrint("  • Final Fare: ${_selectedSubscription!.finalFare}");
      debugPrint("  • Distance: ${_selectedSubscription!.distanceKm} km");
      debugPrint("  • Status: ${_selectedSubscription!.status}");
      debugPrint("  • Payment Status: ${_selectedSubscription!.paymentStatus}");

      // Print assigned driver details
      if (_selectedSubscription!.assignedDriver == null) {
        debugPrint("  • Assigned Driver: NULL");
      } else {
        final driver = _selectedSubscription!.assignedDriver!;
        debugPrint("  • Assigned Driver:");
        debugPrint("    - Driver ID: ${driver.driverId}");
        debugPrint("    - Driver Name: ${driver.driverName}");
        debugPrint("    - Driver Phone: ${driver.driverPhone}");
        debugPrint("    - Driver Email: ${driver.driverEmail}");

        if (driver.vehicleInfo == null) {
          debugPrint("    - Vehicle Info: NULL");
        } else {
          final vehicle = driver.vehicleInfo!;
          debugPrint("    - Vehicle Info:");
          debugPrint("      * Model: ${vehicle.model}");
          debugPrint("      * Plate: ${vehicle.plate}");
          debugPrint("      * Color: ${vehicle.color}");
        }
      }
    }

    // Print passenger profile
    if (_passengerProfile == null) {
      debugPrint("❌ _passengerProfile: NULL");
    } else {
      debugPrint("✅ _passengerProfile:");
      debugPrint("  • ID: ${_passengerProfile!.id}");
      // Add other passenger profile fields you have
    }

    // Print current booking state
    debugPrint("=== BOOKING STATE ===");
    debugPrint("  • _isBooking: $_isBooking");
    debugPrint("  • _currentBookingId: $_currentBookingId");
    debugPrint("  • _currentMapState: $_currentMapState");

    debugPrint("=== END MODEL DATA ===");
  }

  // ✅✅✅ --- THIS IS THE CORRECT VERSION BASED ON THE NEW POSTMAN FILE --- ✅✅✅
  Future<void> _confirmContractRide() async {
    if (_selectedSubscription == null || _passengerProfile == null) {
      _showErrorSnackBar("Critical data is missing. Please restart the app.");
      return;
    }

    setState(() => _isBooking = true);

    try {
      final initialDriver = _selectedSubscription!.assignedDriver;

      // ✅ FIX: Pass the SUBSCRIPTION'S ID from the selected subscription.
      debugPrint(
        "Fetching full driver details for subscription ID: ${_selectedSubscription!.id}",
      );
      final fullDriverDetails = await _apiService.getContractAssignedDriver(
        _selectedSubscription!.id, // <-- THIS IS THE CORRECT ID TO PASS
      );

      if (fullDriverDetails == null) {
        throw ApiException(
          "Could not confirm driver details for this ride. Please contact support.",
        );
      }

      final finalMergedDriver = fullDriverDetails.copyWith(
        vehicleInfo:
            fullDriverDetails.vehicleInfo ?? initialDriver?.vehicleInfo,
      );

      final Trip createdTrip = await _apiService.requestContractRide(
        subscriptionId: _selectedSubscription!.id,
        passengerId: _passengerProfile!.id.toString(),
      );

      if (!mounted) return;

      setState(() {
        _selectedSubscription = _selectedSubscription!.copyWith(
          assignedDriver: finalMergedDriver,
        );
        _currentBookingId = createdTrip.id; // <--- FIX IS HERE
        _currentMapState = MapState.contractDriverOnTheWay;
        ;
      });
      _showErrorSnackBar(
        "Your contract driver is on the way!",
      ); // Changed to _showErrorSnackBar from your code
    } on ApiException catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.message);
        _resetMapState();
      }
    } finally {
      if (mounted) {
        setState(() => _isBooking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red.shade700, fontSize: 16),
            ),
          ),
        ),
      );
    }
    final Set<Marker> currentMarkers = {};

    // --- Logic for Discovery Mode (Simulated Drivers) ---
    if (_currentMapState == MapState.discovery && _carIcon != null) {
      for (final driver in _nearbyDrivers) {
        currentMarkers.add(
          Marker(
            markerId: MarkerId('driver-${driver.id}'),
            position: driver.position,
            icon: _carIcon!,
            rotation: driver.bearing ?? 0.0,
            flat: true,
            anchor: const Offset(0.5, 0.5),
            onTap: () {
              _infoWindowDismissTimer?.cancel();
              _selectedDriverNotifier.value = driver;
              _infoWindowDismissTimer = Timer(const Duration(seconds: 4), () {
                _selectedDriverNotifier.value = null;
              });
            },
          ),
        );
      }
    }
    // --- Logic for All Other Modes (Pickup, Destination, Assigned Driver) ---
    else {
      if (_startPoint != null) {
        currentMarkers.add(
          Marker(
            markerId: const MarkerId('startLocation'),
            position: _startPoint!,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
            infoWindow: const InfoWindow(title: 'Pickup Location'),
          ),
        );
      }
      if (_destinationPoint != null) {
        currentMarkers.add(
          Marker(
            markerId: const MarkerId('destinationLocation'),
            position: _destinationPoint!,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
            infoWindow: const InfoWindow(title: 'Destination'),
          ),
        );
      }
      if ((_currentMapState == MapState.driverOnTheWay ||
              _currentMapState == MapState.ongoingTrip) &&
          _driverPosition != null &&
          _carIcon != null) {
        final driverId = _assignedDriverDetails?.id ?? 'assigned-driver';
        currentMarkers.add(
          Marker(
            markerId: MarkerId('driver-$driverId'),
            position: _driverPosition!,
            icon: _carIcon!,
            rotation: _lastMarkerBearing ?? 0.0,
            flat: true,
            anchor: const Offset(0.5, 0.5),
          ),
        );
      }
    }

    // Logic for the tapped point marker (when picking a location)
    if (_tappedPointMarker != null) {
      currentMarkers.add(_tappedPointMarker!);
    }
    // --- END OF NEW MARKER LOGIC ---

    return WillPopScope(
      onWillPop: () async {
        // --- ADD THIS NEW BLOCK ---
        if (_currentMapState == MapState.search) {
          setState(() {
            _currentMapState = MapState.discovery;
          });
          return false; // This prevents the app from closing
        }
        if (_pickingMode != MapPickingMode.none) {
          setState(() => _pickingMode = MapPickingMode.none);
          return false;
        }
        if (_tappedPlaceDetails != null) {
          setState(() {
            _tappedPlaceDetails = null;
            _tappedPointMarker = null;
          });
          return false;
        }
        if (_isPanelVisible) {
          _resetMapState();
          return false;
        }
        return true;
      },
      child: Scaffold(
        key: _scaffoldKey,
        drawer: AppDrawer(
          passengerProfile: _passengerProfile,
          onEditProfile: () {
            Navigator.of(context).pop();
            _navigateToEditProfile();
          },

          onViewHistory: () {
            Navigator.of(context).pop();
            _navigateToHistory();
          },
          onSoftLogout: () async {
            Navigator.of(context).pop(); // Close drawer first
            await _authService.logout(hard: false);
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const PassengerLoginScreen(),
                ),
                (route) => false,
              );
            }
          },
          onHardLogout: () async {
            Navigator.of(context).pop(); // Close drawer first
            await _authService.logout(hard: true);
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const PassengerLoginScreen(),
                ),
                (route) => false,
              );
            }
          },
        ),

        body: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: _addisAbabaCenter,
                zoom: 12,
              ),
              onMapCreated: (GoogleMapController controller) {
                print("🗺️ Google Map Created and is ready.");
                if (!_mapController.isCompleted) {
                  _mapController.complete(controller);
                }
                try {
                  // ✅ THIS NOW USES YOUR NEW DEFAULT a
                  if (_currentMapStyle != null) {
                    controller.setMapStyle(_currentMapStyle);
                  }
                } catch (e) {
                  print("   L-- 🚨 Error setting map style: $e");
                }
              },
              polylines: _polylines,
              circles: _buildSearchCircle(),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              mapType: _currentMapType,
              zoomControlsEnabled: false,
              zoomGesturesEnabled: true,
              markers: currentMarkers,
              // --- âœ… THIS IS THE MAIN FIX ---
              onTap: _handleMapTap,
            ),

            ValueListenableBuilder<NearbyDriver?>(
              valueListenable: _selectedDriverNotifier,
              builder: (context, selectedDriver, child) {
                if (selectedDriver != null) {
                  return AdvancedDriverInfoWindow(
                    driver: selectedDriver,
                    onClose: () {
                      // Simply set the driver to null to hide the window
                      _selectedDriverNotifier.value = null;
                    },
                    onSelect: () {
                      print(
                        "Driver ${selectedDriver.id} selected. Planning route...",
                      );
                      // Hide the info window
                      _selectedDriverNotifier.value = null;

                      // A great user experience is to now ask "Where to?"
                      // This navigates the user to pick their destination.
                      _navigateToSearchScreen();
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            Positioned(
              bottom: 200, // Adjust position as needed
              left: 20,

              child: Visibility(
                visible:
                    _currentMapState == MapState.discovery && !_isPanelVisible,
                child: FadeInUp(
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Center the button
                    children: [
                      ElevatedButton.icon(
                        onPressed: _startContractRideFlow,
                        icon: const Icon(
                          // Keep this const for performance
                          Icons.document_scanner_outlined,
                          color: Colors.white,
                        ),
                        label: Text(
                          l10n.contractDetails,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.blueAccent, // A different color
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(28)),
                          ),
                          fixedSize: const Size.fromHeight(56),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            MapOverlayButtons(
              onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
              onGpsTap: _goToCurrentUserLocation,
              onLayersTap: _showMapTypeSelector,
              // --- âœ… THIS IS THE FIX for the cancel button ---
              showCancel:
                  _isPanelVisible ||
                  _pickingMode != MapPickingMode.none ||
                  _tappedPlaceDetails != null,
              onCancelTap: () {
                if (_pickingMode != MapPickingMode.none ||
                    _tappedPlaceDetails != null) {
                  setState(() {
                    _pickingMode = MapPickingMode.none;
                    _tappedPlaceDetails = null;
                    _tappedPointMarker = null;
                  });
                } else if (_currentMapState == MapState.searchingForDriver ||
                    _currentMapState == MapState.driverOnTheWay ||
                    _currentMapState == MapState.ongoingTrip) {
                  _cancelBooking();
                } else {
                  _resetMapState();
                }
              },
            ),
            if (_currentMapState == MapState.contractRoutePicking)
              ContractLocationPickerPanel(
                stage: _contractPickStage,
                googleMapsService: _googleMapsService,
                onCancel: _resetMapState,
                onPlaceSelected: (place) {
                  // 👈 THIS IS THE CALLBACK
                  if (_contractPickStage == 'pickup') {
                    setState(() {
                      _startPlace = place;
                      _startPoint = place.coordinates; // <-- This SHOULD work
                      _startAddress = place.primaryText;
                      _contractPickStage = 'destination';
                    });
                    _updateMarkers();
                    // Animate map to the selected pickup location
                    _mapController.future.then(
                      (c) => c.animateCamera(
                        CameraUpdate.newLatLngZoom(place.coordinates, 16.0),
                      ),
                    );
                  } else {
                    // destination stage
                    if (_startPoint != null &&
                        _selectedContractForCreation != null) {
                      // We now have both pickup and destination, navigate to the confirmation screen
                      Navigator.of(context)
                          .push(
                            MaterialPageRoute(
                              builder: (context) => CreateSubscriptionScreen(
                                contractId: _selectedContractForCreation!.id,
                                contractType:
                                    _selectedContractForCreation!.contractType,
                                startAddress: _startAddress,
                                destinationAddress: place.primaryText,
                                startPoint: _startPoint!,
                                destinationPoint: place.coordinates,
                              ),
                            ),
                          )
                          .then((_) {
                            // After returning from the create subscription screen, reset everything
                            _resetMapState();
                          });
                    }
                  }
                },
              ),
            if (_currentMapState == MapState.search)
              // Full-screen search panel
              SearchPanel(
                key: const ValueKey('search_screen'),
                googleApiKey: ApiConstants.googleApiKey,
                initialStart: _startPlace,
                initialEnd: _endPlace,
                onPlaceSelected: _onPlaceSelectedFromSearch,
                onPickOnMap: _onPickOnMapRequested,
                // The onSavedPlaceTap parameter has been removed.
                onBack: () {
                  setState(() {
                    _currentMapState = MapState.discovery;
                  });
                },
              )
            else if (_isPanelVisible &&
                _currentMapState != MapState.contractRoutePicking)
              // All other panels (planning, driver info, rating, etc.)
              DraggableScrollableSheet(
                key: ValueKey('draggable_sheet_$_currentMapState'),
                initialChildSize: 0.4,
                minChildSize: 0.25,
                maxChildSize: 0.85,
                builder: (context, scrollController) {
                  return _RideBookingPanelContent(
                    scrollController: scrollController,
                    mapState: _currentMapState,
                    onSearchTap: () =>
                        setState(() => _currentMapState = MapState.search),
                    startPoint: _startPoint,
                    destinationPoint: _destinationPoint,
                    estimatedTime: _estimatedTime,
                    estimatedDistance: _estimatedDistance,
                    startAddress: _startAddress,
                    onConfirmDropoff: _confirmContractDropoff,
                    isContractTripOngoing: _isContractTripOngoing,
                    destinationAddress: _destinationAddress,
                    eta: _etaToPickup,
                    isBooking: _isBooking,
                    isRatingSubmitting: _isRatingSubmitting,
                    rideOptionsError: _rideOptionsError,
                    vehicleTypes: _vehicleTypes,
                    selectedRideIndex: _selectedRideOptionIndex,
                    driverDetails: _assignedDriverDetails,
                    activeBooking: _activeBooking,
                    vehicleDetails: _assignedVehicleDetails,
                    postTripRating: _postTripRating,
                    postTripCommentController: _postTripCommentController,
                    userLocation: _startPoint,
                    onConfirmRide: _confirmRide,
                    onCancelSearch: _cancelBooking,
                    onProfileTap: _navigateToEditProfile,
                    onCancelRide: _cancelBooking,
                    onContactDriver: () {},
                    onOpenChat: _contactDriverViaSms,
                    onSkipRating: _resetMapState,
                    onSubmitRating: _submitDriverRating,
                    onVehicleSelected: (index) =>
                        setState(() => _selectedRideOptionIndex = index),
                    isLoadingRideOptions: _isLoadingRideOptions,
                    onRatingChanged: (rating) =>
                        setState(() => _postTripRating = rating),
                    onPlanRoute: (coords) => _planOrUpdateRoute(coords),
                    onEnterPickingMode: (mode) {
                      setState(() {
                        _pickingMode = mode;
                        _isPanelVisible = false;
                      });
                    },
                    fareEstimates: _fareEstimates,
                    finalFare: _finalFare,
                    finalDistanceKm: _finalDistanceKm,
                    etaToDestination: _etaToDestination,
                    selectedTip: _selectedTipAmount,
                    selectedTags: _selectedFeedbackTags,
                    onTipSelected: (tip) {
                      setState(
                        () => _selectedTipAmount = (_selectedTipAmount == tip)
                            ? 0.0
                            : tip,
                      );
                    },
                    onTagTapped: (tag) {
                      setState(() {
                        if (_selectedFeedbackTags.contains(tag)) {
                          _selectedFeedbackTags.remove(tag);
                        } else {
                          _selectedFeedbackTags.add(tag);
                        }
                      });
                    },
                    onPlaceSelected: _onPlaceSelectedFromSearch,
                    onPickOnMap: _onPickOnMapRequested,
                    onBackFromSearch: () =>
                        setState(() => _currentMapState = MapState.discovery),
                    startPlaceDetails: _startPlace,
                    endPlaceDetails: _endPlace,
                    onSavedPlaceTap: (place) {
                      _planOrUpdateRoute(
                        place.coordinates,
                        destinationName: place.primaryText,
                      );
                    },
                    availableContracts: _availableContracts,
                    isLoadingContracts: _isLoadingContracts,
                    contractsError: _contractsError,
                    onContractSelected: _handleContractSelected,
                    onSubscriptionSelected: _onContractSelected,
                    onConfirmContractRide: _confirmContractRide,
                    selectedSubscription: _selectedSubscription,
                    onSelectNewContractType: _startNewContractCreationFlow,
                    onCreateNewSubscription: () {
                      if (_availableContracts.isNotEmpty) {
                        // Default to creating the first available contract type
                        _startNewContractCreationFlow(
                          _availableContracts.first,
                        );
                      }
                    },
                    contractPickStage: _contractPickStage,
                  );
                },
              ),
            AdvancedRadiusSlider(
              isVisible:
                  _currentMapState == MapState.discovery && !_isPanelVisible,
              currentRadiusKm: _searchRadiusKm,
              onRadiusChanged: (newRadius) {
                setState(() {
                  _searchRadiusKm = newRadius;
                });
                // ✅ --- CONNECT THE SLIDER TO THE SIMULATOR ---
                // Instantly tell the manager about the new radius.
                _nearbyDriverSimulatorManager?.updateSearchRadius(newRadius);
              },
              onSearchInitiated: (finalRadius) {
                // This callback is now less important for the simulation, but we can
                // keep it for future use (e.g., if you switch back to real API calls).
                // For now, we can just ensure the final radius is set.
                _nearbyDriverSimulatorManager?.updateSearchRadius(finalRadius);
              },
            ),
            if ((_pickingMode == MapPickingMode.setDestination ||
                    _pickingMode == MapPickingMode.setHome) &&
                _tappedPlaceDetails == null)
              Positioned(
                top: MediaQuery.of(context).padding.top + 20,
                left: 20,
                right: 20,
                child: FadeInDown(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.touch_app_rounded,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _pickingMode == MapPickingMode.setDestination
                                  ? AppLocalizations.of(
                                      context,
                                    )!.mapSetDestination
                                  : AppLocalizations.of(context)!.mapSetPickup,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 200,

              right: 20,
              child: Visibility(
                visible:
                    _currentMapState == MapState.discovery && !_isPanelVisible,
                child: FadeInUp(
                  child: Row(
                    children: [
                      // --- The Blue "Where to?" Button ---

                      // --- The Pink "Offline Order" Button ---
                      ElevatedButton.icon(
                        onPressed: _navigateToOfflineSmsScreen,
                        icon: const Icon(
                          Icons.sms_outlined,
                          color: Colors.white,
                        ),
                        label: Text(
                          AppLocalizations.of(
                            context,
                          )!.offline, // A shorter label, add to your l10n file
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.hotPink,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(28)),
                          ),
                          fixedSize: const Size.fromHeight(56),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            if (_currentMapState == MapState.discovery &&
                !_isPanelVisible &&
                _tappedPlaceDetails == null)
              Positioned(
                bottom: 24,
                left: 20,
                right: 20,
                child: FadeInUp(
                  child: GestureDetector(
                    onTap: () {
                      _nearbyDriverSimulatorManager
                          ?.stop(); // Stop the simulation first
                      setState(
                        () => _isPanelVisible = true,
                      ); // Then update the state
                    },

                    child: Container(
                      padding: const EdgeInsets.only(
                        left: 20,
                        top: 4,
                        bottom: 4,
                        right: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 2,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search_rounded,
                            color: AppColors.goldenrod,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _startPoint != null
                                  ? AppLocalizations.of(context)!.whereTo
                                  : AppLocalizations.of(
                                      context,
                                    )!.findingYourLocation,
                              style: const TextStyle(
                                fontSize: 20,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          CircularButton(
                            icon: Icons.person_outline_rounded,
                            onTap: _navigateToEditProfile,
                            backgroundColor: Colors.white,
                            iconColor: Colors.grey.shade700,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            if (_tappedPlaceDetails != null)
              LocationPreviewPanel(
                place: _tappedPlaceDetails!,
                pickingMode: _pickingMode,
                canGoToDestination: _startPoint != null,

                // Context-aware state
                existingPickup: _startPoint,
                existingDestination: _destinationPoint,
                isPickupSet: _startPoint != null,
                isDestinationSet: _destinationPoint != null,

                // Pickup/Destination callbacks
                // In lib/screens/home_screen.dart -> inside the build method, find the LocationPreviewPanel widget, and update its 'onConfirmPickup' callback:
                onConfirmPickup: () {
                  final tappedCoords = _tappedPlaceDetails!.coordinates;
                  final tappedAddress = _tappedPlaceDetails!.primaryText;

                  setState(() {
                    _startPoint = tappedCoords;
                    _startAddress = tappedAddress;
                    _tappedPlaceDetails = null;
                    _tappedPointMarker = null;
                    _pickingMode = MapPickingMode.none; // Reset picking mode
                    _proximityAlertsTriggered.updateAll((key, value) => false);

                    // CRITICAL: Update _startPlace here so SearchPanel gets the new pickup
                    _startPlace = PlaceDetails(
                      primaryText: _startAddress,
                      secondaryText: AppLocalizations.of(
                        context,
                      )!.setPickup, // Use localized string
                      coordinates: _startPoint!,
                      placeId:
                          'picked_pickup_${_startPoint!.latitude}_${_startPoint!.longitude}',
                    );
                  });

                  if (_destinationPoint != null) {
                    // If destination is already set, replan the route with the new pickup
                    _planOrUpdateRoute(_destinationPoint!, start: tappedCoords);
                  } else {
                    _showSuccessSnackBar(
                      AppLocalizations.of(context)!.setPickupFirst,
                    );
                    // If destination is not set, transition to the search screen to prompt for it.
                    setState(() {
                      _currentMapState = MapState.search;
                      _isPanelVisible = true;
                      // The SearchPanel will implicitly use _startPlace which is now updated.
                    });
                  }
                },

                // In lib/screens/home_screen.dart -> inside the build method, find the LocationPreviewPanel widget, and update its 'onConfirmDestination' callback:
                onConfirmDestination: () {
                  final tappedCoords = _tappedPlaceDetails!.coordinates;
                  final tappedAddress = _tappedPlaceDetails!.primaryText;

                  setState(() {
                    _destinationPoint = tappedCoords;
                    _destinationAddress = tappedAddress;
                    _tappedPlaceDetails = null;
                    _tappedPointMarker = null;
                    _pickingMode = MapPickingMode.none; // Reset picking mode
                    // Also update _endPlace when setting destination from map pick
                    _endPlace = PlaceDetails(
                      primaryText: _destinationAddress,
                      secondaryText: AppLocalizations.of(
                        context,
                      )!.setAsDestination, // Use localized string
                      coordinates: _destinationPoint!,
                      placeId:
                          'picked_destination_${_destinationPoint!.latitude}_${_destinationPoint!.longitude}',
                    );
                  });

                  if (_startPoint != null) {
                    // If pickup is already set, plan the route with the new destination
                    _planOrUpdateRoute(tappedCoords, start: _startPoint);
                  } else {
                    _showSuccessSnackBar(
                      AppLocalizations.of(context)!.setAsDestination,
                    );
                    // If pickup is not set, the panel will close and the user is still in discovery,
                    // so they can then set the pickup.
                  }
                },
                // --- IMPORTANT: Ensure all other 'onSave' callbacks also reset _tappedPlaceDetails, _tappedPointMarker, and _pickingMode ---
                onSaveHome: () {
                  final provider = context.read<SavedPlacesProvider>();
                  provider.saveHome(
                    SavedPlace.fromPlaceDetails(_tappedPlaceDetails!),
                  );
                  _showSuccessSnackBar("Home location saved!");
                  setState(() {
                    _tappedPlaceDetails = null;
                    _tappedPointMarker = null;
                    _pickingMode = MapPickingMode.none; // Reset picking mode
                  });
                },

                onSaveWork: () {
                  final provider = context.read<SavedPlacesProvider>();
                  provider.saveWork(
                    SavedPlace.fromPlaceDetails(_tappedPlaceDetails!),
                  );
                  _showSuccessSnackBar("Work location saved!");
                  setState(() {
                    _tappedPlaceDetails = null;
                    _tappedPointMarker = null;
                    _pickingMode = MapPickingMode.none; // Reset picking mode
                  });
                },

                onAddFavorite: () {
                  final provider = context.read<SavedPlacesProvider>();
                  provider.addFavorite(
                    SavedPlace.fromPlaceDetails(_tappedPlaceDetails!),
                  );
                  _showSuccessSnackBar("Added to favorites!");
                  setState(() {
                    _tappedPlaceDetails = null;
                    _tappedPointMarker = null;
                    _pickingMode = MapPickingMode.none; // Reset picking mode
                  });
                },

                onGoToDestination: () {
                  _planOrUpdateRoute(_tappedPlaceDetails!.coordinates);
                  setState(() {
                    _tappedPlaceDetails = null;
                    _tappedPointMarker = null;
                    _pickingMode = MapPickingMode.none; // Reset picking mode
                  });
                },

                onClear: () => setState(() {
                  _tappedPlaceDetails = null;
                  _tappedPointMarker = null;
                  _pickingMode =
                      MapPickingMode.none; // Reset picking mode on clear
                }),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapTypeTile(
    String title,
    IconData icon,
    MapType mapType,
    String? style,
  ) {
    // Determine if this tile is the currently selected one.
    bool isSelected = false;
    if (mapType == MapType.hybrid && _currentMapType == MapType.hybrid) {
      // This is the satellite view.
      isSelected = true;
    } else if (mapType == MapType.normal && _currentMapType == MapType.normal) {
      // This is a normal view (light or dark). Check our state variable.
      isSelected = (_currentMapStyle == style);
    }

    return ListTile(
      leading: Icon(icon, color: AppColors.goldenrod),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Colors.greenAccent)
          : null,
      onTap: () async {
        Navigator.of(context).pop(); // Close the dialog
        final controller = await _mapController.future;

        setState(() {
          _currentMapType = mapType;
          _currentMapStyle =
              style; // Update our state variable with the new style
        });

        // Apply the style. `null` is passed for satellite view, which clears any custom style.
        await controller.setMapStyle(style);
      },
    );
  }

  Set<Circle> _buildSearchCircle() {
    final circles = <Circle>{};

    // Only show the circle if we have a location and are in discovery/searching mode
    if (_startPoint == null ||
        (_currentMapState != MapState.discovery &&
            _currentMapState != MapState.searchingForDriver)) {
      return circles;
    }

    // Determine the color based on the current map state
    final Color circleColor = _currentMapState == MapState.searchingForDriver
        ? Colors.blue.shade600
        : Colors.green.shade600;

    final double radiusInMeters = _searchRadiusKm * 1000;

    // Add a single, static, filled circle
    circles.add(
      Circle(
        circleId: const CircleId('search_radius_filled'),
        center: _startPoint!,
        radius: radiusInMeters,
        // Use a semi-transparent fill color to see the map underneath
        fillColor: circleColor.withValues(alpha: 0.2),
        // Set strokeWidth to 0 for no border
        strokeWidth: 0,
      ),
    );

    return circles;
  }
} // This is the closing brace for the _HomeScreenState class

// âœ… Make sure this typedef is defined above the class
typedef OnEnterPickingMode = void Function(MapPickingMode mode);
typedef OnSavedPlaceTap = void Function(SavedPlace place);

class _RideBookingPanelContent extends StatelessWidget {
  final VoidCallback onConfirmDropoff; // <-- ADD THIS
  final bool isContractTripOngoing; // <-- ADD THIS
  final ScrollController scrollController;
  final MapState mapState;
  final LatLng? startPoint;
  final LatLng? destinationPoint;
  final String estimatedTime;
  final String estimatedDistance;
  final String startAddress;
  final String destinationAddress;
  final String eta;
  final bool isBooking;
  final bool isRatingSubmitting;
  final String? rideOptionsError;
  final List<VehicleType> vehicleTypes;
  final int selectedRideIndex;
  final NearbyDriver? driverDetails;

  final Booking? bookingDetails;
  final Booking? activeBooking;
  final Map<String, dynamic>? vehicleDetails;
  final double postTripRating;
  final TextEditingController postTripCommentController;
  final LatLng? userLocation;

  // --- Callbacks ---
  final VoidCallback onSearchTap;
  final Future<void> Function() onConfirmRide;
  final VoidCallback onCancelSearch;
  final VoidCallback onProfileTap;
  final VoidCallback onCancelRide;
  final VoidCallback onContactDriver;
  final VoidCallback onOpenChat; // ✅ Correctly defined as a property
  final VoidCallback onSkipRating;
  final VoidCallback onSubmitRating;
  final void Function(int) onVehicleSelected;
  final bool isLoadingRideOptions;
  final void Function(double) onRatingChanged;
  final void Function(LatLng) onPlanRoute;
  final OnEnterPickingMode onEnterPickingMode;
  final Map<String, FareEstimate> fareEstimates;
  final double? finalFare; // ✅ ADD THIS
  final double? finalDistanceKm;

  final double selectedTip;
  final Set<String> selectedTags;
  final void Function(double) onTipSelected;
  final void Function(String) onTagTapped; // ✅ ADD THIS
  final OnPlaceSelectedCallback onPlaceSelected;
  final OnPickOnMapCallback onPickOnMap;
  final VoidCallback onBackFromSearch;
  final PlaceDetails? startPlaceDetails;
  final PlaceDetails? endPlaceDetails;

  // ✅ ADD THIS
  final OnSavedPlaceTap onSavedPlaceTap;
  final List<Contract> availableContracts;
  final bool isLoadingContracts;
  final String? contractsError;
  final void Function(Contract) onContractSelected;
  final Function(Subscription) onSubscriptionSelected; // ✅ ADD
  final VoidCallback onConfirmContractRide; // ✅ ADD
  final Subscription? selectedSubscription;
  final VoidCallback onCreateNewSubscription;
  final Function(Contract) onSelectNewContractType;
  final ContractBooking? activeContractBooking;
  final String contractPickStage;
  final String? etaToDestination;

  // ✅ CORRECTED CONSTRUCTOR
  const _RideBookingPanelContent({
    required this.scrollController,
    required this.mapState,
    required this.onSearchTap,
    required this.onConfirmRide,
    required this.onCancelSearch,
    required this.onProfileTap,
    required this.estimatedTime,
    required this.estimatedDistance,
    required this.startAddress,
    required this.destinationAddress,
    required this.eta,
    required this.isLoadingRideOptions,
    required this.isBooking,
    this.rideOptionsError,
    required this.vehicleTypes,
    required this.selectedRideIndex,
    required this.onVehicleSelected,
    this.driverDetails,
    this.activeBooking,
    this.vehicleDetails,
    required this.onCancelRide,
    required this.onContactDriver,
    required this.onOpenChat, // ✅ Correctly part of the constructor
    required this.postTripRating,
    this.startPoint,
    this.destinationPoint,
    required this.onRatingChanged,
    required this.postTripCommentController,
    required this.isRatingSubmitting,
    required this.onSubmitRating,
    required this.onSkipRating,
    required this.onPlanRoute,
    this.userLocation,
    required this.onEnterPickingMode,
    required this.fareEstimates,
    required this.finalFare, // ✅ ADD THIS
    required this.finalDistanceKm, // ✅ ADD THIS

    required this.selectedTip,
    required this.selectedTags,
    required this.onTipSelected,
    required this.onTagTapped,
    required this.onPlaceSelected,
    required this.onPickOnMap,
    required this.onBackFromSearch,
    this.startPlaceDetails,
    this.endPlaceDetails,
    required this.onSavedPlaceTap,

    // ✅ ADD THESE NEW PARAMETERS
    required this.availableContracts,
    required this.isLoadingContracts,
    required this.contractsError,
    required this.onContractSelected,
    required this.onSubscriptionSelected, // ✅ ADD
    required this.onConfirmContractRide, // ✅ ADD
    this.selectedSubscription,
    required this.onCreateNewSubscription, // ✅ ADD
    required this.onSelectNewContractType,
    required this.contractPickStage,
    this.etaToDestination,
    required this.isContractTripOngoing,
    required this.onConfirmDropoff,
  });

  @override
  Widget build(BuildContext context) {
    final List<Color> gradientColors = switch (mapState) {
      MapState.discovery => [AppColors.primaryColor, AppColors.secondaryColor],
      MapState.planning => [AppColors.secondaryColor, const Color(0xFF002266)],
      MapState.searchingForDriver => [
        const Color(0xFF002266),
        const Color(0xFF001133),
      ],
      _ => [AppColors.primaryColor, AppColors.secondaryColor],
    };
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
        boxShadow: [
          BoxShadow(color: Colors.black, blurRadius: 25, spreadRadius: 5),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        controller: scrollController,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0.0, 0.3),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                child: child,
              ),
            );
          },
          child: _buildPanelContent(context),
        ),
      ),
    );
  }

  Widget _buildPanelContent(BuildContext context) {
    switch (mapState) {
      case MapState.discovery:
        return DiscoveryPanelContent(
          key: const ValueKey('discovery'),
          onSearchTap: onSearchTap,
          onProfileTap: onProfileTap,
          userLocation: userLocation,
          onSavedPlaceTap: (place) {
            Provider.of<SavedPlacesProvider>(
              context,
              listen: false,
            ).addRecentSearch(place);
            onPlanRoute(place.coordinates);
          },
          onEnterPickingMode: onEnterPickingMode,
        );

      case MapState.planning:
        return PlanningPanelContent(
          key: ValueKey(
            '${startPoint?.latitude}-${destinationPoint?.latitude}',
          ),
          estimatedTime: estimatedTime,
          estimatedDistance: estimatedDistance,
          isLoadingRideOptions: isLoadingRideOptions,
          onConfirmRide: onConfirmRide,
          rideOptionsError: rideOptionsError,
          vehicleTypes: vehicleTypes,
          selectedRideIndex: selectedRideIndex,
          onVehicleSelected: onVehicleSelected,
          fareEstimates: fareEstimates,
          availableContracts: availableContracts,
          isLoadingContracts: isLoadingContracts,
          contractsError: contractsError,
          onContractSelected: onContractSelected,
        );

      case MapState.searchingForDriver:
        final vehicle = vehicleTypes.isNotEmpty
            ? vehicleTypes[selectedRideIndex]
            : null;
        double price = 0.0;
        if (vehicle != null) {
          final estimate = fareEstimates[vehicle.name.toLowerCase()];
          if (estimate != null) {
            price = estimate.fare;
          }
        }
        return SearchingPanelContent(
          key: const ValueKey('searching'),
          onCancel: onCancelSearch,
          startAddress: startAddress.isEmpty
              ? "Current Location"
              : startAddress,
          destinationAddress: destinationAddress.isEmpty
              ? "Selected Destination"
              : destinationAddress,
          selectedVehicle: vehicle,
          estimatedPrice: price,
        );

      case MapState.driverOnTheWay:
        return DriverOnTheWayPanelContent(
          key: const ValueKey('driver_on_way_panel'),
          booking: activeBooking,
          eta: eta,
          onCancel: onCancelRide,
          onContact: onContactDriver,
          onOpenChat: onOpenChat,
          isTripOngoing: mapState == MapState.ongoingTrip,
        );
      case MapState.contractDriverOnTheWay:
        return ContractDriverOnTheWayPanelContent(
          key: const ValueKey('contract_driver_on_way_panel'),
          subscription: selectedSubscription,
          eta: estimatedTime,
          distance: estimatedDistance,
          onCancel: onCancelRide,
          onContact: onContactDriver,
          onOpenChat: onOpenChat,
          onConfirmDropoff: onConfirmDropoff,
          isTripOngoing: isContractTripOngoing, // <-- USE THE FLAG
        );
      case MapState.ongoingTrip:
        return OngoingTripPanelContent(
          key: const ValueKey('ongoing_trip_panel'),
          booking: activeBooking,
          onOpenChat: onOpenChat,
          // --- THIS IS THE FIX ---
          // Pass the ETA value down to the final panel
          etaToDestination: etaToDestination,
          // ----------------------
          onShareTrip: () {
            print("Share trip tapped!");
          },
        );

      case MapState.postTripRating:
        return PostTripRatingPanelContent(
          key: const ValueKey('rating'),
          driver: driverDetails,
          startAddress: startAddress,
          destinationAddress: destinationAddress,
          finalFare: finalFare,
          finalDistanceKm: finalDistanceKm,
          rating: postTripRating,
          onRatingChanged: onRatingChanged,
          commentController: postTripCommentController,
          selectedTags: selectedTags,
          onTagTapped: onTagTapped,
          isSubmitting: isRatingSubmitting,
          onSubmit: onSubmitRating,
          onSkip: onSkipRating,
        );
      case MapState.contractSelection:
        return ContractModePanel(
          key: const ValueKey('contract_mode'),
          onSubscriptionSelected: onSubscriptionSelected,
          onCancel: onCancelSearch,
          onSelectNewContractType: onSelectNewContractType,
          onCreateNewSubscription: onCreateNewSubscription,
        );
      case MapState.contractRideConfirmation:
        if (selectedSubscription == null) {
          return const Center(
            child: Text("Error: Subscription details missing."),
          );
        }
        return ContractRideConfirmationPanel(
          key: const ValueKey('contract_confirmation'),
          subscription: selectedSubscription!,
          onConfirm: onConfirmContractRide,
          onCancel: onCancelSearch,
          isBooking: isBooking,
        );

      case MapState.contractRoutePicking:
        return ContractLocationPickerPanel(
          key: const ValueKey('contract_location_picker'),
          stage: contractPickStage,
          googleMapsService: GoogleMapsService(
            apiKey: ApiConstants.googleApiKey,
          ),
          onPlaceSelected: (place) => onPlaceSelected(
            place,
            contractPickStage == 'pickup' ? 'start' : 'end',
          ),
          onCancel: onCancelSearch,
        );

      default:
        return const SizedBox.shrink();
    }
  }
}

class CircularButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color iconColor; // <-- ADD THIS to control icon color explicitly

  const CircularButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.backgroundColor = Colors.white,
    this.iconColor = Colors.black54, // <-- ADD a default icon color
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1), // Softer shadow
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor), // <-- USE the new property
      ),
    );
  }
}

class _ChatView extends StatefulWidget {
  final String bookingId;
  final List<BookingNote> notes;
  final String passengerId;
  final Function(String) onSend;

  const _ChatView({
    required this.bookingId,
    required this.notes,
    required this.passengerId,
    required this.onSend,
  });

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollToBottom(animated: false),
    );
  }

  @override
  void didUpdateWidget(covariant _ChatView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If a new message comes in, scroll to the bottom
    if (widget.notes.length > oldWidget.notes.length) {
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animated = true}) {
    if (_scrollController.hasClients) {
      final position = _scrollController.position.maxScrollExtent;
      if (animated) {
        _scrollController.animateTo(
          position,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(position);
      }
    }
  }

  void _handleSend() {
    final message = _textController.text.trim();
    if (message.isNotEmpty) {
      widget.onSend(message);
      _textController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Color(0xFF1a1a2e),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              AppLocalizations.of(context)!.chatWithDriver,

              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 1, color: Colors.white24),

          // Message List
          Expanded(
            child: widget.notes.isEmpty
                ? Center(
                    // AFTER
                    child: Text(
                      AppLocalizations.of(context)!.noMessagesYet,
                      style: const TextStyle(color: Colors.white54),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: widget.notes.length,
                    itemBuilder: (context, index) {
                      final note = widget.notes[index];
                      // Backend uses 'passenger' or 'driver' in the 'sender' field
                      final isMe = note.senderType.toLowerCase() == 'passenger';
                      return _ChatMessageBubble(note: note, isMe: isMe);
                    },
                  ),
          ),

          // Input Area
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white24)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                    ),
                    onSubmitted: (_) => _handleSend(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(
                    Icons.send_rounded,
                    color: AppColors.goldenrod,
                  ),
                  onPressed: _handleSend,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    padding: const EdgeInsets.all(14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessageBubble extends StatelessWidget {
  final BookingNote note;
  final bool isMe;

  const _ChatMessageBubble({required this.note, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe
              ? AppColors.goldenrod.withValues(alpha: 0.9)
              : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isMe
                ? const Radius.circular(20)
                : const Radius.circular(4),
            bottomRight: isMe
                ? const Radius.circular(4)
                : const Radius.circular(20),
          ),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Text(
          note.message,
          style: TextStyle(
            color: isMe ? Colors.black87 : Colors.white,
            fontWeight: isMe ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class MapOverlayButtons extends StatelessWidget {
  final VoidCallback onMenuTap, onGpsTap, onLayersTap, onCancelTap;
  final bool showCancel;
  const MapOverlayButtons({
    super.key,
    required this.onMenuTap,
    required this.onGpsTap,
    required this.onLayersTap,
    required this.showCancel,
    required this.onCancelTap,
  });
  @override
  Widget build(BuildContext context) {
    // FIX: Get l10n outside the Text widget to avoid `const` error
    final l10n = AppLocalizations.of(context)!;
    return Positioned(
      top: MediaQuery.of(context).padding.top + 15,
      left: 15,
      right: 15,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircularButton(icon: Icons.menu_rounded, onTap: onMenuTap),
          if (showCancel)
            FadeIn(
              duration: const Duration(milliseconds: 300), // Faster fade
              child: ElevatedButton.icon(
                icon: const Icon(Icons.close, color: Colors.redAccent),
                label: Text(
                  l10n.cancel, // Use the local l10n variable
                  style: const TextStyle(color: Colors.redAccent),
                ),
                onPressed: onCancelTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ),
          Column(
            children: [
              CircularButton(icon: Icons.gps_fixed, onTap: onGpsTap),
              const SizedBox(height: 10),
              CircularButton(icon: Icons.layers_outlined, onTap: onLayersTap),
            ],
          ),
        ],
      ),
    );
  }
}
