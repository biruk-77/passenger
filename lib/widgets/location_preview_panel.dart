import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../l10n/app_localizations.dart';
import '../models/search_result.dart';
import '../utils/enums.dart';
import '../theme/color.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // <--- ADDED THIS IMPORT

class LocationPreviewPanel extends StatelessWidget {
  final PlaceDetails place;
  final VoidCallback onClear;
  final MapPickingMode pickingMode;
  final VoidCallback? onConfirmPickup; // For setting pickup location
  final VoidCallback? onConfirmDestination; // For setting destination
  final VoidCallback? onSaveHome;
  final VoidCallback? onSaveWork;
  final VoidCallback? onAddFavorite;
  final VoidCallback? onGoToDestination; // Direct routing from discovery
  final bool canGoToDestination;
  final LatLng? existingPickup; // Current pickup if set
  final LatLng? existingDestination; // Current destination if set
  final bool isPickupSet; // Whether pickup is already set
  final bool isDestinationSet; // Whether destination is already set

  const LocationPreviewPanel({
    super.key,
    required this.place,
    required this.onClear,
    required this.pickingMode,
    this.onConfirmPickup,
    this.onConfirmDestination,
    this.onSaveHome,
    this.onSaveWork,
    this.onAddFavorite,
    this.onGoToDestination,
    this.canGoToDestination = true,
    this.existingPickup,
    this.existingDestination,
    this.isPickupSet = false,
    this.isDestinationSet = false,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: FadeInUp(
        duration: const Duration(milliseconds: 400),
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 30,
                spreadRadius: 5,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF0D1B3E).withValues(alpha: 0.9),
                      const Color(0xFF040A1A).withValues(alpha: 0.95),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPlaceInfo(),
                    const SizedBox(height: 20),
                    _buildIntelligentActionSection(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceInfo() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.goldenrod.withValues(alpha: 0.3),
                Colors.orangeAccent.withValues(alpha: 0.2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.location_on_rounded,
            color: AppColors.goldenrod,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                place.primaryText,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (place.secondaryText != null &&
                  place.secondaryText!.isNotEmpty)
                const SizedBox(height: 4),
              if (place.secondaryText != null &&
                  place.secondaryText!.isNotEmpty)
                Text(
                  place.secondaryText!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        _buildCloseButton(),
      ],
    );
  }

  Widget _buildCloseButton() {
    return GestureDetector(
      onTap: onClear,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.close_rounded,
          color: Colors.white.withValues(alpha: 0.7),
          size: 20,
        ),
      ),
    );
  }

