// lib/providers/history_provider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

import '../models/ride_history.dart';
import '../services/api_service.dart';
import '../services/google_maps_service.dart';
import 'package:flutter/foundation.dart'; // Add this for debugPrint

// ... HistoryTabData class remains the same ...
class HistoryTabData {
  final String? status;
  final List<RideHistoryItem> historyItems = [];
  bool isLoading = false;
  bool hasMore = true;
  String? errorMessage;
  int currentPage = 1;
  static const int itemsPerPage = 15;
  HistoryTabData({required this.status});
  void reset() {
    currentPage = 1;
    hasMore = true;
    errorMessage = null;
  }
}

class HistoryProvider with ChangeNotifier {
  final ApiService _apiService;
  final GoogleMapsService _googleMapsService;
  bool _isDisposed = false;
  static const _cacheKey = 'ride_history_cache';

  final Map<int, HistoryTabData> tabs = {
    0: HistoryTabData(status: null),
    1: HistoryTabData(status: 'completed'),
    2: HistoryTabData(status: 'canceled'),
  };

  HistoryProvider(this._apiService, this._googleMapsService) {
    _loadHistoryFromCache();
  }

  // ▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼
  // === STEP 1: IMPLEMENT THE _loadHistoryFromCache METHOD ===
  // ▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼
  Future<void> _loadHistoryFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_cacheKey);

      if (jsonString != null) {
        // Decode the saved string back into a Map
        final Map<String, dynamic> cachedData = jsonDecode(jsonString);

        // Iterate over the cached tabs ("0", "1", "2")
        for (var entry in cachedData.entries) {
          final tabIndex = int.tryParse(entry.key);
          if (tabIndex != null && tabs.containsKey(tabIndex)) {
            // Convert the list of JSON maps back into RideHistoryItem objects
            final List<dynamic> itemsJson = entry.value;
            final items = itemsJson
                .map((item) => RideHistoryItem.fromJson(item))
                .toList();

            // Populate the provider's state with the cached data
            tabs[tabIndex]!.historyItems.clear();
            tabs[tabIndex]!.historyItems.addAll(items);
          }
        }
        debugPrint("✅ Ride history loaded from cache.");
        notifyListeners(); // Update the UI with the cached data
      }
    } catch (e) {
      debugPrint("🚨 Could not load ride history from cache: $e");
      // If cache is corrupt, it's safer to just start fresh
      await clearCache();
    }
  }

  // ▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼
  // === STEP 2: IMPLEMENT THE _saveHistoryToCache METHOD ===
  // ▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼
  Future<void> _saveHistoryToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> dataToCache = {};

      // Convert the RideHistoryItem objects in each tab into a JSON-compatible format
      for (var entry in tabs.entries) {
        final tabIndex = entry.key;
        final tabData = entry.value;
        // The key must be a String for JSON encoding
        dataToCache[tabIndex.toString()] = tabData.historyItems
            .map((item) => item.toJson())
            .toList();
      }

      // Encode the entire map to a single JSON string
      final String jsonString = jsonEncode(dataToCache);
      await prefs.setString(_cacheKey, jsonString);
      debugPrint("✅ Ride history saved to cache.");
    } catch (e) {
      debugPrint("🚨 Could not save ride history to cache: $e");
    }
  }

  // ✅ --- ADD THIS NEW METHOD FROM THE PREVIOUS FIX ---
  /// Clears all cached and in-memory ride history data.
  Future<void> clearCache() async {
    // 1. Clear the data in memory
    for (final tabData in tabs.values) {
      tabData.historyItems.clear();
      tabData.reset(); // Reset pagination and error states
    }

    // 2. Clear the data from persistent storage
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      debugPrint("Ride history cache cleared successfully.");
    } catch (e) {
      debugPrint("Error clearing ride history cache: $e");
    }

    // 3. Notify listeners that the data is gone
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  // ... fetchHistory, _resolveAddressesForList, and dispose methods are the same ...
  Future<void> fetchHistory({
    required int tabIndex,
    bool isRefresh = false,
  }) async {
    final currentTab = tabs[tabIndex]!;
    if (currentTab.isLoading || (!isRefresh && !currentTab.hasMore)) return;

    if (isRefresh) {
      currentTab.reset();
    }

    currentTab.isLoading = true;
    currentTab.errorMessage = null;
    notifyListeners();

    try {
      final newItems = await _apiService.getMyRideHistory(
        page: currentTab.currentPage,
        limit: HistoryTabData.itemsPerPage,
        status: currentTab.status,
      );

      if (!_isDisposed) {
        if (isRefresh) {
          currentTab.historyItems.clear();
        }
        currentTab.historyItems.addAll(newItems);
        currentTab.currentPage++;
        currentTab.hasMore = newItems.length == HistoryTabData.itemsPerPage;

        notifyListeners();

        _resolveAddressesForList(currentTab.historyItems);

        // Save to cache after fetching new items
        await _saveHistoryToCache();
      }
    } on DioException {
      if (!_isDisposed) currentTab.errorMessage = "No Internet Connection";
    } catch (e) {
      if (!_isDisposed)
        currentTab.errorMessage = 'An unexpected error occurred.';
    } finally {
      if (!_isDisposed) {
        currentTab.isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> _resolveAddressesForList(List<RideHistoryItem> items) async {
    bool didUpdate = false;
    for (final item in items) {
      try {
        if (item.pickup?.address == null && item.pickup?.coordinates != null) {
          final place = await _googleMapsService.getAddressFromCoordinates(
            item.pickup!.coordinates,
          );
          item.pickup!.address = place.name;
          didUpdate = true;
        }
        if (item.dropoff?.address == null &&
            item.dropoff?.coordinates != null) {
          final place = await _googleMapsService.getAddressFromCoordinates(
            item.dropoff!.coordinates,
          );
          item.dropoff!.address = place.name;
          didUpdate = true;
        }
      } catch (e) {
        debugPrint("Could not resolve address for history item: $e");
      }
    }

    if (didUpdate && !_isDisposed) {
      notifyListeners();
      await _saveHistoryToCache(); // Re-save cache with resolved addresses
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
