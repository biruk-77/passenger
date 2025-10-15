import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/route_details.dart';
import '../models/location.dart';

import '../models/search_result.dart';
// --- Custom Data Models for Richer Information ---

// --- Custom Exceptions for Granular Error Handling ---

class GoogleMapsApiException implements Exception {
  final String message;
  final String? status;
  final dynamic underlyingException;
  GoogleMapsApiException(this.message, {this.status, this.underlyingException});
  @override
  String toString() =>
      'GoogleMapsApiException: $message (status: $status, underlying: $underlyingException)';
}

class GoogleMapsApiZeroResultsException extends GoogleMapsApiException {
  GoogleMapsApiZeroResultsException(String message)
    : super(message, status: 'ZERO_RESULTS');
}

// --- Main Service Class ---

class GoogleMapsService {
  final String apiKey;
  late final Dio _dio;
  String? _sessionToken;

  final Map<String, PlaceAddress> _geocodeMemoryCache = {};
  static const _geocodeCacheKey = 'geocode_persistent_cache_v3';

  GoogleMapsService({required this.apiKey}) {
    final options = BaseOptions(
      baseUrl: 'https://maps.googleapis.com/maps/api',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      queryParameters: {'key': apiKey},
    );
    _dio = Dio(options);
    _loadPersistentCache();
    debugPrint("✅ GoogleMapsService Initialized: The Ultimate Edition");
  }

  /// --- 🧠 THE ULTIMATE ADDRESS LOOKUP ---
  Future<PlaceAddress> getAddressFromCoordinates(
    LatLng coordinates, {
    double currentZoomLevel = 16.0, // Default zoom if not provided
  }) async {
    final cacheKey =
        '${coordinates.latitude.toStringAsFixed(6)},${coordinates.longitude.toStringAsFixed(6)}';

    try {
      debugPrint(
        "🌍 [GEO-LOOKUP] Starting intelligent address search for $coordinates at zoom $currentZoomLevel",
      );

      // --- STAGE 1: Zoom-Aware Nearby Place Search ---
      final nearbyPlace = await _getNearbyPlace(
        coordinates,
        currentZoomLevel: currentZoomLevel,
      );
      if (nearbyPlace != null) {
        debugPrint(
          "✅ [Stage 1] SUCCESS: Found nearby place: ${nearbyPlace.name}",
        );
        await _saveToCache(cacheKey, nearbyPlace);
        return nearbyPlace;
      }
      debugPrint(
        "⚠️ [Stage 1] No high-quality nearby places found. Proceeding to Stage 2.",
      );

      // --- STAGE 2: Precise Reverse Geocoding for Street Address ---
      final geocodeResponse = await _dio.get(
        '/geocode/json',
        queryParameters: {
          'latlng': '${coordinates.latitude},${coordinates.longitude}',
        },
      );

      if (_isResponseValid(geocodeResponse, 'results')) {
        final Map<String, dynamic>? bestResult = _findBestGeocodingResult(
          geocodeResponse.data['results'],
        );
        if (bestResult != null) {
          final placeAddress = _buildPlaceAddressFromResult(
            bestResult,
            coordinates,
          );
          debugPrint(
            "✅ [Stage 2] SUCCESS: Found street address: ${placeAddress.name}",
          );
          await _saveToCache(cacheKey, placeAddress);
          return placeAddress;
        }
      }
      debugPrint("⚠️ [Stage 2] Reverse geocoding returned no usable results.");

      throw GoogleMapsApiZeroResultsException(
        "Could not identify any location after all stages.",
      );
    } on DioException catch (e) {
      debugPrint("🔥 DioException during address lookup: ${e.message}");
      throw GoogleMapsApiException(
        'Network error during address lookup.',
        underlyingException: e,
      );
    } catch (e) {
      debugPrint("🔥 Unhandled Exception during address lookup: $e");
      rethrow;
    }
  }

