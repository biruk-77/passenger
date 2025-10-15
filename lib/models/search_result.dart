// FILE: lib/models/search_result.dart
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../providers/saved_places_provider.dart';

// Represents the details of a place selected from Google Places API or map tap
class PlaceDetails {
  final String primaryText;
  final String? secondaryText;
  final LatLng coordinates;
  final String placeId;

  PlaceDetails({
    required this.primaryText,
    this.secondaryText,
    required this.coordinates,
    required this.placeId,
  });

  factory PlaceDetails.fromSavedPlace(SavedPlace place) {
    return PlaceDetails(
      placeId: place.placeId,
      primaryText: place.primaryText,
      secondaryText: place.secondaryText,
      coordinates: place.coordinates,
    );
  }
}

// ✅ THIS ENUM IS USED BY YOUR HISTORY SCREEN
enum SearchAction { selectPlace, pickOnMap, cancelled }

// ✅ THIS IS THE CORRECT ORIGINAL CLASS STRUCTURE
class SearchResult {
  final SearchAction? action;
  final PlaceDetails? start;
  final PlaceDetails? end;
  final String? fieldToPick;

  // --- NEW PROPERTIES FOR CONTRACT CREATION ---
  final bool isContractCreation;
  final String? contractId;
  final String? contractType;

  SearchResult({
    this.action, // Make action optional
    this.start,
    this.end,
    this.fieldToPick,
    this.isContractCreation = false, // Default to false
    this.contractId,
    this.contractType,
  });

  // --- NEW CONSTRUCTOR FOR CONTRACT FLOW ---
  factory SearchResult.forContractCreation({
    required String contractId,
    required String contractType,
    PlaceDetails? start,
    PlaceDetails? end,
  }) {
    return SearchResult(
      isContractCreation: true,
      contractId: contractId,
      contractType: contractType,
      start: start,
      end: end,
      action: null, // Not needed for this flow
    );
  }
}
