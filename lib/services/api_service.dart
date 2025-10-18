// FILE: lib/services/api_service.dart
/* CRITICAL: DO NOT REMOVE OR ABBREVIATE. 
      This file must be delivered complete. 
      Any changes must preserve the exported public API. */
import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

// Core dependencies from your existing project structure
import '../services/auth_service.dart';
import '../utils/constants.dart';
import '../utils/api_exception.dart';
import '../utils/logger.dart';
import '../utils/enums.dart';

// Import all required models from their separate files
import '../models/active_booking_state.dart';
import '../models/booking.dart';
import '../models/booking_progress.dart';
import '../models/contract/contract_ride.dart';
import '../models/contract/driver.dart' hide AssignedDriver;
import '../models/passenger.dart';

import '../models/pricing_rule.dart';
import '../models/ride_history.dart';
import '../models/route.dart';
import '../models/contract/trip.dart';
import '../models/vehicle_type.dart';
import '../models/wallet_transaction.dart';
import '../models/contract/contract_booking.dart';
import '../models/payments/payment_partner.dart'; // <--- NEWLY CREATED
import '../models/payments/payment_option.dart'; // <--- NEWLY CREATED
import '../models/contract/trip_schedule_item.dart';

class ApiService {
  static const String _source = "ApiService";
  final Dio _authDio;
  final Dio _bookingsDio;
  final Dio _contractDio;
  final AuthService _authService;
  Future<bool>? _ongoingRefresh; // ensure single-flight refresh across requests

  ApiService(
    this._authService, {
    Dio? authDio,
    Dio? bookingsDio,
    Dio? contractDio,
  }) : _authDio = authDio ?? Dio(),
       _bookingsDio = bookingsDio ?? Dio(),
       _contractDio = contractDio ?? Dio() {
    // --- Auth Service Configuration ---
    _authDio.options
      ..baseUrl = ApiConstants.authBaseUrl
      ..connectTimeout = const Duration(seconds: 20)
      ..receiveTimeout = const Duration(seconds: 20)
      ..headers = {'Accept': 'application/json'};

    // --- Bookings Service Configuration ---
    _bookingsDio.options
      ..baseUrl = ApiConstants.bookingsBaseUrl
      ..connectTimeout = const Duration(seconds: 20)
      ..receiveTimeout = const Duration(seconds: 20)
      ..headers = {'Accept': 'application/json'};

    _contractDio.options
      ..baseUrl = ApiConstants.contractBaseUrl
      ..connectTimeout = const Duration(seconds: 20)
      ..receiveTimeout = const Duration(seconds: 20)
      ..headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json', // <-- ADD THIS LINE
      };
    if (kDebugMode) {
      HttpClient createBadHttpClient() {
        final client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      }

      (_authDio.httpClientAdapter as IOHttpClientAdapter).createHttpClient =
          createBadHttpClient;
      (_bookingsDio.httpClientAdapter as IOHttpClientAdapter).createHttpClient =
          createBadHttpClient;
      (_contractDio.httpClientAdapter as IOHttpClientAdapter).createHttpClient =
          createBadHttpClient;
    }