  /// --- 🗺️ ROUTE & DIRECTIONS ---
  Future<RouteDetails> getDirectionsInfo(
    LatLng origin,
    LatLng destination,
  ) async {
    final url =
        '/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}';
    try {
      final response = await _dio.get(url);
      if (_isResponseValid(response, 'routes')) {
        final route = response.data['routes'][0];
        final leg = route['legs'][0];
        return RouteDetails(
          points: _decodePolyline(route['overview_polyline']['points']),
          distanceText: leg['distance']['text'],
          durationText: leg['duration']['text'],
          distanceValue: leg['distance']['value'],
          durationValue: leg['duration']['value'],
          bounds: LatLngBounds(
            southwest: LatLng(
              route['bounds']['southwest']['lat'],
              route['bounds']['southwest']['lng'],
            ),
            northeast: LatLng(
              route['bounds']['northeast']['lat'],
              route['bounds']['northeast']['lng'],
            ),
          ),
        );
      }
      throw GoogleMapsApiZeroResultsException(
        "No routes found. Status: ${response.data?['status']}",
      );
    } catch (e) {
      throw GoogleMapsApiException(
        "Failed to get directions",
        underlyingException: e,
      );
    }
  }

  /// --- 📸 STATIC MAP URL GENERATION ---
  String getStaticMapUrlWithRoute({
    required LatLng pickup,
    required LatLng dropoff,
    List<Polyline>? polylines,
    int width = 600,
    int height = 400,
  }) {
    final pickupMarker =
        'color:0x00FF00%7Clabel:P%7C${pickup.latitude},${pickup.longitude}';
    final dropoffMarker =
        'color:0xFF0000%7Clabel:D%7C${dropoff.latitude},${dropoff.longitude}';
    String url =
        'https://maps.googleapis.com/maps/api/staticmap?size=${width}x$height&markers=$pickupMarker&markers=$dropoffMarker&key=$apiKey';

    if (polylines != null && polylines.isNotEmpty) {
      final simplifiedPoints = _simplifyPolyline(
        polylines.first.points,
        0.0001,
      );
      final encodedPolyline = _encodePolyline(simplifiedPoints);
      url += '&path=weight:4%7Ccolor:0x0000FF%7Cenc:$encodedPolyline';
    }
    return url;
  }

  // --- 🏙️ PLACE AUTOCOMPLETE ---
  void startSession() => _sessionToken = const Uuid().v4();
  void endSession() => _sessionToken = null;

  Future<List<Map<String, dynamic>>> getPlacePredictions(String input) async {
    if (input.trim().isEmpty) return [];
    if (_sessionToken == null) startSession();

    try {
      final response = await _dio.get(
        '/place/autocomplete/json',
        queryParameters: {
          'input': input,
          'sessiontoken': _sessionToken,
          'components': 'country:ET',
        },
      );
      if (_isResponseValid(response, 'predictions')) {
        return List<Map<String, dynamic>>.from(response.data['predictions']);
      }
      throw GoogleMapsApiException(
        "Places API Error: ${response.data?['status']}",
      );
    } on DioException catch (e) {
      throw GoogleMapsApiException("Failed to get predictions: ${e.message}");
    }
  }

  Future<Map<String, dynamic>> getPlaceDetails(String placeId) async {
    if (_sessionToken == null)
      throw GoogleMapsApiException(
        "Session token is missing for place details.",
      );
    try {
      final response = await _dio.get(
        '/place/details/json',
        queryParameters: {
          'place_id': placeId,
          'sessiontoken': _sessionToken,
          'fields': 'geometry,name,formatted_address',
        },
      );
      if (_isResponseValid(response, 'result')) {
        return response.data['result'];
      }
      throw GoogleMapsApiException(
        "Place Details API Error: ${response.data?['status']}",
      );
    } on DioException catch (e) {
      throw GoogleMapsApiException("Failed to get place details: ${e.message}");
    } finally {
      endSession();
    }
  }

  // --- 🛠️ UTILITY & PRIVATE HELPERS ---