  /// Intelligent action builder that adapts to the current selection context
  Widget _buildIntelligentActionSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Handle specific picking modes first, these modes usually imply a single primary action
    switch (pickingMode) {
      case MapPickingMode.setPickup:
        return _buildPrimaryActionButton(
          icon: Icons.my_location_rounded,
          text: l10n.confirmPickup,
          onPressed: onConfirmPickup,
          color: Colors.blueAccent,
        );

      case MapPickingMode.setDestination:
        return _buildPrimaryActionButton(
          icon: Icons.flag_rounded,
          text: l10n.confirmDestination,
          onPressed: onConfirmDestination,
          color: Colors.greenAccent,
        );

      case MapPickingMode.setHome:
        return _buildPrimaryActionButton(
          icon: Icons.home_filled,
          text: l10n.discoverySetHome,
          onPressed: onSaveHome,
          color: Colors.orangeAccent,
        );

      case MapPickingMode.setWork:
        return _buildPrimaryActionButton(
          icon: Icons.work_rounded,
          text: l10n.discoverySetWork,
          onPressed: onSaveWork,
          color: Colors.purpleAccent,
        );

      case MapPickingMode.addFavorite:
        return _buildPrimaryActionButton(
          icon: Icons.star_rounded,
          text: l10n.discoveryAddFavorite,
          onPressed: onAddFavorite,
          color: AppColors.goldenrod,
        );

      default:
        // If pickingMode is MapPickingMode.none (default),
        // revert to context-aware actions. This is the "general panel" part.
        return _buildContextAwareActions(context, l10n);
    }
  }

  /// Builds actions based on whether pickup/destination are already set
  Widget _buildContextAwareActions(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    // Case 1: Neither pickup nor destination is set - show setup options
    if (!isPickupSet && !isDestinationSet) {
      return Column(
        children: [
          _buildPrimaryActionButton(
            icon: Icons.my_location_rounded,
            text: l10n.setAsPickupLocation,
            onPressed: onConfirmPickup,
            color: Colors.blueAccent,
          ),
          const SizedBox(height: 12),
          // Add "Go to Destination" if applicable, otherwise just save options
          if (canGoToDestination && onGoToDestination != null) ...[
            _buildPrimaryActionButton(
              icon: Icons.directions_rounded,
              text: l10n.goToDestination,
              onPressed: onGoToDestination,
              color: AppColors.goldenrod,
            ),
            const SizedBox(height: 12),
          ],
          _buildSecondaryActionsRow(l10n),
        ],
      );
    }

    // Case 2: Only pickup is set - show destination options
    if (isPickupSet && !isDestinationSet) {
      return Column(
        children: [
          _buildPrimaryActionButton(
            icon: Icons.flag_rounded,
            text: l10n.setAsDestination,
            onPressed: onConfirmDestination,
            color: Colors.greenAccent,
          ),
          const SizedBox(height: 12),
          _buildSecondaryActionsRow(l10n),
        ],
      );
    }

    // Case 3: Both are set - show routing and save options
    if (isPickupSet && isDestinationSet) {
      return Row(
        children: [
          Expanded(
            child: _buildPrimaryActionButton(
              icon: Icons.directions_rounded,
              text: l10n.updateRoute,
              onPressed:
                  onConfirmDestination, // This will re-plan the route with the new destination
              color: AppColors.goldenrod,
            ),
          ),
          const SizedBox(width: 12),
          _buildSaveMenuButton(l10n),
        ],
      );
    }

    // Fallback if none of the above (shouldn't typically be reached if logic is sound)
    // This handles discovery mode with a tapped place where canGoToDestination is key.
    return Column(
      children: [
        _buildPrimaryActionButton(
          icon: Icons.directions_rounded,
          text: canGoToDestination ? l10n.goToDestination : l10n.setPickupFirst,
          onPressed: canGoToDestination ? onGoToDestination : null,
          color: AppColors.goldenrod,
        ),
        const SizedBox(height: 12),
        _buildSecondaryActionsRow(l10n),
      ],
    );
  }

  Widget _buildPrimaryActionButton({
    required IconData icon,
    required String text,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          disabledBackgroundColor: Colors.grey.shade600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          shadowColor: color.withValues(alpha: 0.3),
        ),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryActionsRow(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _buildSecondaryButton(
            icon: Icons.home_rounded,
            text: l10n.saveHome,
            onPressed: onSaveHome,
            color: Colors.orangeAccent,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSecondaryButton(
            icon: Icons.work_rounded,
            text: l10n.saveWork,
            onPressed: onSaveWork,
            color: Colors.purpleAccent,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSecondaryButton(
            icon: Icons.star_rounded,
            text: l10n.addFavorite,
            onPressed: onAddFavorite,
            color: AppColors.goldenrod,
          ),
        ),
      ],
    );
  }

  Widget _buildSecondaryButton({
    required IconData icon,
    required String text,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return OutlinedButton.icon(
      icon: Icon(icon, size: 18, color: color),
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.5)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: color.withValues(alpha: 0.1),
      ),
      label: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// Enhanced save menu with better UX
  Widget _buildSaveMenuButton(AppLocalizations l10n) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'home':
            onSaveHome?.call();
            break;
          case 'work':
            onSaveWork?.call();
            break;
          case 'favorite':
            onAddFavorite?.call();
            break;
        }
      },
      color: const Color(0xFF1A2C55),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
      ),
      elevation: 8,
      offset: const Offset(0, -120),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        _buildPopupMenuItem(
          value: 'home',
          icon: Icons.home_filled,
          title: l10n.saveAsHome,
          color: Colors.orangeAccent,
        ),
        const PopupMenuDivider(height: 8),
        _buildPopupMenuItem(
          value: 'work',
          icon: Icons.work_rounded,
          title: l10n.saveAsWork,
          color: Colors.purpleAccent,
        ),
        const PopupMenuDivider(height: 8),
        _buildPopupMenuItem(
          value: 'favorite',
          icon: Icons.star_rounded,
          title: l10n.addToFavorites,
          color: AppColors.goldenrod,
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: const Icon(
          Icons.bookmark_add_rounded,
          color: AppColors.goldenrod,
          size: 24,
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem({
    required String value,
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return PopupMenuItem<String>(
      value: value,
      height: 48,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
