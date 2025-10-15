// lib/providers/saved_places_provider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/search_result.dart';

// A single, robust model for any saved place.
class SavedPlace {
  final String primaryText;
  final String? secondaryText;
  final LatLng coordinates;
  final String placeId; // ✅ THE MISSING FIELD

  SavedPlace({
    required this.primaryText,
    this.secondaryText,
    required this.coordinates,
    required this.placeId, // ✅ ADDED TO CONSTRUCTOR
  });

  // Convert a SavedPlace into a Map for JSON encoding.
  Map<String, dynamic> toJson() => {
    'primaryText': primaryText,
    'secondaryText': secondaryText,
    'latitude': coordinates.latitude,
    'longitude': coordinates.longitude,
    'placeId': placeId, // ✅ ADDED TO JSON
  };

  // Create a SavedPlace from a JSON map.
  factory SavedPlace.fromJson(Map<String, dynamic> json) => SavedPlace(
    primaryText: json['primaryText'],
    secondaryText: json['secondaryText'],
    coordinates: LatLng(json['latitude'], json['longitude']),
    placeId: json['placeId'] ?? '', // ✅ READ FROM JSON
  );

  // Create a SavedPlace from a PlaceDetails object.
  factory SavedPlace.fromPlaceDetails(PlaceDetails details) {
    return SavedPlace(
      primaryText: details.primaryText,
      secondaryText: details.secondaryText,
      coordinates: details.coordinates,
      placeId: details.placeId, // ✅ MAP THE FIELD
    );
  }
}

class SavedPlacesProvider with ChangeNotifier {
  static const _homeKey = 'saved_place_home';
  static const _workKey = 'saved_place_work';
  static const _recentKey = 'recent_places_list';
  static const _favoritesKey = 'favorite_places_list';
  static const _maxRecent = 5; // Keep the list of recents short

  SavedPlace? _homePlace;
  SavedPlace? _workPlace;
  List<SavedPlace> _recentPlaces = [];
  List<SavedPlace> _favoritePlaces = [];

  bool _isLoading = false;

  // Getters to access the data from the UI
  SavedPlace? get homePlace => _homePlace;
  SavedPlace? get workPlace => _workPlace;
  List<SavedPlace> get favoritePlaces => _favoritePlaces;
  List<SavedPlace> get recentPlaces => _recentPlaces;
  bool get isLoading => _isLoading;

  SavedPlacesProvider() {
    loadPlaces();
  }

  // Load all saved places from SharedPreferences when the provider is created.
  Future<void> loadPlaces() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();

    // Load Home
    final homeJsonString = prefs.getString(_homeKey);
    if (homeJsonString != null) {
      _homePlace = SavedPlace.fromJson(json.decode(homeJsonString));
    }

    // Load Work
    final workJsonString = prefs.getString(_workKey);
    if (workJsonString != null) {
      _workPlace = SavedPlace.fromJson(json.decode(workJsonString));
    }

    // Load Favorites
    final favoritesJsonStringList = prefs.getStringList(_favoritesKey);
    if (favoritesJsonStringList != null) {
      _favoritePlaces = favoritesJsonStringList
          .map((s) => SavedPlace.fromJson(json.decode(s)))
          .toList();
    }

    // Load Recents
    final recentJsonStringList = prefs.getStringList(_recentKey);
    if (recentJsonStringList != null) {
      _recentPlaces = recentJsonStringList
          .map((s) => SavedPlace.fromJson(json.decode(s)))
          .toList();
    }

    _isLoading = false;
    notifyListeners(); // Notify UI that data is ready
  }

  void clearAllData() {
    deleteHome();
    deleteWork();
    clearRecents();
    // Create a copy of the list before iterating to avoid modification errors
    for (final place in List.from(_favoritePlaces)) {
      removeFavorite(place);
    }
    // The notifyListeners() is called within each sub-method, so it's not needed here
    // unless you want one single UI update at the end. For simplicity, this is fine.
  }

  // Add a new place to the top of the recent searches list.
  Future<void> addRecentSearch(SavedPlace place) async {
    // Prevent duplicates by primary text
    _recentPlaces.removeWhere((p) => p.primaryText == place.primaryText);

    // Add to the beginning of the list
    _recentPlaces.insert(0, place);

    // Ensure the list doesn't grow too long
    if (_recentPlaces.length > _maxRecent) {
      _recentPlaces = _recentPlaces.sublist(0, _maxRecent);
    }

    // Save to storage
    await _saveRecents();

    notifyListeners();
    // Notify UI of the change
  }

  Future<void> updateFavorite(SavedPlace oldPlace, SavedPlace newPlace) async {
    final index = _favoritePlaces.indexWhere(
      (p) => p.primaryText == oldPlace.primaryText,
    );

    if (index != -1) {
      _favoritePlaces[index] = newPlace;
      await _saveFavorites();
      notifyListeners();
    }
  }

  // Clears all recent places from the list and from storage.
  Future<void> clearRecents() async {
    _recentPlaces.clear();
    await _saveRecents(); // Save the new empty list
    notifyListeners(); // Update the UI
  }

  Future<void> deleteHome() async {
    _homePlace = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_homeKey);
    notifyListeners();
  }

  Future<void> deleteWork() async {
    _workPlace = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_workKey);
    notifyListeners();
  }

  // Helper method to save the current list of recents to SharedPreferences
  Future<void> _saveRecents() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> recentJsonStringList = _recentPlaces
        .map((p) => json.encode(p.toJson()))
        .toList();
    await prefs.setStringList(_recentKey, recentJsonStringList);
  }

  // Helper method to save the favorites list to SharedPreferences
  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favoritesJsonStringList = _favoritePlaces
        .map((p) => json.encode(p.toJson()))
        .toList();
    await prefs.setStringList(_favoritesKey, favoritesJsonStringList);
  }

  // Add a place to favorites
  Future<void> addFavorite(SavedPlace place) async {
    // Prevent duplicates
    if (!_favoritePlaces.any((p) => p.primaryText == place.primaryText)) {
      _favoritePlaces.add(place);
      await _saveFavorites();
      notifyListeners();
    }
  }

  // Remove a place from favorites
  Future<void> removeFavorite(SavedPlace placeToRemove) async {
    _favoritePlaces.removeWhere(
      (p) => p.primaryText == placeToRemove.primaryText,
    );
    await _saveFavorites();
    notifyListeners();
  }

  Future<void> saveHome(SavedPlace place) async {
    _homePlace = place;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_homeKey, json.encode(place.toJson()));
    notifyListeners();
  }

  Future<void> saveWork(SavedPlace place) async {
    _workPlace = place;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_workKey, json.encode(place.toJson()));
    notifyListeners();
  }

  Future<void> deleteRecent(SavedPlace placeToDelete) async {
    _recentPlaces.removeWhere(
      (p) =>
          p.primaryText == placeToDelete.primaryText &&
          p.secondaryText == placeToDelete.secondaryText,
    );
    await _saveRecents(); // Save the updated list
    notifyListeners(); // Update the UI
  }
}