  bool _isResponseValid(Response response, String resultKey) {
    if (response.statusCode == 200 && response.data != null) {
      final status = response.data['status'];
      if (status == 'OK') {
        final results = response.data[resultKey];
        return results != null && (results is List ? results.isNotEmpty : true);
      }
    }
    return false;
  }

  // Method with the first correction
  Future<PlaceAddress?> _getNearbyPlace(
    LatLng coordinates, {
    required double currentZoomLevel,
  }) async {
    double radius;
    if (currentZoomLevel > 18) {
      radius = 20;
    } else if (currentZoomLevel > 16) {
      radius = 50;
    } else if (currentZoomLevel > 14) {
      radius = 250;
    } else {
      radius = 1000;
    }

    debugPrint(
      "🧠 Zoom-Aware Search: Zoom is $currentZoomLevel, searching with radius ${radius}m",
    );

    try {
      final response = await _dio.get(
        '/place/nearbysearch/json',
        queryParameters: {
          'location': '${coordinates.latitude},${coordinates.longitude}',
          'radius': radius,
        },
      );
      if (_isResponseValid(response, 'results')) {
        final bestResult = (response.data['results'] as List).firstWhere((
          place,
        ) {
          final types = List<String>.from(place['types'] ?? []);
          return !types.contains('political') && !types.contains('locality');
        }, orElse: () => response.data['results'][0]);
        return PlaceAddress(
          name: bestResult['name'],
          fullAddress:
              bestResult['vicinity'] ??
              'Near ${bestResult['name']}', // <-- CORRECTED PARAMETER
          coordinates: LatLng(
            bestResult['geometry']['location']['lat'],
            bestResult['geometry']['location']['lng'],
          ),
          placeType: (bestResult['types'] as List).isNotEmpty
              ? bestResult['types'][0]
              : null,
        );
      }
      return null;
    } catch (e) {
      debugPrint("⚠️ Nearby Search failed silently: $e");
      return null;
    }
  }

  Map<String, dynamic>? _findBestGeocodingResult(List<dynamic> results) {
    return results.firstWhere(
      (result) => !(result['types'] as List).contains('plus_code'),
      orElse: () => results.isNotEmpty ? results.first : null,
    );
  }

  // Method with the second correction
  PlaceAddress _buildPlaceAddressFromResult(
    Map<String, dynamic> result,
    LatLng originalCoords,
  ) {
    final formattedAddress =
        result['formatted_address'] as String? ?? "Address unavailable";
    final components = List<Map<String, dynamic>>.from(
      result['address_components'] ?? [],
    );
    final componentMap = <String, String>{};
    for (var c in components) {
      if ((c['types'] as List).isNotEmpty) {
        componentMap[c['types'][0]] = c['long_name'];
      }
    }

    String primaryName =
        componentMap['point_of_interest'] ??
        componentMap['premise'] ??
        componentMap['street_address'] ??
        componentMap['route'] ??
        componentMap['neighborhood'] ??
        componentMap['sublocality'] ??
        formattedAddress.split(',').first;

    final plusCodeRegex = RegExp(r'^[A-Z0-9]{4}\+[A-Z0-9]{2,}');
    if (plusCodeRegex.hasMatch(primaryName)) {
      primaryName =
          componentMap['neighborhood'] ??
          componentMap['sublocality_level_1'] ??
          componentMap['locality'] ??
          "Selected Area";
    }

    // ==========================================================
    // =========== FIX #2 IS HERE ===============================
    // ==========================================================
    return PlaceAddress(
      name: primaryName,
      fullAddress: formattedAddress, // <-- CORRECTED PARAMETER
      coordinates: originalCoords,
      placeType: (result['types'] as List).isNotEmpty
          ? result['types'][0] as String?
          : null,
    );
  }

