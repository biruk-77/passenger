// lib/widgets/home_screen_panels/contract_location_picker_panel.dart
// ✅ MODERNIZED & OPTIMIZED VERSION
// By AI Artistic Flutter System — Premium Contract Edition

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../l10n/app_localizations.dart';
import '../../models/search_result.dart';
import '../../services/google_maps_service.dart';
import '../../theme/color.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// --- EXISTING DESIGN SYSTEM CONSTANTS (UNUSED BY NEW BACKGROUND, KEPT FOR WIDGETS) ---
const Color _backgroundColorStart = Color(0xFF2C3E50);
const Color _backgroundColorEnd = Color(0xFF1B2631);
const Color _goldAccent = Color(0xFFD4AF37);
const String _primaryFont = 'Inter';
const String _headingFont = 'PlayfairDisplay';

typedef OnContractPlaceSelected = void Function(PlaceDetails place);

class ContractLocationPickerPanel extends StatefulWidget {
  final String stage;
  final GoogleMapsService googleMapsService;
  final OnContractPlaceSelected onPlaceSelected;
  final VoidCallback onCancel;

  const ContractLocationPickerPanel({
    super.key,
    required this.stage,
    required this.googleMapsService,
    required this.onPlaceSelected,
    required this.onCancel,
  });

  @override
  State<ContractLocationPickerPanel> createState() =>
      _ContractLocationPickerPanelState();
}

