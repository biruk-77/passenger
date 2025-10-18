// FILE: /lib/widgets/home_screen_panels/search_panel.dart
/* CRITICAL: DO NOT REMOVE OR ABBREVIATE. 
      This file must be delivered complete. 
      Any changes must preserve the exported public API. */
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/saved_places_provider.dart';
import '../../models/search_result.dart';
import '../../services/google_maps_service.dart';
import '../../theme/color.dart';
import '../glowing_text_field.dart';

typedef OnPlaceSelectedCallback =
    void Function(PlaceDetails place, String field);
typedef OnPickOnMapCallback = void Function(String field);
typedef OnRouteConfirmedCallback =
    void Function(PlaceDetails start, PlaceDetails end);

class SearchPanel extends StatefulWidget {
  final String googleApiKey;
  final PlaceDetails? initialStart;
  final PlaceDetails? initialEnd;
  final OnPlaceSelectedCallback onPlaceSelected;
  final OnPickOnMapCallback onPickOnMap;
  final VoidCallback onBack;
  final bool isContractCreationMode;
  final OnRouteConfirmedCallback? onContractRouteConfirmed;

  const SearchPanel({
    super.key,
    required this.googleApiKey,
    this.initialStart,
    this.initialEnd,
    required this.onPlaceSelected,
    required this.onPickOnMap,
    required this.onBack,
    this.isContractCreationMode = false,
    this.onContractRouteConfirmed,
  });

  @override
  State<SearchPanel> createState() => _SearchPanelState();
}