  Future<void> _loadPersistentCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cachedJson = prefs.getString(_geocodeCacheKey);
      if (cachedJson != null) {
        final Map<String, dynamic> decodedMap = json.decode(cachedJson);
        _geocodeMemoryCache.addAll(
          decodedMap.map(
            (key, value) =>
                MapEntry(key, PlaceAddress.fromJson(json.decode(value))),
          ),
        );
        debugPrint(
          "✅ Loaded ${_geocodeMemoryCache.length} addresses from persistent cache.",
        );
      }
    } catch (e) {
      debugPrint("⚠️ Failed to load persistent geocode cache: $e");
    }
  }

  Future<void> _saveToCache(String key, PlaceAddress address) async {
    _geocodeMemoryCache[key] = address;
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheToSave = _geocodeMemoryCache.map(
        (key, value) => MapEntry(key, json.encode(value.toJson())),
      );
      await prefs.setString(_geocodeCacheKey, json.encode(cacheToSave));
    } catch (e) {
      debugPrint("⚠️ Failed to save to persistent geocode cache: $e");
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length, lat = 0, lng = 0;
    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;
      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  String _encodePolyline(List<LatLng> points) {
    var plat = 0;
    var plng = 0;
    var encoded = '';
    for (var point in points) {
      var lat = (point.latitude * 1e5).round();
      var lng = (point.longitude * 1e5).round();
      var dlat = lat - plat;
      var dlng = lng - plng;
      plat = lat;
      plng = lng;
      encoded += _encode(dlat) + _encode(dlng);
    }
    return encoded;
  }

  String _encode(int val) {
    val = val < 0 ? ~(val << 1) : val << 1;
    var result = '';
    while (val >= 0x20) {
      result += String.fromCharCode((0x20 | (val & 0x1f)) + 63);
      val >>= 5;
    }
    result += String.fromCharCode(val + 63);
    return result;
  }

  List<LatLng> _simplifyPolyline(List<LatLng> points, double tolerance) {
    if (points.length < 3) return points;
    int firstPoint = 0;
    int lastPoint = points.length - 1;
    List<int> pointIndexsToKeep = [firstPoint, lastPoint];
    while (points[firstPoint] == points[lastPoint]) {
      lastPoint--;
    }
    _douglasPeucker(
      points,
      firstPoint,
      lastPoint,
      tolerance,
      pointIndexsToKeep,
    );
    List<LatLng> returnPoints = [];
    pointIndexsToKeep.sort();
    for (var index in pointIndexsToKeep) {
      returnPoints.add(points[index]);
    }
    return returnPoints;
  }

  void _douglasPeucker(
    List<LatLng> points,
    int firstPoint,
    int lastPoint,
    double tolerance,
    List<int> pointIndexsToKeep,
  ) {
    double maxDistance = 0;
    int indexFarthest = 0;
    for (int i = firstPoint; i < lastPoint; i++) {
      double distance = _perpendicularDistance(
        points[firstPoint],
        points[lastPoint],
        points[i],
      );
      if (distance > maxDistance) {
        maxDistance = distance;
        indexFarthest = i;
      }
    }
    if (maxDistance > tolerance && indexFarthest != 0) {
      pointIndexsToKeep.add(indexFarthest);
      _douglasPeucker(
        points,
        firstPoint,
        indexFarthest,
        tolerance,
        pointIndexsToKeep,
      );
      _douglasPeucker(
        points,
        indexFarthest,
        lastPoint,
        tolerance,
        pointIndexsToKeep,
      );
    }
  }

  double _perpendicularDistance(LatLng p1, LatLng p2, LatLng p) {
    double area =
        ((p1.latitude * p2.longitude +
                    p2.latitude * p.longitude +
                    p.latitude * p1.longitude) -
                (p2.latitude * p1.longitude +
                    p.latitude * p2.longitude +
                    p1.latitude * p.longitude))
            .abs();
    double bottom = sqrt(
      pow(p1.latitude - p2.latitude, 2) + pow(p1.longitude - p2.longitude, 2),
    );
    double height = area / bottom * 2;
    return height;
  }
}