class _ContractLocationPickerPanelState
    extends State<ContractLocationPickerPanel>
    with TickerProviderStateMixin {
  // STEP 2: Added TickerProviderStateMixin
  // --- EXISTING STATE & CONTROLLERS (UNCHANGED) ---
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _predictions = [];
  bool _isSearchingNetwork = false;
  Timer? _debounce;
  final List<PlaceDetails> _recentSearches = [];

  // --- STEP 2: ADDED ANIMATION CONTROLLERS ---
  late final AnimationController _gradientController;
  late final AnimationController _burstController;

  @override
  void initState() {
    super.initState();

    // --- STEP 3: INITIALIZED NEW CONTROLLERS ---
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);

    _burstController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _burstController.forward();
      }
    });

    // --- EXISTING INIT LOGIC (UNCHANGED) ---
    widget.googleMapsService.startSession();
  }

  @override
  void dispose() {
    // --- STEP 3: DISPOSED NEW CONTROLLERS ---
    _gradientController.dispose();
    _burstController.dispose();

    // --- EXISTING DISPOSE LOGIC (UNCHANGED) ---
    _searchController.dispose();
    _debounce?.cancel();
    widget.googleMapsService.endSession();
    super.dispose();
  }

  // --- EXISTING LOGIC (UNCHANGED) ---
  Future<void> _onSearchChanged(String input) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    if (input.trim().isEmpty) {
      setState(() {
        _predictions = [];
        _isSearchingNetwork = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (mounted) setState(() => _isSearchingNetwork = true);
      try {
        final results = await widget.googleMapsService.getPlacePredictions(
          input,
        );
        if (mounted) setState(() => _predictions = results);
      } catch (e) {
        debugPrint("Error fetching predictions: $e");
      } finally {
        if (mounted) setState(() => _isSearchingNetwork = false);
      }
    });
  }

  Future<void> _onPredictionTapped(
    String placeId, {
    PlaceDetails? recentPlace,
  }) async {
    try {
      final PlaceDetails place;
      if (recentPlace != null) {
        place = recentPlace;
      } else {
        final details = await widget.googleMapsService.getPlaceDetails(placeId);
        final location = details['geometry']['location'];
        place = PlaceDetails(
          primaryText: details['name'] ?? 'Unknown Location',
          secondaryText: details['formatted_address'],
          placeId: placeId,
          coordinates: LatLng(location['lat'], location['lng']),
        );
      }
      widget.onPlaceSelected(place);
    } catch (e) {
      debugPrint("Error getting place details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool showRecentSearches = _searchController.text.trim().isEmpty;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Material(
        color: Colors.transparent,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.5,
          clipBehavior: Clip.antiAlias,
          // --- STEP 5: REMOVED OLD DECORATION ---
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.0)),
          ),
          // --- STEP 5: WRAPPED CONTENT IN A STACK WITH NEW BACKGROUND ---
          child: Stack(
            children: [
              _buildAnimatedGradientBackground(),
              _buildCornerBurstEffect(),
              // --- EXISTING CONTENT WIDGETS (UNCHANGED) ---
              Column(
                children: [
                  _buildHeader(l10n),
                  _buildSearchBar(l10n),
                  const Divider(color: _goldAccent, height: 24, thickness: 0.2),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: showRecentSearches
                          ? _buildRecentSearchesSection(l10n)
                          : _buildPredictionsSection(l10n),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().slideY(
      // Panel entry animation is preserved
      begin: 1.0,
      duration: 400.ms,
      curve: Curves.easeOutCubic,
    );
  }

  // --- EXISTING HELPER WIDGETS (UNCHANGED) ---
  Widget _buildHeader(AppLocalizations l10n) {
    final title = widget.stage == 'pickup'
        ? l10n.contractPickerTitlePickup
        : l10n.contractPickerTitleDestination;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32.0)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                onPressed: widget.onCancel,
              ),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: _headingFont,
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 48), // Spacer to balance the close button
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n) {
    final hintText = widget.stage == 'pickup'
        ? l10n.contractPickerHintPickup
        : l10n.contractPickerHintDestination;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        autofocus: true,
        style: const TextStyle(color: Colors.white, fontFamily: _primaryFont),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          prefixIcon: const Icon(Icons.search, color: _goldAccent),
          suffixIcon: _isSearchingNetwork
              ? const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: SizedBox(
                    height: 10,
                    width: 10,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _goldAccent,
                    ),
                  ),
                )
              : null,
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: _goldAccent),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentSearchesSection(AppLocalizations l10n) {
    if (_recentSearches.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history_rounded,
        message: l10n.contractPickerNoRecents,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Text(
            l10n.contractPickerRecentsTitle,
            style: const TextStyle(
              fontFamily: _primaryFont,
              color: Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: _recentSearches.length,
            itemBuilder: (context, index) {
              final place = _recentSearches[index];
              return _SearchResultTile(
                    icon: Icons.history,
                    iconColor: _goldAccent,
                    title: place.primaryText,
                    subtitle: place.secondaryText ?? '',
                    onTap: () =>
                        _onPredictionTapped(place.placeId, recentPlace: place),
                  )
                  .animate(delay: (100 * index).ms)
                  .fadeIn(duration: 400.ms)
                  .slideX(begin: -0.1);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPredictionsSection(AppLocalizations l10n) {
    if (_predictions.isEmpty && !_isSearchingNetwork) {
      return _buildEmptyState(
        icon: Icons.search_off_rounded,
        message: l10n.contractPickerNoResults,
      );
    }
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _predictions.length,
      itemBuilder: (context, index) {
        final prediction = _predictions[index];
        final mainText =
            prediction['structured_formatting']?['main_text'] ?? '';
        final secondaryText =
            prediction['structured_formatting']?['secondary_text'] ?? '';
        return _SearchResultTile(
          icon: Icons.location_on_outlined,
          title: mainText,
          subtitle: secondaryText,
          onTap: () => _onPredictionTapped(prediction['place_id']),
        ).animate(delay: (50 * index).ms).fadeIn(duration: 300.ms);
      },
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.3), size: 48),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: _primaryFont,
              color: Colors.white.withOpacity(0.5),
              fontSize: 16,
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  // --- STEP 4: COPIED HELPER WIDGETS ---
  Widget _buildAnimatedGradientBackground() {
    return AnimatedBuilder(
      animation: _gradientController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(
                -1.0 + (_gradientController.value * 2),
                1.0 - (_gradientController.value * 2),
              ),
              radius: 1.5,
              colors: [
                AppColors.primaryColor.withOpacity(0.7),
                AppColors.background,
              ],
              stops: const [0.0, 1.0],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCornerBurstEffect() {
    return AnimatedBuilder(
      animation: _burstController,
      builder: (context, child) {
        final animation = CurvedAnimation(
          parent: _burstController,
          curve: Curves.easeOutCubic,
        );
        return ClipPath(
          clipper: _CircleClipper(
            radius: animation.value * MediaQuery.of(context).size.width * 1.5,
            position: const Offset(double.infinity, 0), // Top-right corner
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  AppColors.goldenrod.withOpacity(0.3),
                  AppColors.primaryColor.withOpacity(0.2),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.4, 1.0],
                center: const Alignment(1.0, -1.0), // Top-right corner
              ),
            ),
          ),
        );
      },
    );
  }
}

// --- EXISTING WIDGET (UNCHANGED) ---
class _SearchResultTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SearchResultTile({
    required this.icon,
    this.iconColor = Colors.white70,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontFamily: _primaryFont),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.white.withOpacity(0.6),
          fontFamily: _primaryFont,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: onTap,
    );
  }
}

// --- STEP 4: COPIED CUSTOM CLIPPER CLASS ---
class _CircleClipper extends CustomClipper<Path> {
  final double radius;
  final Offset position;

  _CircleClipper({required this.radius, required this.position});

  @override
  Path getClip(Size size) {
    final path = Path();
    final effectivePosition = Offset(
      position.dx.isInfinite ? size.width : position.dx,
      position.dy,
    );
    path.addOval(Rect.fromCircle(center: effectivePosition, radius: radius));
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true; // Always reclip as the radius is animating
  }
}