class _SearchPanelState extends State<SearchPanel>
    with SingleTickerProviderStateMixin {
  late final GoogleMapsService _mapsService;
  List<Map<String, dynamic>> _predictions = [];
  Timer? _debounce;

  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  final FocusNode _startFocus = FocusNode();
  final FocusNode _endFocus = FocusNode();

  PlaceDetails? _selectedStart;
  PlaceDetails? _selectedEnd;
  String _activeField = 'start';

  bool _isSearchingNetwork = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _mapsService = GoogleMapsService(apiKey: widget.googleApiKey);
    _mapsService.startSession();
    _tabController = TabController(length: 2, vsync: this);

    _selectedStart = widget.initialStart;
    _selectedEnd = widget.initialEnd;
    _startController.text =
        _selectedStart?.primaryText ??
        (widget.isContractCreationMode ? "" : "Current Location");
    _endController.text = _selectedEnd?.primaryText ?? "";

    _startFocus.addListener(_handleFocusChange);
    _endFocus.addListener(_handleFocusChange);
    _startController.addListener(() => _onSearchChanged(_startController));
    _endController.addListener(() => _onSearchChanged(_endController));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedStart != null && _selectedEnd == null) {
        FocusScope.of(context).requestFocus(_endFocus);
      }
    });
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {
        if (_startFocus.hasFocus) {
          _activeField = 'start';
          _startController.clear();
          _selectedStart = null;
        } else if (_endFocus.hasFocus) {
          _activeField = 'end';
          _endController.clear();
          _selectedEnd = null;
        } else {
          // When focus is lost, restore text if needed.
          // ✅ FIX: The line below was removed.
          if (_selectedStart != null) {
            _startController.text = _selectedStart!.primaryText;
          }
          if (_selectedEnd != null) {
            _endController.text = _selectedEnd!.primaryText;
          }
        }
      });
    }
  }

  void _onSearchChanged(TextEditingController controller) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 250), () {
      final input = controller.text.trim();
      final currentFocus = _startFocus.hasFocus || _endFocus.hasFocus;

      if (mounted && currentFocus) {
        if (input.length > 1) {
          _fetchPredictions(input);
        } else {
          // If input is short or empty, clear predictions and stop searching
          setState(() {
            _predictions = [];
            _isSearchingNetwork = false;
          });
        }
      }
    });
  }

  Future<void> _fetchPredictions(String input) async {
    if (!mounted) return;
    setState(() {
      // ✅ USE THE NEW VARIABLE
      _isSearchingNetwork = true;
    });
    try {
      final predictions = await _mapsService.getPlacePredictions(input);
      if (mounted) setState(() => _predictions = predictions);
    } catch (e) {
      // We can just print the error and show an empty list
      debugPrint("Search prediction error: $e");
      if (mounted) setState(() => _predictions = []);
    } finally {
      if (mounted) {
        setState(() {
          // ✅ USE THE NEW VARIABLE
          _isSearchingNetwork = false;
        });
      }
    }
  }

  void _selectPlace(PlaceDetails place) {
    debugPrint("🔍 [SEARCH PANEL] Place selected: ${place.primaryText}");
    debugPrint("🔍 [SEARCH PANEL] Field: $_activeField");
    debugPrint("🔍 [SEARCH PANEL] Coordinates: ${place.coordinates}");

    setState(() {
      if (_activeField == 'start') {
        _selectedStart = place;
        _startController.text = place.primaryText;
      } else {
        _selectedEnd = place;
        _endController.text = place.primaryText;
      }
      // ✅ FIX: The two lines below were removed.
      _predictions = [];
    });

    widget.onPlaceSelected(place, _activeField);

    if (_activeField == 'start' && _selectedEnd == null) {
      FocusScope.of(context).requestFocus(_endFocus);
    } else {
      FocusScope.of(context).unfocus();
    }
  }

  Future<void> _onPredictionTapped(Map<String, dynamic> prediction) async {
    FocusScope.of(context).unfocus(); // Hide keyboard
    final placeId = prediction['place_id'];
    if (placeId == null) return;

    debugPrint(
      "🔍 [SEARCH PANEL] Prediction tapped: ${prediction['description']}",
    );
    debugPrint(
      "🔍 [SEARCH PANEL] Main text: ${prediction['structured_formatting']?['main_text']}",
    );
    debugPrint(
      "🔍 [SEARCH PANEL] Secondary text: ${prediction['structured_formatting']?['secondary_text']}",
    );

    try {
      final placeDetails = await _mapsService.getPlaceDetails(placeId);
      if (!mounted || placeDetails == null) return;
      _mapsService.startSession(); // Start a new session for the next search

      debugPrint(
        "🔍 [SEARCH PANEL] Place details formatted_address: ${placeDetails['formatted_address']}",
      );
      debugPrint(
        "🔍 [SEARCH PANEL] Place details name: ${placeDetails['name']}",
      );

      final location = placeDetails['geometry']?['location'];
      if (location != null) {
        // THIS IS THE KEY: We prioritize the text from the prediction list.
        // ✅ FIX: Preserve the exact search term from the prediction, not the formatted address
        final selectedPlace = PlaceDetails(
          placeId: placeId,
          primaryText:
              prediction['structured_formatting']?['main_text'] ??
              prediction['description'] ??
              'Location',
          secondaryText:
              prediction['structured_formatting']?['secondary_text'] ??
              prediction['description'] ?? // ✅ Use prediction description, not formatted_address
              'Location',
          coordinates: LatLng(location['lat'], location['lng']),
        );

        debugPrint(
          "🔍 [SEARCH PANEL] Preserving exact search term: ${selectedPlace.primaryText}",
        );
        debugPrint(
          "🔍 [SEARCH PANEL] Secondary text: ${selectedPlace.secondaryText}",
        );

        Provider.of<SavedPlacesProvider>(
          context,
          listen: false,
        ).addRecentSearch(SavedPlace.fromPlaceDetails(selectedPlace));

        _selectPlace(selectedPlace);
      }
    } catch (e) {
      debugPrint("Error getting place details: $e");
    }
  }

  void _handleSavedPlaceSelection(SavedPlace place) {
    final placeDetails = PlaceDetails.fromSavedPlace(place);
    _selectPlace(placeDetails);
  }

  void _swapLocations() {
    setState(() {
      final tempText = _startController.text;
      _startController.text = _endController.text;
      _endController.text = tempText;

      final tempPlace = _selectedStart;
      _selectedStart = _selectedEnd;
      _selectedEnd = tempPlace;

      if (_selectedStart != null) {
        widget.onPlaceSelected(_selectedStart!, 'start');
      }
      if (_selectedEnd != null) {
        widget.onPlaceSelected(_selectedEnd!, 'end');
      }
    });
  }

  @override
  void dispose() {
    _mapsService.endSession();
    _startController.dispose();
    _endController.dispose();
    _startFocus.removeListener(_handleFocusChange);
    _endFocus.removeListener(_handleFocusChange);
    _debounce?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool canPlanRoute = _selectedStart != null && _selectedEnd != null;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D1B3E), Color(0xFF040A1A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(l10n),
            _buildInputCard(l10n),
            const SizedBox(height: 20),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),

                // ✅ REPLACE THIS 'child:' PROPERTY
                child:
                    (_startFocus.hasFocus || _endFocus.hasFocus) &&
                            _startController.text.isNotEmpty ||
                        _endController.text.isNotEmpty
                    ? _buildSearchContent(l10n)
                    : _buildSavedPlacesContent(l10n, canPlanRoute),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) => FadeInDown(
    from: 30,
    duration: const Duration(milliseconds: 600),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        children: [
          _PremiumBackButton(onTap: widget.onBack),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isContractCreationMode
                      ? "Set Contract Route"
                      : l10n.setYourRoute,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.isContractCreationMode
                      ? "Choose your daily pickup and drop-off"
                      : l10n.whereWouldYouLikeToGo,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildInputCard(AppLocalizations l10n) => FadeInUp(
    from: 30,
    delay: const Duration(milliseconds: 100),
    duration: const Duration(milliseconds: 600),
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.12),
            Colors.white.withValues(alpha: 0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildRouteIndicators(),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                GlowingTextField(
                  controller: _startController,
                  focusNode: _startFocus,
                  hintText: l10n.pickupLocation,
                  suffixIcon: _buildSuffixIcon(_startFocus),
                ),
                const SizedBox(height: 16),
                GlowingTextField(
                  controller: _endController,
                  focusNode: _endFocus,
                  hintText: l10n.destination,
                  suffixIcon: _buildSuffixIcon(_endFocus),
                ),
              ],
            ),
          ),
          _buildSwapButton(),
        ],
      ),
    ),
  );

  Widget _buildSuffixIcon(FocusNode focusNode) {
    return IconButton(
      icon: Icon(
        Icons.push_pin_outlined,
        color: Colors.white.withValues(alpha: 0.6),
        size: 20,
      ),
      onPressed: () {
        if (focusNode == _startFocus) {
          widget.onPickOnMap('start');
        } else if (focusNode == _endFocus) {
          widget.onPickOnMap('end');
        }
      },
    );
  }

  Widget _buildRouteIndicators() => Column(
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.goldenrod.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.my_location,
          color: AppColors.goldenrod,
          size: 18,
        ),
      ),
      Container(
        height: 80,
        width: 2,
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.3),
              Colors.white.withValues(alpha: 0.1),
              Colors.transparent,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.hotPink.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.location_on,
          color: AppColors.hotPink,
          size: 18,
        ),
      ),
    ],
  );

  Widget _buildSwapButton() => FadeInRight(
    delay: const Duration(milliseconds: 200),
    child: Container(
      margin: const EdgeInsets.only(left: 12),
      child: Center(
        child: IconButton(
          onPressed: _swapLocations,
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: const Icon(
              Icons.swap_vert_rounded,
              color: AppColors.goldenrod,
              size: 20,
            ),
          ),
        ),
      ),
    ),
  );

  /// Renamed from `_buildPredictionsList` to reflect its new purpose.
  Widget _buildSearchContent(AppLocalizations l10n) {
    return FadeInUp(
      key: const ValueKey('search_content'),
      from: 30,
      duration: const Duration(milliseconds: 500),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ✅ CHANGE THIS 'if' CONDITION
          if (_isSearchingNetwork && _predictions.isEmpty)
            _buildLoadingIndicator(l10n)
          else
            ..._predictions.map(
              (prediction) => _buildPredictionTile(prediction),
            ),
        ],
      ),
    );
  }

  Widget _buildSavedPlacesContent(AppLocalizations l10n, bool canPlanRoute) {
    return FadeInUp(
      key: const ValueKey('saved_places_content'),
      from: 30,
      duration: const Duration(milliseconds: 500),
      child: SingleChildScrollView(
        child: Column(
          children: [
            if (canPlanRoute)
              _buildPlanRouteButton(l10n)
            else
              _buildQuickActions(l10n),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _buildSavedPlacesSection(l10n),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 400,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _buildTabBarSection(l10n),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanRouteButton(AppLocalizations l10n) {
    // ✅ ADD THIS LINE
    final bool isEnabled = _selectedStart != null && _selectedEnd != null;

    return Container(
      key: const ValueKey('plan_route_button'),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      width: double.infinity,
      child: ElevatedButton.icon(
        // ✅ REPLACE THIS ENTIRE onPressed LOGIC
        onPressed: isEnabled
            ? () {
                if (widget.isContractCreationMode) {
                  // Call the new callback to navigate to CreateSubscriptionScreen
                  widget.onContractRouteConfirmed?.call(
                    _selectedStart!,
                    _selectedEnd!,
                  );
                } else {
                  // The original behavior for regular rides
                  widget.onBack();
                }
              }
            : null,
        // ✅ REPLACE THE ICON
        icon: Icon(
          widget.isContractCreationMode
              ? Icons.check_circle_outline_rounded
              : Icons.route_rounded,
          color: Colors.black87,
        ),
        // ✅ REPLACE THE LABEL'S TEXT
        label: Text(
          widget.isContractCreationMode
              ? "Confirm Contract Route"
              : l10n.planYourRoute,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          backgroundColor: AppColors.goldenrod,
          // ✅ ADD THIS LINE FOR DISABLED STATE
          disabledBackgroundColor: Colors.grey.shade600,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          shadowColor: AppColors.goldenrod.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildQuickActions(AppLocalizations l10n) {
    return Container(
      key: const ValueKey('quick_actions'),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _QuickActionButton(
              icon: Icons.map_outlined,
              label: l10n.pickOnMap,
              color: AppColors.goldenrod,
              onTap: () => widget.onPickOnMap(_activeField),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _QuickActionButton(
              icon: Icons.favorite_border_rounded,
              label: l10n.addFavorite,
              color: Colors.pinkAccent,
              onTap: () => widget.onPickOnMap('favorite'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _QuickActionButton(
              icon: Icons.delete_outline_rounded,
              label: l10n.clearAll,
              color: Colors.redAccent,
              onTap: () => _showClearAllDialog(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedPlacesSection(AppLocalizations l10n) {
    return Consumer<SavedPlacesProvider>(
      builder: (context, provider, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.12),
                Colors.white.withValues(alpha: 0.06),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: Column(
            children: [
              _PremiumSavedPlaceTile(
                icon: Icons.home_filled,
                title: provider.homePlace?.primaryText ?? l10n.home,
                subtitle:
                    provider.homePlace?.secondaryText ??
                    l10n.addYourHomeAddress,
                isSet: provider.homePlace != null,
                color: Colors.orangeAccent,
                onTap: () {
                  if (provider.homePlace != null) {
                    _handleSavedPlaceSelection(provider.homePlace!);
                  } else {
                    widget.onPickOnMap('home');
                  }
                },
                onLongPress: provider.homePlace != null
                    ? () => _showPlaceMenu(context, 'home')
                    : null,
                l10n: l10n,
              ),
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.white.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              _PremiumSavedPlaceTile(
                icon: Icons.work_rounded,
                title: provider.workPlace?.primaryText ?? l10n.work,
                subtitle:
                    provider.workPlace?.secondaryText ??
                    l10n.addYourWorkAddress,
                isSet: provider.workPlace != null,
                color: Colors.purpleAccent,
                onTap: () {
                  if (provider.workPlace != null) {
                    _handleSavedPlaceSelection(provider.workPlace!);
                  } else {
                    widget.onPickOnMap('work');
                  }
                },
                onLongPress: provider.workPlace != null
                    ? () => _showPlaceMenu(context, 'work')
                    : null,
                l10n: l10n,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabBarSection(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.goldenrod,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.symmetric(horizontal: 10),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              tabs: [
                Tab(text: l10n.favorites),
                Tab(text: l10n.recentTrips),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFavoritesList(context, l10n),
                _buildRecentsList(context, l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(BuildContext context, AppLocalizations l10n) {
    return Consumer<SavedPlacesProvider>(
      builder: (context, placesProvider, child) {
        if (placesProvider.favoritePlaces.isEmpty) {
          return Center(
            child: _PremiumEmptyState(
              icon: Icons.star_border_rounded,
              title: l10n.noFavoritesYet,
              message: l10n.addFavoritesMessage,
              action: _AddButton(
                onTap: () => widget.onPickOnMap('favorite'),
                label: l10n.addFavorite,
              ),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: placesProvider.favoritePlaces.length,
          itemBuilder: (context, index) {
            final place = placesProvider.favoritePlaces[index];
            return _PremiumPlaceTile(
              icon: Icons.star_rounded,
              iconColor: AppColors.goldenrod,
              title: place.primaryText,
              subtitle: place.secondaryText ?? '',
              onTap: () => _handleSavedPlaceSelection(place),
              onLongPress: () => _showPlaceMenu(context, 'favorite', place),
              showMenu: true,
            );
          },
        );
      },
    );
  }

  Widget _buildRecentsList(BuildContext context, AppLocalizations l10n) {
    return Consumer<SavedPlacesProvider>(
      builder: (context, placesProvider, child) {
        if (placesProvider.recentPlaces.isEmpty) {
          return Center(
            child: _PremiumEmptyState(
              icon: Icons.history_toggle_off_rounded,
              title: l10n.noRecentTrips,
              message: l10n.recentTripsMessage,
            ),
          );
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.recentTripsCount(placesProvider.recentPlaces.length),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<SavedPlacesProvider>().clearRecents();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.recentsCleared),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    child: Text(
                      l10n.clearAll,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: placesProvider.recentPlaces.length,
                itemBuilder: (context, index) {
                  final place = placesProvider.recentPlaces[index];
                  return Dismissible(
                    key: ValueKey(place.placeId),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      decoration: BoxDecoration(
                        color: Colors.red.shade800,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: const Icon(
                        Icons.delete_forever,
                        color: Colors.white,
                      ),
                    ),
                    onDismissed: (_) {
                      context.read<SavedPlacesProvider>().deleteRecent(place);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.recentTripRemoved),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    child: _PremiumPlaceTile(
                      icon: Icons.history_rounded,
                      title: place.primaryText,
                      subtitle: place.secondaryText ?? '',
                      onTap: () => _handleSavedPlaceSelection(place),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingIndicator(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.goldenrod),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.searching,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionTile(Map<String, dynamic> prediction) {
    final mainText = prediction['structured_formatting']?['main_text'] ?? '';
    final secondaryText =
        prediction['structured_formatting']?['secondary_text'] ?? '';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onPredictionTapped(prediction),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.goldenrod.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.goldenrod,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mainText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (secondaryText.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        secondaryText,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white54,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

   void _showPlaceMenu(BuildContext context, String type, [SavedPlace? place]) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return _PremiumActionSheet(
          title: _getMenuTitle(l10n, type, place),
          actions: [
            _ActionSheetItem(
              icon: Icons.edit_location_alt_rounded,
              title: l10n.changeAddress,
              color: AppColors.goldenrod,
              onTap: () {
                Navigator.of(ctx).pop();
                if (type == 'home') widget.onPickOnMap('home');
                if (type == 'work') widget.onPickOnMap('work');
                if (type == 'favorite') widget.onPickOnMap('favorite');
              },
            ),
            _ActionSheetItem(
              icon: Icons.delete_forever_rounded,
              title: l10n.remove,
              color: Colors.redAccent,
              onTap: () {
                Navigator.of(ctx).pop();
                final provider = Provider.of<SavedPlacesProvider>(
                  context,
                  listen: false,
                );
                if (type == 'home') provider.deleteHome();
                if (type == 'work') provider.deleteWork();
                if (type == 'favorite' && place != null) {
                  provider.removeFavorite(place);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.itemRemovedSuccessfully(type)),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  String _getMenuTitle(AppLocalizations l10n, String type, SavedPlace? place) {
    switch (type) {
      case 'home':
        return l10n.homeAddress;
      case 'work':
        return l10n.workAddress;
      case 'favorite':
        return place?.primaryText ?? l10n.favoritePlace;
      default:
        return l10n.placeOptions;
    }
  }

  void _showClearAllDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => _PremiumConfirmationDialog(
        title: l10n.clearAllDataTitle,
        content: l10n.clearAllDataContent,
        confirmText: l10n.clearEverything,
        onConfirm: () {
          final provider = Provider.of<SavedPlacesProvider>(
            context,
            listen: false,
          );
          provider.clearAllData();
          Navigator.of(ctx).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.allDataCleared),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }
}

class _PremiumBackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _PremiumBackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumSavedPlaceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSet;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final AppLocalizations l10n;

  const _PremiumSavedPlaceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSet,
    required this.color,
    required this.onTap,
    required this.l10n,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.3),
                      color.withValues(alpha: 0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isSet
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 13,
                        fontStyle: isSet ? FontStyle.normal : FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (onLongPress != null)
                Icon(
                  Icons.more_vert_rounded,
                  color: Colors.white.withValues(alpha: 0.5),
                  size: 20,
                )
              else if (isSet == false)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    l10n.add,
                    style: const TextStyle(
                      color: AppColors.goldenrod,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumPlaceTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final IconData icon;
  final Color? iconColor;
  final bool showMenu;

  const _PremiumPlaceTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.onLongPress,
    this.icon = Icons.place_rounded,
    this.iconColor,
    this.showMenu = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor ?? Colors.white70, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (showMenu)
                IconButton(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: Colors.white.withValues(alpha: 0.5),
                    size: 20,
                  ),
                  onPressed: onLongPress,
                )
              else
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white.withValues(alpha: 0.4),
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const _PremiumEmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white.withValues(alpha: 0.4),
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[const SizedBox(height: 20), action!],
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  final String label;

  const _AddButton({required this.onTap, required this.label});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.add, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.goldenrod.withValues(alpha: 0.2),
        foregroundColor: AppColors.goldenrod,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.goldenrod.withValues(alpha: 0.3)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }
}

class _PremiumActionSheet extends StatelessWidget {
  final String title;
  final List<_ActionSheetItem> actions;

  const _PremiumActionSheet({required this.title, required this.actions});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2C55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...actions,
          const Divider(
            color: Colors.white12,
            height: 1,
            indent: 16,
            endIndent: 16,
          ),
          _ActionSheetItem(
            icon: Icons.cancel_rounded,
            title: l10n.cancel,
            color: Colors.white54,
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class _ActionSheetItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _ActionSheetItem({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final VoidCallback onConfirm;

  const _PremiumConfirmationDialog({
    required this.title,
    required this.content,
    required this.confirmText,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFF1A2C55), const Color(0xFF0D1B3E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                content,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        l10n.cancel,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(confirmText),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