    _addInterceptors(_authDio);
    _addInterceptors(_bookingsDio);
    _addInterceptors(_contractDio);
  }

  void _addInterceptors(Dio dioInstance) {
    dioInstance.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          final isPublicEndpoint =
              options.path.contains('/login') ||
              options.path.contains('/register') ||
              options.path.contains('/request-otp') ||
              options.path.contains('/verify-otp');

          if (isPublicEndpoint) {
            debugPrint(
              "➡️ [$_source] Requesting PUBLIC: ${options.method} ${options.uri}",
            );
            return handler.next(options);
          }

          // For ALL other (protected) endpoints, get the token right now.
          final token = await _authService.storage.getAccessToken();

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            debugPrint(
              "➡️ [$_source] Requesting PROTECTED with fresh token: ${options.method} ${options.uri}",
            );
            return handler.next(options);
          } else {
            // If there's no token, reject the request.
            debugPrint(
              "❌ [$_source] Rejecting request to ${options.uri}: No token found.",
            );
            return handler.reject(
              DioException(
                requestOptions: options,
                error: ApiException("Not authenticated.", statusCode: 401),
              ),
            );
          }
        },
        onResponse: (response, handler) {
          debugPrint(
            "⬅️ [$_source] Response [${response.statusCode}]: ${response.requestOptions.method} ${response.requestOptions.uri}",
          );
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          debugPrint(
            "❌ [$_source] Interceptor Error: ${e.message} on ${e.requestOptions.uri}",
          );

          // ** NEW LOGIC **
          // If this specific endpoint returns a 404, it's not a real "error".
          // It's expected behavior. We should resolve it and let the calling function handle it.
          if (e.response?.statusCode == 404 &&
              e.requestOptions.path == '/wallet/balance') {
            debugPrint(
              "✅ [$_source] Interceptor: Caught expected 404 for /wallet/balance. Passing response to the handler.",
            );
            // Resolve with the error response, so the try/catch in getPassengerWalletBalance can see the 404.
            return handler.resolve(e.response!);
          }

          if (e.response?.statusCode == 401 &&
              !e.requestOptions.path.contains('/login')) {
            debugPrint(
              "⚠️ [$_source] Token expired for ${e.requestOptions.path}. Attempting refresh...",
            );

            // Single-flight: if a refresh is already in progress, await it; otherwise start one
            _ongoingRefresh ??= _authService.refreshToken();
            final bool refreshed = await _ongoingRefresh!.whenComplete(() {
              _ongoingRefresh = null;
            });

            if (refreshed) {
              debugPrint(
                "✅ [$_source] Token refresh successful. Retrying original request...",
              );
              try {
                final newAccessToken = await _authService.storage
                    .getAccessToken();
                final options = e.requestOptions
                  ..headers['Authorization'] = 'Bearer $newAccessToken';
                final response = await dioInstance.fetch(options);
                return handler.resolve(response);
              } on DioException catch (retryError) {
                return handler.next(retryError);
              }
            } else {
              // Fail fast with a clear auth error so UI can navigate to login and avoid loops
              final apiException = ApiException(
                "Authentication failed: Invalid token.",
                statusCode: 401,
              );
              return handler.next(
                DioException(
                  requestOptions: e.requestOptions,
                  error: apiException,
                ),
              );
            }
          }
          final apiException = ApiException.fromDioError(e);
          return handler.next(
            DioException(requestOptions: e.requestOptions, error: apiException),
          );
        },
      ),
    );
  }

  List<T> _processListResponse<T>(
    Response response,
    T Function(Map<String, dynamic>) fromJson,
    String listKey,
  ) {
    if (response.data is Map<String, dynamic> &&
        response.data['data'] is Map<String, dynamic>) {
      final data = response.data['data'];
      if (data[listKey] is List) {
        return (data[listKey] as List).map((item) => fromJson(item)).toList();
      }
    }
    throw ApiException(
      "Invalid list response format.",
      statusCode: response.statusCode,
    );
  }

  T _processObjectResponse<T>(
    Response response,
    T Function(Map<String, dynamic>) fromJson,
    List<String> objectKeys,
  ) {
    if (response.data is Map<String, dynamic> &&
        response.data['data'] is Map<String, dynamic>) {
      dynamic currentObject = response.data['data'];
      for (var key in objectKeys) {
        if (currentObject is Map<String, dynamic> &&
            currentObject.containsKey(key)) {
          currentObject = currentObject[key];
        } else {
          throw ApiException(
            "Invalid object key path.",
            statusCode: response.statusCode,
          );
        }
      }
      return fromJson(currentObject);
    }
    throw ApiException(
      "Invalid object response format.",
      statusCode: response.statusCode,
    );
  }

  Future<Subscription> createSubscription({
    required String contractId,
    required String pickupLocation,
    required String dropoffLocation,
    required double pickupLatitude,
    required double pickupLongitude,
    required double dropoffLatitude,
    required double dropoffLongitude,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    debugPrint(
      "🚀 [$_source] createSubscription: Creating subscription for contract ID: $contractId...",
    );
    try {
      // ❌ OLD, BUGGY CODE (from your logs)
      // final response = await _contractDio.post(
      //   '/subscripttion/create',

      // ✅ NEW, CORRECTED CODE
      final response = await _contractDio.post(
        '/subscription/create', // <-- Corrected: one 't'
        data: {
          "contract_id": contractId,
          "pickup_location": pickupLocation,
          "dropoff_location": dropoffLocation,
          "pickup_latitude": pickupLatitude,
          "pickup_longitude": pickupLongitude,
          "dropoff_latitude": dropoffLatitude,
          "dropoff_longitude": dropoffLongitude,
          "start_date": DateFormat('yyyy-MM-dd').format(startDate),
          "end_date": DateFormat('yyyy-MM-dd').format(endDate),
        },
      );

      if (response.data != null &&
          response.data['data'] != null &&
          response.data['data']['subscription'] != null) {
        final subscriptionData =
            response.data['data']['subscription'] as Map<String, dynamic>;
        final subscription = Subscription.fromJson(subscriptionData);
        debugPrint(
          "✅ [$_source] createSubscription: Success, created subscription with ID: ${subscription.id}.",
        );
        return subscription;
      } else {
        throw ApiException("Invalid response format from createSubscription.");
      }
    } on DioException catch (e) {
      debugPrint(
        "❌ [$_source] createSubscription: Failed. Error: ${e.response?.data ?? e.message}",
      );
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<Subscription>> getMySubscriptions() async {
    debugPrint(
      "🚀 [$_source] getMySubscriptions: Fetching user subscriptions...",
    );
    try {
      final passenger = _authService.currentPassenger;
      if (passenger == null) {
        throw ApiException("User is not logged in.", statusCode: 401);
      }
      final passengerId = passenger.id;

      // ============================ FIX #1: Correct URL ===========================
      final response = await _contractDio.get(
        '/passenger/$passengerId/subscriptions', // <-- CORRECTED URL
      );
      // ==========================================================================

      print("😂😂😂😘😘😘😘😘👆$response.data");

      // The API returns two lists. We need to read from both of them.

      // 1. Get the main 'data' object safely.
      final responseData = response.data['data'];
      if (responseData == null || responseData is! Map) {
        // If the 'data' key doesn't exist or isn't a map, return empty.
        return [];
      }

      // 2. Extract both lists. Use '?? []' as a safety net.
      final List<dynamic> activeList =
          responseData['active_subscriptions'] ?? [];
      final List<dynamic> historyList =
          responseData['subscription_history'] ?? [];

      // 3. Combine them into a single list.
      final allSubscriptionsJson = [...activeList, ...historyList];

      // 4. Now, parse the combined list.
      final subscriptions = allSubscriptionsJson
          .map((item) => Subscription.fromJson(item as Map<String, dynamic>))
          .toList();

      debugPrint(
        "✅ [$_source] getMySubscriptions: Success, found ${subscriptions.length} subscriptions.",
      );
      return subscriptions;
    } catch (e) {
      debugPrint("❌ [$_source] getMySubscriptions: Failed. Error: $e");
      rethrow; // Re-throw to allow UI to handle the error
    }
  }

  Future<void> submitManualPayment({
    required String subscriptionId,
    required String transactionReference,
    required File receiptImage,
    required double amount,
  }) async {
    debugPrint(
      "🚀 [$_source] submitManualPayment: Submitting manual proof for sub ID: $subscriptionId...",
    );

    try {
      final formData = FormData.fromMap({
        'subscription_id': subscriptionId,
        'payment_method': 'Manual Bank Transfer', // As per Postman spec
        'transaction_reference': transactionReference,
        'amount': amount,
        'receipt_image': await MultipartFile.fromFile(
          receiptImage.path,
          filename: receiptImage.path.split('/').last,
        ),
      });

      // ✅ Capture response before printing
      final response = await _contractDio.post(
        '/payments/manual',
        data: formData,
      );

      debugPrint(
        "✅ [$_source] submitManualPayment: Success, manual payment submitted for review.\n"
        "Response: ${response.data}",
      );
    } on DioException catch (e) {
      debugPrint(
        "❌ [$_source] submitManualPayment: Failed. Error: ${e.response?.data ?? e.message}",
      );
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<Contract>> getAvailableContracts({String? contractType}) async {
    debugPrint(
      "🚀 [$_source] getAvailableContracts: Fetching contracts... ${contractType != null ? '(Type: $contractType)' : '(All Types)'}",
    );
    try {
      final Map<String, dynamic> queryParameters = {};
      if (contractType != null) {
        queryParameters['contract_type'] = contractType;
      }

      final response = await _contractDio.get(
        '/contract-types/active',
        queryParameters: queryParameters,
      );
      print(
        "✅ [$_source] getAvailableContracts: Success, fetched contracts. ${contractType != null ? '(Type: $contractType)' : '(All Types)'} (Status code: ${response.statusCode} Response: ${response.data})",
      );

      if (response.data is Map<String, dynamic> &&
          response.data['data'] is List) {
        final List<dynamic> contractList = response.data['data'];
        final contracts = contractList
            .map((json) => Contract.fromJson(json as Map<String, dynamic>))
            .toList();
        debugPrint(
          "✅ [$_source] getAvailableContracts: Success, found ${contracts.length} contracts.",
        );
        return contracts;
      } else {
        throw ApiException(
          "Invalid response format when fetching available contracts.",
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      debugPrint("❌ [$_source] getAvailableContracts: Failed. Error: $e");
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> confirmTripPickup(String tripId, {String? notes}) async {
    debugPrint(
      "🚀 [$_source] confirmTripPickup: Confirming pickup for trip ID: $tripId...",
    );
    try {
      // This function seems to be for an action after a trip is created.
      // The Postman spec's "Confirm Pickup" *creates* the trip via POST /trip/pickup
      // This PATCH endpoint might be for a different flow. Keeping as is.
      await _contractDio.patch('/trip/$tripId/pickup', data: {'notes': notes});
      debugPrint(
        "✅ [$_source] confirmTripPickup: Success, pickup confirmed for trip ID: $tripId.",
      );
    } on DioException catch (e) {
      debugPrint("❌ [$_source] confirmTripPickup: Failed. Error: $e");
      throw ApiException.fromDioError(e);
    }
  }
  // lib/services/api_service.dart
  // lib/services/api_service.dart

  // ✅✅✅ --- THIS IS THE CORRECT VERSION BASED ON THE NEW POSTMAN FILE --- ✅✅✅
  Future<AssignedDriver?> getContractAssignedDriver(
    String subscriptionId, // ✅ FIX 1: This must be the subscriptionId
  ) async {
    debugPrint(
      "🚀 [ApiService] getContractAssignedDriver: Fetching driver for SUBSCRIPTION ID: $subscriptionId...",
    );
    try {
      // ✅ FIX 2: The URL now matches the new Postman file exactly.
      final response = await _contractDio.get(
        '/passenger/subscription/$subscriptionId/driver',
      );

      debugPrint(
        "✅ [ApiService] getContractAssignedDriver: Success, driver details received. (Status: ${response.statusCode})",
      );
      final data = response.data?['data'];
      if (data?['assigned_driver'] != null) {
        final driver = AssignedDriver.fromJson(data['assigned_driver']);
        debugPrint(
          "✅ [ApiService] getContractAssignedDriver: Success, parsed driver: ${driver.driverName}.",
        );
        return driver;
      } else {
        debugPrint(
          "💬 [ApiService] getContractAssignedDriver: 'assigned_driver' key not found in response.",
        );
        return null;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        debugPrint(
          "💬 [ApiService] getContractAssignedDriver: No driver assigned for this subscription (404).",
        );
        return null;
      }
      debugPrint("❌ [ApiService] getContractAssignedDriver: Failed. Error: $e");
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> confirmTripDropoff(
    String tripId, {
    String? notes,
    int? rating,
  }) async {
    debugPrint(
      "🚀 [$_source] confirmTripDropoff: Confirming dropoff for trip ID: $tripId...",
    );
    try {
      await _contractDio.patch(
        '/trip/$tripId/dropoff',
        data: {'notes': notes, 'rating': rating},
      );
      debugPrint(
        "✅ [$_source] confirmTripDropoff: Success, dropoff confirmed for trip ID: $tripId.",
      );
    } on DioException catch (e) {
      debugPrint("❌ [$_source] confirmTripDropoff: Failed. Error: $e");
      throw ApiException.fromDioError(e);
    }
  }

  // --- 🚗 Driver Workflow ---
  Future<List<PassengerSubscription>> getDriverPassengers(
    String driverId,
  ) async {
    debugPrint(
      "🚀 [$_source] getDriverPassengers: Fetching passengers for driver ID: $driverId...",
    );
    try {
      final response = await _contractDio.get('/driver/$driverId/passengers');
      final passengers = _processListResponse(
        response,
        PassengerSubscription.fromJson,
        'passengers',
      );
      debugPrint(
        "✅ [$_source] getDriverPassengers: Success, found ${passengers.length} passengers.",
      );
      return passengers;
    } on DioException catch (e) {
      debugPrint("❌ [$_source] getDriverPassengers: Failed. Error: $e");
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<TripScheduleItem>> getDriverSchedule(
    String driverId,
    DateTime date,
  ) async {
    debugPrint(
      "🚀 [$_source] getDriverSchedule: Fetching schedule for driver ID: $driverId on date: $date...",
    );
    try {
      final response = await _contractDio.get(
        '/driver/$driverId/schedule',
        queryParameters: {'date': DateFormat('yyyy-MM-dd').format(date)},
      );
      final schedule = _processListResponse(
        response,
        TripScheduleItem.fromJson,
        'schedule',
      );
      debugPrint(
        "✅ [$_source] getDriverSchedule: Success, found ${schedule.length} schedule items.",
      );
      return schedule;
    } on DioException catch (e) {
      debugPrint("❌ [$_source] getDriverSchedule: Failed. Error: $e");
      throw ApiException.fromDioError(e);
    }
  }

  // --- 👨‍💼 Admin Workflow ---
  Future<void> setContractSettings({
    required String contractType,
    required double basePricePerKm,
    required double discountPercentage,
    required double minimumFare,
  }) async {
    debugPrint(
      "🚀 [$_source] setContractSettings: Updating settings for contract type: $contractType...",
    );
    try {
      await _contractDio.post(
        '/admin/contract/settings',
        data: {
          'contract_type': contractType,
          'base_price_per_km': basePricePerKm,
          'discount_percentage': discountPercentage,
          'minimum_fare': minimumFare,
        },
      );
      debugPrint(
        "✅ [$_source] setContractSettings: Success, settings updated.",
      );
    } on DioException catch (e) {
      debugPrint("❌ [$_source] setContractSettings: Failed. Error: $e");
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> approveSubscription(String subscriptionId) async {
    debugPrint(
      "🚀 [$_source] approveSubscription: Approving subscription ID: $subscriptionId...",
    );
    try {
      await _contractDio.post('/admin/subscription/$subscriptionId/approve');
      debugPrint(
        "✅ [$_source] approveSubscription: Success, subscription approved.",
      );
    } on DioException catch (e) {
      debugPrint("❌ [$_source] approveSubscription: Failed. Error: $e");
      throw ApiException.fromDioError(e);
    }
  }

  // --- 🚛 Trip Management ---
  Future<dynamic> getTripDetails(String tripId) async {
    debugPrint(
      "🚀 [$_source] getTripDetails: Fetching details for trip ID: $tripId...",
    );
    try {
      final response = await _contractDio.get('/trip/$tripId');
      final tripData = response.data['data']['trip'];
      debugPrint("✅ [$_source] getTripDetails: Success, fetched trip details.");
      return tripData;
    } on DioException catch (e) {
      debugPrint("❌ [$_source] getTripDetails: Failed. Error: $e");
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> submitPayment({
    required String contractId,
    required String passengerId,
    required String paymentMethod,
    required String dueDate,
    required String transactionReference,
    required String imagePath,
  }) async {
    debugPrint(
      "🚀 [$_source] submitPayment: Submitting payment for contract ID: $contractId...",
    );
    try {
      final formData = FormData.fromMap({
        'contract_id': contractId,
        'passenger_id': passengerId,
        'payment_method': paymentMethod,
        'due_date': dueDate,
        'transaction_reference': transactionReference,
        'status': 'PENDING',
        'receipt_image': await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split('/').last,
        ),
      });
      await _contractDio.post('/payments', data: formData);
      debugPrint(
        "✅ [$_source] submitPayment: Success, payment submitted for review.",
      );
    } on DioException catch (e) {
      debugPrint("❌ [$_source] submitPayment: Failed. Error: $e");
      throw ApiException.fromDioError(e);
    }
  }

  Future<Trip> requestContractRide({
    required String subscriptionId,
    required String passengerId,
  }) async {
    debugPrint(
      "🚀 [ApiService] requestContractRide: Creating trip for sub ID: $subscriptionId...",
    );
    try {
      final response = await _contractDio.post(
        '/trip/pickup',
        data: {
          'subscription_id': subscriptionId,
          'passenger_id': passengerId,
          'notes': 'Contract ride pickup requested.',
        },
      );

      final tripData = response.data?['data']?['trip'];
      if (tripData == null || tripData is! Map<String, dynamic>) {
        throw ApiException(
          "Failed to create trip: Invalid server response format.",
        );
      }

      final trip = Trip.fromJson(tripData);
      debugPrint(
        "✅ [ApiService] requestContractRide: Success, created trip ID: ${trip.id} with status: ${trip.status}.",
      );
      return trip;
    } on DioException catch (e) {
      debugPrint("❌ [ApiService] requestContractRide: Failed. Error: $e");
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> paySubscriptionViaGateway({
    required String subscriptionId,
    required String paymentOptionId,
    String? phone, // ✅ 1. ADD THE OPTIONAL PHONE PARAMETER HERE
  }) async {
    final endpoint = "/subscription/$subscriptionId/payment";
    debugPrint(
      "🚀 [ApiService] paySubscriptionViaGateway: Initiating payment for subscription ID: $subscriptionId with Option ID: $paymentOptionId",
    );

    // ✅ 2. DYNAMICALLY BUILD THE REQUEST BODY
    final Map<String, dynamic> requestData = {
      'payment_option_id': paymentOptionId,
      
    };

    // ✅ 3. ONLY ADD THE PHONE NUMBER IF IT'S PROVIDED
    if (phone != null && phone.trim().isNotEmpty) {
      requestData['phone_number'] = phone
          .trim(); // Use the key 'phone_number' as per backend specs
    }

    debugPrint(" 👍👍👍👍👍👍👍👍👍r - Payload: $requestData");

    try {
      final response = await _contractDio.post(
        endpoint,
        data: requestData, // ✅ 4. SEND THE DYNAMIC DATA
      );

      debugPrint(
        "✅ [ApiService] paySubscriptionViaGateway: Success, payment initiated. Response: ${response.data}",
      );
      return response.data as Map<String, dynamic>? ??
          {'success': true, 'message': 'Payment initiated successfully.'};
    } on DioException catch (e) {
      debugPrint(
        "💣 [ApiService] FAILED REQUEST HEADERS: ${e.requestOptions.headers}",
      );
      debugPrint(
        "🔥🔥🔥 [ApiService] SERVER ERROR RESPONSE: ${e.response?.data}",
      );
      debugPrint(
        "❌ [ApiService] paySubscriptionViaGateway: Failed. Error: ${e.response?.data ?? e.message}",
      );
      throw ApiException.fromDioError(e);
    }
  }

  // --- Functions from Generic Booking Service ---
  Future<FareEstimate> estimateFare({
    required LatLng pickup,
    required LatLng dropoff,
    required String vehicleType,
  }) async {
    debugPrint(
      "🚀 [$_source] estimateFare: Requesting fare for '$vehicleType'...",
    );
    try {
      final response = await _bookingsDio.post(
        '/drivers/estimate-fare',
        data: {
          "vehicleType": vehicleType,
          "radiusKm": 10,
          "pickup": {
            "latitude": pickup.latitude,
            "longitude": pickup.longitude,
          },
          "dropoff": {
            "latitude": dropoff.latitude,
            "longitude": dropoff.longitude,
          },
        },
      );
      final estimate = FareEstimate.fromJson(response.data);
      debugPrint(
        "✅ [$_source] estimateFare: Success, fare is ${estimate.fare}.",
      );
      return estimate;
    } catch (e) {
      debugPrint("❌ [$_source] estimateFare: Failed. Error: $e");
      rethrow;
    }
  }

  Future<Booking?> getActiveBookingForPassenger() async {
    debugPrint(
      "🚀 [$_source] getActiveBookingForPassenger: Checking for active bookings...",
    );
    try {
      final response = await _bookingsDio.get(
        '/bookings',
        queryParameters: {
          'status': ['accepted', 'ongoing', 'driver_on_the_way'],
          'limit': 1,
        },
      );
      final List<dynamic> bookingsData = response.data is Map
          ? response.data['bookings'] ?? []
          : (response.data is List ? response.data : []);
      if (bookingsData.isNotEmpty) {
        final activeBooking = Booking.fromJson(bookingsData.first);
        debugPrint(
          "✅ [$_source] getActiveBookingForPassenger: Success, found active booking: ${activeBooking.id}",
        );
        return activeBooking;
      } else {
        debugPrint(
          "💬 [$_source] getActiveBookingForPassenger: No active bookings found.",
        );
        return null;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        debugPrint(
          "💬 [$_source] getActiveBookingForPassenger: No active bookings found (404).",
        );
        return null;
      }
      debugPrint(
        "❌ [$_source] getActiveBookingForPassenger: Failed. Error: $e",
      );
      rethrow;
    }
  }

  Future<Booking> getBookingDetails(String bookingId) async {
    debugPrint(
      "🚀 [$_source] getBookingDetails: Fetching details for booking ID: $bookingId...",
    );
    try {
      final response = await _bookingsDio.get('/bookings/$bookingId');
      final booking = Booking.fromJson(response.data);
      debugPrint(
        "✅ [$_source] getBookingDetails: Success, parsed booking details.",
      );
      return booking;
    } catch (e) {
      debugPrint(
        "❌ [$_source] getBookingDetails: Failed for $bookingId. Error: $e",
      );
      rethrow;
    }
  }

  Future<void> ratebooking({
    required String bookingId,
    required int rating,
    String? feedback,
  }) async {
    const String source = "ApiService (ratebooking)";

    // Use the correct Dio instance for the booking service
    final url = '/bookings/$bookingId/rate-driver';

    final Map<String, dynamic> body = {'rating': rating};
    if (feedback != null && feedback.isNotEmpty) {
      body['comment'] = feedback;
    }

    Logger.info(
      source,
      "Submitting rating for booking $bookingId to URL: ${_bookingsDio.options.baseUrl}$url",
    );

    try {
      final response = await _bookingsDio.post(url, data: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Logger.success(
          source,
          "Rating submitted successfully for booking $bookingId",
        );
        // No need to return anything on success
      } else {
        // Dio automatically throws an exception for non-2xx statuses,
        // so this 'else' block is less likely to be hit, but it's good practice.
        throw ApiException(
          'Failed to submit rating.',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      Logger.error(source, "Error submitting driver rating", e);
      // Re-throw a standardized exception for the UI to handle.
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<Booking>> getMyBookings({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    debugPrint("🚀 [$_source] getMyBookings: Fetching booking history...");
    try {
      final response = await _bookingsDio.get(
        '/bookings',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (status != null) 'status': status,
        },
      );
      final List<dynamic> data = response.data['bookings'] ?? [];
      final bookings = data.map((item) => Booking.fromJson(item)).toList();
      debugPrint(
        "✅ [$_source] getMyBookings: Success, found ${bookings.length} bookings.",
      );
      return bookings;
    } catch (e) {
      debugPrint("❌ [$_source] getMyBookings: Failed. Error: $e");
      rethrow;
    }
  }

  Future<List<RideHistoryItem>> getMyRideHistory({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    debugPrint("🚀 [$_source] getMyRideHistory: Fetching ride history...");
    try {
      final response = await _bookingsDio.get(
        '/analytics/rides/history',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (status != null) 'status': status,
        },
      );
      final List<dynamic> historyData = response.data['rides'] ?? [];
      final history = historyData
          .map((item) => RideHistoryItem.fromJson(item))
          .toList();
      debugPrint(
        "✅ [$_source] getMyRideHistory: Success, found ${history.length} items.",
      );
      return history;
    } catch (e) {
      debugPrint("❌ [$_source] getMyRideHistory: Failed. Error: $e");
      rethrow;
    }
  }

  Future<List<WalletTransaction>> getWalletTransactions() async {
    debugPrint(
      "🚀 [$_source] getWalletTransactions: Fetching wallet transactions...",
    );
    try {
      final response = await _contractDio.get('/wallet/transactions');
      debugPrint(
        "✅ [$_source] getWalletTransactions: Received response: ${response.data}",
      );

      if (response.statusCode == 200) {
        // ✅ FIX: THE API RETURNS A RAW LIST, NOT A MAP.
        // We must first check if the response data is a List.
        if (response.data is List) {
          final List<dynamic> dataList = response.data;
          final transactions = dataList
              .map(
                (item) =>
                    WalletTransaction.fromJson(item as Map<String, dynamic>),
              )
              .toList();
          debugPrint(
            "✅ [$_source] getWalletTransactions: Success (from raw list), found ${transactions.length} transactions.",
          );
          return transactions;
        }
        // This part is kept as a fallback in case the API changes to a nested structure
        else if (response.data is Map) {
          dynamic transactionsData;
          if (response.data.containsKey('data') &&
              response.data['data'] is Map &&
              response.data['data'].containsKey('transactions')) {
            transactionsData = response.data['data']['transactions'];
          } else if (response.data.containsKey('transactions')) {
            transactionsData = response.data['transactions'];
          }

          if (transactionsData is List) {
            final List<dynamic> dataList = transactionsData;
            final transactions = dataList
                .map(
                  (item) =>
                      WalletTransaction.fromJson(item as Map<String, dynamic>),
                )
                .toList();
            debugPrint(
              "✅ [$_source] getWalletTransactions: Success (from map), found ${transactions.length} transactions.",
            );
            return transactions;
          }
        }

        // If the structure is not a List or a recognized Map, it's an error.
        debugPrint(
          "⚠️ [$_source] getWalletTransactions: Response was not a list or a known map structure. Returning empty list.",
        );
        return [];
      }

      debugPrint(
        "⚠️ [$_source] getWalletTransactions: Received status ${response.statusCode}. Returning empty list.",
      );
      return [];
    } catch (e) {
      debugPrint("❌ [$_source] getWalletTransactions: An error occurred: $e");
      // Re-throw the error so the ViewModel can catch it and show an error message.
      throw ApiException("Failed to load transactions.");
    }
  }

  Future<List<Contract>> getAllContractTypesForPassenger() async {
    debugPrint(
      "🚀 [$_source] getAllContractTypesForPassenger: Fetching all contract types...",
    );
    try {
      final response = await _contractDio.get('/contract-types');
      if (response.data is Map<String, dynamic> &&
          response.data['data'] is List) {
        final List<dynamic> contractList = response.data['data'];
        final contracts = contractList
            .map((json) => Contract.fromJson(json as Map<String, dynamic>))
            .toList();
        debugPrint(
          "✅ [$_source] getAllContractTypesForPassenger: Success, found ${contracts.length} contract types.",
        );
        return contracts;
      } else {
        throw ApiException(
          "Invalid response format when fetching all contract types.",
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      debugPrint(
        "❌ [$_source] getAllContractTypesForPassenger: Failed. Error: $e",
      );
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<PaymentPartner>> getPassengerPaymentPartners() async {
    debugPrint(
      "🚀 [$_source] getPassengerPaymentPartners: Fetching payment partners for passenger...",
    );
    try {
      final response = await _contractDio.get('/payments/partners');
      if (response.data is Map<String, dynamic> &&
          response.data['data'] is List) {
        final List<dynamic> partnersData = response.data['data'];
        final partners = partnersData
            .map(
              (item) => PaymentPartner.fromJson(item as Map<String, dynamic>),
            )
            .toList();
        debugPrint(
          "✅ [$_source] getPassengerPaymentPartners: Success, found ${partners.length} partners.",
        );
        return partners;
      } else {
        throw ApiException("Invalid response format for payment partners.");
      }
    } on DioException catch (e) {
      debugPrint(
        "❌ [$_source] getPassengerPaymentPartners: Failed. Error: ${e.response?.data ?? e.message}",
      );
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<PaymentOption>> getPassengerPaymentOptions() async {
    debugPrint(
      "🚀 [$_source] getPassengerPaymentOptions: Fetching payment options for passenger...",
    );
    try {
      final response = await _contractDio.get('/payments/options');

      // --- ✅ CORRECTED LOGIC ---
      // Check if the response data is a List directly.
      if (response.data is List) {
        // The API returns a raw list, so we cast it directly.
        final List<dynamic> optionsData = response.data;
        final options = optionsData
            .map((item) => PaymentOption.fromJson(item as Map<String, dynamic>))
            .toList();
        debugPrint(
          "✅ [$_source] getPassengerPaymentOptions: Success, found ${options.length} options.",
        );
        return options;
      }
      // It's good practice to also handle the nested format, in case the API changes.
      else if (response.data is Map<String, dynamic> &&
          response.data['data'] is List) {
        final List<dynamic> optionsData = response.data['data'];
        final options = optionsData
            .map((item) => PaymentOption.fromJson(item as Map<String, dynamic>))
            .toList();
        debugPrint(
          "✅ [$_source] getPassengerPaymentOptions: Success (from nested structure), found ${options.length} options.",
        );
        return options;
      } else {
        // If it's neither format, then it's a real error.
        throw ApiException("Invalid response format for payment options.");
      }
    } on DioException catch (e) {
      debugPrint(
        "❌ [$_source] getPassengerPaymentOptions: Failed. Error: ${e.response?.data ?? e.message}",
      );
      throw ApiException.fromDioError(e);
    }
  }

  Future<PaymentOption?> getPaymentPreference() async {
    debugPrint(
      "🚀 [$_source] getPaymentPreference: Fetching passenger payment preference...",
    );
    try {
      // The endpoint is correct as per the backend developer.
      final response = await _contractDio.get('/payments/preference');

      // --- ✅ NEW, ROBUST CHECK ---
      // This logic handles the case where the backend sends a 200 OK
      // but the 'data' object is empty ({}), which means no preference is set.
      if (response.data != null &&
          response.data['data'] is Map<String, dynamic> &&
          (response.data['data'] as Map).isNotEmpty) {
        // If 'data' is a map and it has keys in it, then a preference exists.
        final preferenceData = response.data['data'] as Map<String, dynamic>;
        final paymentOption = PaymentOption.fromJson(preferenceData);
        debugPrint(
          "✅ [$_source] getPaymentPreference: Success, found preference: ${paymentOption.name}.",
        );
        return paymentOption;
      } else {
        // This will now execute correctly when data is {} or null.
        // This is NOT an error. It's the expected result for a user with no saved preference.
        debugPrint(
          "💬 [$_source] getPaymentPreference: No payment preference has been set by the user.",
        );
        return null;
      }
    } on DioException catch (e) {
      // A 404 or 204 would also be valid ways for the server to say "not found".
      if (e.response?.statusCode == 404 || e.response?.statusCode == 204) {
        debugPrint(
          "💬 [$_source] getPaymentPreference: No payment preference found (${e.response?.statusCode}).",
        );
        return null;
      }
      debugPrint(
        "❌ [$_source] getPaymentPreference: A network error occurred. Error: ${e.response?.data ?? e.message}",
      );
      throw ApiException.fromDioError(e);
    } catch (e) {
      // This will catch any other unexpected parsing errors.
      debugPrint(
        "❌ [$_source] getPaymentPreference: Failed to parse the response. Error: $e",
      );
      throw ApiException("Invalid response format for payment options.");
    }
  }

  Future<void> setPaymentPreference({required String paymentOptionId}) async {
    debugPrint(
      "🚀 [$_source] setPaymentPreference: Setting passenger payment preference to ID: $paymentOptionId...",
    );
    try {
      await _contractDio.post(
        '/payments/preference',
        data: {"payment_option_id": paymentOptionId},
      );
      debugPrint(
        "✅ [$_source] setPaymentPreference: Success, payment preference set.${paymentOptionId}",
      );
    } on DioException catch (e) {
      debugPrint(
        "❌ [$_source] setPaymentPreference: Failed. Error: ${e.response?.data ?? e.message}",
      );
      throw ApiException.fromDioError(e);
    }
  }

  // --- NEW Passenger Trip Related Functions ---
  Future<List<Trip>> getMyContractTrips() async {
    debugPrint(
      "🚀 [$_source] getMyContractTrips: Fetching passenger's contract trips...",
    );
    try {
      final response = await _contractDio.get('/trip');
      // ============================ FIX #2: More Robust Parsing ===========================
      if (response.data != null && response.data['data'] != null) {
        final dynamic data = response.data['data'];
        final List<dynamic> tripsData = data is Map && data.containsKey('trips')
            ? data['trips']
            : (data is List ? data : []);

        final trips = tripsData
            .map((item) => Trip.fromJson(item as Map<String, dynamic>))
            .toList();
        debugPrint(
          "✅ [$_source] getMyContractTrips: Success, found ${trips.length} contract trips.",
        );
        return trips;
      } else {
        throw ApiException("Invalid response format for passenger trips.");
      }
      // ===================================================================================
    } on DioException catch (e) {
      debugPrint(
        "❌ [$_source] getMyContractTrips: Failed. Error: ${e.response?.data ?? e.message}",
      );
      throw ApiException.fromDioError(e);
    }
  }

  // --- NEW Passenger Contract Types Related Functions ---
  Future<Contract> getContractTypeByIdForPassenger(
    String contractTypeId,
  ) async {
    debugPrint(
      "🚀 [$_source] getContractTypeByIdForPassenger: Fetching contract type ID: $contractTypeId...",
    );
    try {
      final response = await _contractDio.get(
        '/contract-types/$contractTypeId',
      );
      if (response.data is Map<String, dynamic> &&
          response.data['data'] is Map<String, dynamic>) {
        final contractData = response.data['data'] as Map<String, dynamic>;
        final contract = Contract.fromJson(contractData);
        debugPrint(
          "✅ [$_source] getContractTypeByIdForPassenger: Success, fetched contract type:.",
        );
        return contract;
      } else {
        throw ApiException("Invalid response format for contract type by ID.");
      }
    } on DioException catch (e) {
      debugPrint(
        "❌ [$_source] getContractTypeByIdForPassenger: Failed. Error: ${e.response?.data ?? e.message}",
      );
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> getPassengerWalletBalance() async {
    debugPrint(
      "🚀 [$_source] getPassengerWalletBalance: Fetching wallet data object...",
    );
    try {
      final response = await _contractDio.get('/wallet/balance');
      debugPrint(
        "✅ [$_source] getPassengerWalletBalance: Received response: ${response.data}",
      );

      // The API returns the wallet object directly at the root.
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        // Return the whole map directly.
        final walletData = response.data as Map<String, dynamic>;
        debugPrint(
          "✅ [$_source] getPassengerWalletBalance: Success, returning wallet data map.",
        );
        return walletData;
      } else {
        debugPrint(
          "⚠️ [$_source] getPassengerWalletBalance: Invalid response format. Returning default map.",
        );
        // Return a default map on failure so the UI doesn't crash.
        return {'balance': 0.0, 'currency': 'N/A'};
      }
    } catch (e) {
      debugPrint(
        "❌ [$_source] getPassengerWalletBalance: An error occurred: $e",
      );
      // Return a default map on any exception.
      return {'balance': 0.0, 'currency': 'N/A'};
    }
  }

  Future<ActiveBookingState?> restoreActiveBookingState() async {
    debugPrint(
      "🚀 [$_source] restoreActiveBookingState: Attempting to restore booking state...",
    );
    final Booking? activeBooking = await getActiveBookingForPassenger();
    if (activeBooking == null) {
      debugPrint(
        "💬 [$_source] restoreActiveBookingState: No active booking found to restore.",
      );
      return null;
    }
    try {
      final progress = await getBookingProgress(activeBooking.id);
      final LatLng routeStart =
          progress.driverLocation ?? activeBooking.pickup.coordinates;
      final LatLng routeEnd = activeBooking.status == 'ongoing'
          ? activeBooking.dropoff.coordinates
          : activeBooking.pickup.coordinates;
      final routeResponse = await getRoute(
        from: routeStart,
        to: routeEnd,
        vehicleType: activeBooking.vehicleType,
      );

      final state = ActiveBookingState(
        booking: activeBooking,
        mapState: activeBooking.status == 'ongoing'
            ? MapState.ongoingTrip
            : MapState.driverOnTheWay,
        polylinePoints: routeResponse.decodedPolylinePoints,
      );
      debugPrint(
        "✅ [$_source] restoreActiveBookingState: Success, restored state for booking ${activeBooking.id}.",
      );
      return state;
    } catch (e) {
      debugPrint(
        "❌ [$_source] restoreActiveBookingState: Failed for ${activeBooking.id}. Error: $e",
      );
      rethrow;
    }
  }

  Future<Booking> updateBooking(
    String bookingId,
    UpdateBookingRequest request,
  ) async {
    debugPrint(
      "🚀 [$_source] updateBooking: Updating booking ID: $bookingId...",
    );
    try {
      final response = await _bookingsDio.put(
        '/bookings/$bookingId',
        data: request.toJson(),
      );
      final booking = Booking.fromJson(response.data);
      debugPrint("✅ [$_source] updateBooking: Success.");
      return booking;
    } catch (e) {
      debugPrint("❌ [$_source] updateBooking: Failed. Error: $e");
      rethrow;
    }
  }

  Future<List<VehicleType>> getVehicleTypes() async {
    debugPrint("🚀 [$_source] getVehicleTypes: Fetching vehicle types...");
    try {
      final response = await _bookingsDio.get('/bookings/vehicle/types');
      dynamic raw = response.data is Map && response.data.containsKey('data')
          ? response.data['data']
          : response.data;
      if (raw == null) return [];
      final List<dynamic> data = raw is List ? raw : [raw];
      final types = data.map((item) {
        if (item is String) return VehicleType.fromName(item.trim());
        if (item is Map)
          return VehicleType.fromJson(Map<String, dynamic>.from(item));
        return VehicleType.fromName('unknown');
      }).toList();
      debugPrint(
        "✅ [$_source] getVehicleTypes: Success, found ${types.length} types.",
      );
      return types;
    } catch (e) {
      debugPrint("❌ [$_source] getVehicleTypes: Failed. Error: $e");
      rethrow;
    }
  }

  Future<BackendRouteResponse> getRoute({
    required LatLng from,
    required LatLng to,
    required String vehicleType,
  }) async {
    debugPrint("🚀 [$_source] getRoute: Fetching route...");
    try {
      final response = await _bookingsDio.post(
        '/mapping/route',
        data: {
          "from": {"latitude": from.latitude, "longitude": from.longitude},
          "to": {"latitude": to.latitude, "longitude": to.longitude},
          "vehicle": vehicleType,
        },
      );
      final route = BackendRouteResponse.fromJson(response.data);
      debugPrint(
        "✅ [$_source] getRoute: Success, got route with ${route.decodedPolylinePoints.length} points.",
      );
      return route;
    } catch (e) {
      debugPrint("❌ [$_source] getRoute: Failed. Error: $e");
      rethrow;
    }
  }

  Future<EtaResponse> getEta({
    required LatLng from,
    required LatLng to,
    required String vehicle,
  }) async {
    debugPrint("🚀 [$_source] getEta: Fetching ETA...");
    try {
      final response = await _bookingsDio.post(
        '/mapping/eta',
        data: {
          'from': {'latitude': from.latitude, 'longitude': from.longitude},
          'to': {'latitude': to.latitude, 'longitude': to.longitude},
          'vehicle': vehicle,
        },
      );
      final eta = EtaResponse.fromJson(response.data);
      debugPrint("✅ [$_source] getEta: Success, ETA is ${eta.etaText}.");
      return eta;
    } catch (e) {
      debugPrint("❌ [$_source] getEta: Failed. Error: $e");
      rethrow;
    }
  }

  Future<BookingProgress> getBookingProgress(String bookingId) async {
    debugPrint(
      "🚀 [$_source] getBookingProgress: Fetching progress for booking ID: $bookingId...",
    );
    try {
      final response = await _bookingsDio.get(
        '/mapping/booking/$bookingId/progress',
      );
      final progress = BookingProgress.fromJson(response.data);
      debugPrint(
        "✅ [$_source] getBookingProgress: Success, current status is ${progress.status}.",
      );
      return progress;
    } catch (e) {
      debugPrint("❌ [$_source] getBookingProgress: Failed. Error: $e");
      rethrow;
    }
  }

  Future<dynamic> topupWallet({
    required String id,
    required double amount,
    required String reason,
    required String merchantId,
    required String phoneNumber,
    required String paymentMethod,
  }) async {
    debugPrint("🚀 [$_source] topupWallet: Topping up wallet...");
    try {
      final response = await _bookingsDio.post(
        '/wallet/topup',
        data: {
          "id": id,
          "amount": amount,
          "reason": reason,
          "merchantId": merchantId,
          "phoneNumber": phoneNumber,
          "paymentMethod": paymentMethod,
        },
      );
      debugPrint("✅ [$_source] topupWallet: Success.");
      return response.data;
    } catch (e) {
      debugPrint("❌ [$_source] topupWallet: Failed. Error: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> debugAuth() async {
    debugPrint("🚀 [$_source] debugAuth: Performing debug auth check...");
    try {
      final response = await _bookingsDio.get('/bookings/debug/auth');
      debugPrint("✅ [$_source] debugAuth: Success.");
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint("❌ [$_source] debugAuth: Failed. Error: $e");
      rethrow;
    }
  }

  void dispose() {
    _authDio.close();
    _bookingsDio.close();
    _contractDio.close();
    debugPrint("👋 [$_source] Disposed and all Dio clients closed.");
  }
}
