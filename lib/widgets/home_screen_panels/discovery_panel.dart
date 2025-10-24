// lib/widgets/home_screen_panels/discovery_panel.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../providers/saved_places_provider.dart';
import '../../theme/color.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/enums.dart';

// ✅ CONVERTED TO STATEFULWIDGET FOR ANIMATIONS
class DiscoveryPanelContent extends StatefulWidget {
  final VoidCallback onSearchTap;
  final void Function(SavedPlace) onSavedPlaceTap;
  final LatLng? userLocation;
  final VoidCallback onProfileTap;
  final OnEnterPickingMode onEnterPickingMode;

  const DiscoveryPanelContent({
    super.key,
    required this.onSearchTap,
    required this.onProfileTap,
    required this.onSavedPlaceTap,
    this.userLocation,
    required this.onEnterPickingMode,
  });

  @override
  State<DiscoveryPanelContent> createState() => _DiscoveryPanelContentState();
}

class _DiscoveryPanelContentState extends State<DiscoveryPanelContent>
    with TickerProviderStateMixin {
  // ✅ ADDED ANIMATION CONTROLLERS
  late final AnimationController _gradientController;
  late final AnimationController _burstController;

  @override
  void initState() {
    super.initState();
    // ✅ INITIALIZED ANIMATION CONTROLLERS
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
  }

  @override
  void dispose() {
    // ✅ DISPOSED ANIMATION CONTROLLERS
    _gradientController.dispose();
    _burstController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // ✅ REFACTORED BUILD METHOD WITH NEW BACKGROUND
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32.0)),
      child: Stack(
        children: [
          // ✅ ADDED NEW BACKGROUND
          _buildAnimatedGradientBackground(),
          _buildCornerBurstEffect(),

          // Original content with BackdropFilter
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.background.withValues(alpha: 0.25),
                border: Border.all(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                ),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 12.0,
                  ),
                  // ✅ WRAPPED CONTENT IN FADEINUP FOR SYNCHRONIZED ANIMATION
                  child: FadeInUp(
                    delay: const Duration(milliseconds: 1200),
                    duration: const Duration(milliseconds: 600),
                    from: 50,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(child: _PremiumPanelHandle()),
                        const SizedBox(height: 20),
                        _buildHeader(context, l10n),
                        const SizedBox(height: 24),
                        _buildSearchBar(context, l10n),
                        const SizedBox(height: 20),
                        _buildQuickActions(context, l10n),
                        const SizedBox(height: 24),
                        _buildSavedPlacesSection(context, l10n),
                        const SizedBox(height: 28),
                        _buildTabBarSection(context, l10n),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ALL WIDGETS BELOW ARE REFACTORED TO BE THEME-AWARE
  // NO LOGIC HAS BEEN CHANGED

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.discoveryWhereTo,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Explore your favorite destinations",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        _PremiumProfileButton(onTap: widget.onProfileTap),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: widget.onSearchTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.onSurface.withValues(alpha: 0.15),
              theme.colorScheme.onSurface.withValues(alpha: 0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_rounded,
                color: theme.colorScheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                l10n.discoverySearchDestination,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Search",
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionButton(
            icon: Icons.favorite_border_rounded,
            label: "Add Favorite",
            color: Theme.of(context).colorScheme.primary,
            onTap: () => widget.onEnterPickingMode(MapPickingMode.addFavorite),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.history_rounded,
            label: "Recent",
            color: AppColors.info,
            onTap: () => _scrollToRecents(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.delete_outline_rounded,
            label: "Clear All",
            color: AppColors.error,
            onTap: () => _showClearAllDialog(context, l10n),
          ),
        ),
      ],
    );
  }

  Widget _buildSavedPlacesSection(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Consumer<SavedPlacesProvider>(
      builder: (context, placesProvider, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.onSurface.withValues(alpha: 0.12),
                theme.colorScheme.onSurface.withValues(alpha: 0.06),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
            ),
          ),
          child: Column(
            children: [
              _PremiumSavedPlaceTile(
                icon: Icons.home_filled,
                title:
                    placesProvider.homePlace?.primaryText ?? l10n.discoveryHome,
                subtitle:
                    placesProvider.homePlace?.secondaryText ??
                    l10n.discoveryAddHome,
                isSet: placesProvider.homePlace != null,
                color: AppColors.warning,
                onTap: () {
                  if (placesProvider.homePlace != null) {
                    widget.onSavedPlaceTap(placesProvider.homePlace!);
                  } else {
                    widget.onEnterPickingMode(MapPickingMode.setHome);
                  }
                },
                onLongPress: placesProvider.homePlace != null
                    ? () =>
                          _showPlaceMenu(context, l10n, placesProvider, 'home')
                    : null,
              ),
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      theme.colorScheme.onSurface.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              _PremiumSavedPlaceTile(
                icon: Icons.work_rounded,
                title:
                    placesProvider.workPlace?.primaryText ?? l10n.discoveryWork,
                subtitle:
                    placesProvider.workPlace?.secondaryText ??
                    l10n.discoveryAddWork,
                isSet: placesProvider.workPlace != null,
                color: AppColors.info,
                onTap: () {
                  if (placesProvider.workPlace != null) {
                    widget.onSavedPlaceTap(placesProvider.workPlace!);
                  } else {
                    widget.onEnterPickingMode(MapPickingMode.setWork);
                  }
                },
                onLongPress: placesProvider.workPlace != null
                    ? () =>
                          _showPlaceMenu(context, l10n, placesProvider, 'work')
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabBarSection(BuildContext context, AppLocalizations l10n) {
    return _PremiumTabBarSection(
      l10n: l10n,
      onSavedPlaceTap: widget.onSavedPlaceTap,
      onEnterPickingMode: widget.onEnterPickingMode,
      onShowMenu: (place) => _showPlaceMenu(
        context,
        l10n,
        Provider.of<SavedPlacesProvider>(context, listen: false),
        'favorite',
        place,
      ),
    );
  }

  void _scrollToRecents(BuildContext context) {}

  void _showClearAllDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => _PremiumConfirmationDialog(
        title: "Clear All Data?",
        content:
            "This will remove all your home, work, favorites, and recent places. This action cannot be undone.",
        confirmText: "Clear Everything",
        onConfirm: () {
          final provider = Provider.of<SavedPlacesProvider>(
            context,
            listen: false,
          );
          provider.clearAllData();
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("All data cleared successfully"),
              backgroundColor: AppColors.success,
            ),
          );
        },
      ),
    );
  }

  void _showPlaceMenu(
    BuildContext context,
    AppLocalizations l10n,
    SavedPlacesProvider provider,
    String type, [
    SavedPlace? place,
  ]) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return _PremiumActionSheet(
          title: _getMenuTitle(type, place),
          actions: [
            _ActionSheetItem(
              icon: Icons.edit_location_alt_rounded,
              title: "Change Address",
              color: Theme.of(context).colorScheme.primary,
              onTap: () {
                Navigator.of(context).pop();
                if (type == 'home')
                  {widget.onEnterPickingMode(MapPickingMode.setHome);}
                if (type == 'work') {
                  widget.onEnterPickingMode(MapPickingMode.setWork);
                }
                if (type == 'favorite') {
                  widget.onEnterPickingMode(MapPickingMode.addFavorite);
                }
              },
            ),
            _ActionSheetItem(
              icon: Icons.delete_forever_rounded,
              title: "Remove",
              color: Theme.of(context).colorScheme.error,
              onTap: () {
                Navigator.of(context).pop();
                if (type == 'home') provider.deleteHome();
                if (type == 'work') provider.deleteWork();
                if (type == 'favorite' && place != null) {
                  provider.removeFavorite(place);
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Place removed successfully"),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  String _getMenuTitle(String type, SavedPlace? place) {
    switch (type) {
      case 'home':
        return 'Home Address';
      case 'work':
        return 'Work Address';
      case 'favorite':
        return place?.primaryText ?? 'Favorite Place';
      default:
        return 'Place Options';
    }
  }

  // ✅ HELPER WIDGETS COPIED FROM TEMPLATE
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
                AppColors.primaryColor.withValues(alpha: 0.7),
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
                  AppColors.goldenrod.withValues(alpha: 0.3),
                  AppColors.primaryColor.withValues(alpha: 0.2),
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

// ALL SUB-WIDGETS BELOW ARE NOW THEME-AWARE

class _PremiumPanelHandle extends StatelessWidget {
  const _PremiumPanelHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 5,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

class _PremiumProfileButton extends StatelessWidget {
  final VoidCallback onTap;

  const _PremiumProfileButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.3),
              AppColors.warning.withValues(alpha: 0.2),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
          ),
        ),
        child: Icon(Icons.person_rounded, color: theme.colorScheme.onSurface),
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
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
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

  const _PremiumSavedPlaceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSet,
    required this.color,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isSet
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurface.withValues(
                                alpha: 0.8,
                              ),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
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
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  size: 20,
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Add",
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
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

class _PremiumTabBarSection extends StatefulWidget {
  final AppLocalizations l10n;
  final void Function(SavedPlace) onSavedPlaceTap;
  final OnEnterPickingMode onEnterPickingMode;
  final void Function(SavedPlace) onShowMenu;

  const _PremiumTabBarSection({
    required this.l10n,
    required this.onSavedPlaceTap,
    required this.onEnterPickingMode,
    required this.onShowMenu,
  });

  @override
  State<_PremiumTabBarSection> createState() => _PremiumTabBarSectionState();
}

class _PremiumTabBarSectionState extends State<_PremiumTabBarSection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TabBar(
              controller: _tabController,
              indicatorColor: theme.colorScheme.primary,
              labelColor: theme.colorScheme.onSurface,
              unselectedLabelColor: theme.colorScheme.onSurface.withValues(
                alpha: 0.6,
              ),
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.symmetric(horizontal: 10),
              labelStyle: theme.textTheme.labelLarge,
              tabs: [
                Tab(text: widget.l10n.discoveryFavoritePlaces),
                Tab(text: widget.l10n.discoveryRecentTrips),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 280,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFavoritesList(context),
                _buildRecentsList(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(BuildContext context) {
    final placesProvider = context.watch<SavedPlacesProvider>();
    final theme = Theme.of(context);

    return Stack(
      children: [
        Positioned.fill(
          child: placesProvider.favoritePlaces.isEmpty
              ? _PremiumEmptyState(
                  icon: Icons.star_border_rounded,
                  title: "No Favorites Yet",
                  message:
                      "Tap the button below to add your first favorite place",
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 60),
                  itemCount: placesProvider.favoritePlaces.length,
                  itemBuilder: (context, index) {
                    final place = placesProvider.favoritePlaces[index];
                    return _PremiumPlaceTile(
                      icon: Icons.star_rounded,
                      iconColor: theme.colorScheme.primary,
                      title: place.primaryText,
                      subtitle: place.secondaryText ?? '',
                      onTap: () => widget.onSavedPlaceTap(place),
                      onLongPress: () => widget.onShowMenu(place),
                      showMenu: true,
                    );
                  },
                ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () =>
                widget.onEnterPickingMode(MapPickingMode.addFavorite),
            backgroundColor: theme.colorScheme.primary,
            mini: true,
            child: Icon(Icons.add, color: theme.colorScheme.onPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentsList(BuildContext context) {
    final placesProvider = context.watch<SavedPlacesProvider>();
    final theme = Theme.of(context);

    return Column(
      children: [
        if (placesProvider.recentPlaces.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${placesProvider.recentPlaces.length} ${widget.l10n.recentTrips}",
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      _showClearRecentsDialog(context, widget.l10n),
                  child: Text(
                    widget.l10n.discoveryClearAll,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (placesProvider.recentPlaces.isEmpty)
          const Expanded(
            child: _PremiumEmptyState(
              icon: Icons.history_toggle_off_rounded,
              title: "No Recent Trips",
              message: "Your recent destinations will appear here",
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: placesProvider.recentPlaces.length,
              itemBuilder: (context, index) {
                final place = placesProvider.recentPlaces[index];
                return Dismissible(
                  key: ValueKey(
                    place.primaryText + (place.secondaryText ?? ''),
                  ),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Icon(
                      Icons.delete_forever,
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                  onDismissed: (_) {
                    context.read<SavedPlacesProvider>().deleteRecent(place);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(widget.l10n.discoveryRecentTripRemoved),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  child: _PremiumPlaceTile(
                    icon: Icons.history_rounded,
                    title: place.primaryText,
                    subtitle: place.secondaryText ?? '',
                    onTap: () => widget.onSavedPlaceTap(place),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  void _showClearRecentsDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => _PremiumConfirmationDialog(
        title: "${l10n.discoveryClearAll}?",
        content:
            "This will remove all your recent trip history. This action cannot be undone.",
        confirmText: l10n.discoveryClearAll,
        onConfirm: () {
          context.read<SavedPlacesProvider>().clearRecents();
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Recent trips cleared"),
              backgroundColor: AppColors.success,
            ),
          );
        },
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
    final theme = Theme.of(context);
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
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color:
                      iconColor ??
                      theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
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
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    size: 20,
                  ),
                  onPressed: onLongPress,
                )
              else
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
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
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[const SizedBox(height: 20), action!],
        ],
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
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(title, style: theme.textTheme.titleLarge),
          ),
          ...actions,
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
              Text(title, style: Theme.of(context).textTheme.titleMedium),
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
    final theme = Theme.of(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.colorScheme.surface, theme.colorScheme.background],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 16),
              Text(
                content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
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
                        backgroundColor: theme.colorScheme.onSurface.withValues(
                          alpha: 0.1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: theme.colorScheme.onSurface),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: theme.colorScheme.onError,
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

// ✅ CUSTOM CLIPPER CLASS COPIED FROM TEMPLATE
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
