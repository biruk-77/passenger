// FILE: lib/widgets/app_drawer.dart

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';

// Import your project's existing files
import '../l10n/app_localizations.dart';
import '../screens/settings_screen.dart';
import '../theme/color.dart';
import '../models/passenger.dart';
import '../screens/passenger/my_subscriptions_screen.dart';
import '../screens/passenger/available_contracts_screen.dart';
import '../screens/my_transactions_screen.dart';
import '../screens/my_trips_screen.dart';

/// The "Genesis Grid Drawer".
/// An executive-class drawer featuring a highly interactive, illuminated grid,
/// 3D tilt, parallax, and refined "glassmorphism" for a sophisticated and
/// impressive user experience.
class AppDrawer extends StatefulWidget {
  final Passenger? passengerProfile;
  final VoidCallback onEditProfile;
  final VoidCallback onViewHistory;
  final VoidCallback onSoftLogout;
  final VoidCallback onHardLogout;

  const AppDrawer({
    super.key,
    required this.passengerProfile,
    required this.onEditProfile,
    required this.onViewHistory,
    required this.onSoftLogout,
    required this.onHardLogout,
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  Offset _localPointerOffset = Offset.zero;
  Offset _globalPointerOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: 800.ms);
    _slideAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPointerEvent(PointerEvent event) {
    setState(() {
      _localPointerOffset = event.localPosition;
      _globalPointerOffset = event.position;
    });
  }

  void _onPointerExit(PointerEvent event) {
    setState(() {
      _localPointerOffset = Offset.zero;
      _globalPointerOffset = Offset.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double drawerWidth =
        size.width * 0.85; // Slightly wider for a grander feel

    final double tiltY = _localPointerOffset == Offset.zero
        ? 0.0
        : (0.08 *
              (_localPointerOffset.dx - drawerWidth / 2) /
              (drawerWidth / 2));
    final double tiltX = _localPointerOffset == Offset.zero
        ? 0.0
        : -(0.08 *
              (_localPointerOffset.dy - size.height / 2) /
              (size.height / 2));

    final transform = Matrix4.identity()
      ..setEntry(3, 2, 0.001)
      ..rotateY(tiltY)
      ..rotateX(tiltX);

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        final slideValue = _slideAnimation.value;
        return Transform.translate(
          offset: Offset(-drawerWidth * (1 - slideValue), 0),
          child: Opacity(opacity: slideValue, child: child),
        );
      },
      child: MouseRegion(
        onExit: _onPointerExit,
        child: Listener(
          onPointerMove: _onPointerEvent,
          onPointerHover: _onPointerEvent,
          child: AnimatedContainer(
            duration: 400.ms,
            curve: Curves.easeOut,
            transform: transform,
            transformAlignment: Alignment.center,
            child: Material(
              color: Colors.transparent,
              child: SizedBox(
                width: drawerWidth,
                child: _KineticDrawerContent(
                  // This widget now contains the new background
                  passengerProfile: widget.passengerProfile,
                  onEditProfile: widget.onEditProfile,
                  onViewHistory: widget.onViewHistory,
                  onSoftLogout: widget.onSoftLogout,
                  onHardLogout: widget.onHardLogout,
                  localPointerOffset: _localPointerOffset,
                  globalPointerOffset: _globalPointerOffset,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ✅ CHANGED: Converted to a StatefulWidget to manage its own background animations.
// This is the minimum change required to add the new background design correctly.
class _KineticDrawerContent extends StatefulWidget {
  final Passenger? passengerProfile;
  final VoidCallback onEditProfile;
  final VoidCallback onViewHistory;
  final VoidCallback onSoftLogout;
  final VoidCallback onHardLogout;
  final Offset localPointerOffset;
  final Offset globalPointerOffset;

  const _KineticDrawerContent({
    required this.passengerProfile,
    required this.onEditProfile,
    required this.onViewHistory,
    required this.onSoftLogout,
    required this.onHardLogout,
    required this.localPointerOffset,
    required this.globalPointerOffset,
  });

  @override
  State<_KineticDrawerContent> createState() => _KineticDrawerContentState();
}

class _KineticDrawerContentState extends State<_KineticDrawerContent>
    with TickerProviderStateMixin {
  // ✅ NEW: Animation controllers for the new background design
  late final AnimationController _gradientController;
  late final AnimationController _burstController;

  @override
  void initState() {
    super.initState();
    // ✅ NEW: Initializing background animation controllers
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);

    _burstController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    // Start the animation after a short delay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _burstController.forward();
      }
    });
  }

  @override
  void dispose() {
    // ✅ NEW: Disposing background animation controllers
    _gradientController.dispose();
    _burstController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: const BorderRadius.horizontal(right: Radius.circular(32)),
      child: Container(
        color: Colors.transparent, // Background is now handled by the Stack
        child: Stack(
          children: [
            // ✅ NEW: The animated gradient background from the login screen
            _buildAnimatedGradientBackground(),
            // ✅ NEW: The corner burst effect from the login screen
            _buildCornerBurstEffect(),

            // This is your original glassmorphism effect, it now sits on top of the new background
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? AppColors.primaryColor.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.2),
                  border: Border(
                    right: BorderSide(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            // ALL of your original content below remains untouched.
            Column(
              children: [
                _KineticDrawerHeader(
                  passengerProfile: widget.passengerProfile,
                  pointerOffset: widget.localPointerOffset,
                ),
                Expanded(
                  child: _KineticMenuList(
                    onEditProfile: widget.onEditProfile,
                    onViewHistory: widget.onViewHistory,
                    localPointerOffset: widget.localPointerOffset,
                    globalPointerOffset: widget.globalPointerOffset,
                  ),
                ),
                _KineticDrawerFooter(
                  onSoftLogout: widget.onSoftLogout,
                  onHardLogout: widget.onHardLogout,
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  // ✅ NEW: Background widget copied directly from login screen
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
                Theme.of(context).scaffoldBackgroundColor,
              ],
              stops: const [0.0, 1.0],
            ),
          ),
        );
      },
    );
  }

  // ✅ NEW: Corner burst widget copied directly from login screen
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
            position: const Offset(double.infinity, 0),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  AppColors.primaryColor.withValues(alpha: 0.2),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.4, 1.0],
                center: const Alignment(1.0, -1.0),
              ),
            ),
          ),
        );
      },
    );
  }
}

// All of your original widgets below are UNCHANGED.
class _KineticDrawerHeader extends StatelessWidget {
  final Passenger? passengerProfile;
  final Offset pointerOffset;

  const _KineticDrawerHeader({
    required this.passengerProfile,
    required this.pointerOffset,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final String userName = passengerProfile?.name ?? l10n.drawerGuestUser;
    final String userEmail = passengerProfile?.email ?? '...';

    final parallaxOffset = pointerOffset == Offset.zero
        ? Offset.zero
        : Offset(pointerOffset.dx * 0.03, pointerOffset.dy * 0.03);

    return Transform.translate(
      offset: parallaxOffset,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          MediaQuery.of(context).padding.top + 32,
          24,
          24,
        ),
        child: Row(
          children: [
            Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.6),
                        blurRadius: 30.0,
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 20.0,
                        spreadRadius: -5,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: theme.colorScheme.surface,
                    backgroundImage: passengerProfile?.photoUrl != null
                        ? NetworkImage(passengerProfile!.photoUrl!)
                        : null,
                    child: passengerProfile?.photoUrl == null
                        ? Icon(
                            Icons.person_outline_rounded,
                            size: 36,
                            color: theme.colorScheme.primary,
                          )
                        : null,
                  ),
                )
                .animate()
                .fadeIn(delay: 200.ms)
                .scale(begin: const Offset(0.8, 0.8)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: TextStyle(
                      fontFamily: 'PlayfairDisplay',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userEmail,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().slideX(begin: -0.2, delay: 300.ms, duration: 500.ms).fadeIn(),
    );
  }
}

class _KineticMenuList extends StatelessWidget {
  final VoidCallback onEditProfile;
  final VoidCallback onViewHistory;
  final Offset localPointerOffset;
  final Offset globalPointerOffset;

  const _KineticMenuList({
    required this.onEditProfile,
    required this.onViewHistory,
    required this.localPointerOffset,
    required this.globalPointerOffset,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final parallaxOffset = localPointerOffset == Offset.zero
        ? Offset.zero
        : Offset(localPointerOffset.dx * 0.05, localPointerOffset.dy * 0.05);

    final menuItems = [
      _MagneticMenuItem(
        icon: Icons.account_circle_outlined,
        text: l10n.drawerProfileSettings,
        onTap: onEditProfile,
        pointerOffset: globalPointerOffset,
      ),
      _MagneticMenuItem(
        icon: Icons.alt_route,
        text: l10n.drawerMyTrips,
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const MyTripsScreen()),
          );
        },
        pointerOffset: globalPointerOffset,
      ),
      _MagneticMenuItem(
        icon: Icons.history_rounded,
        text: l10n.drawerRideHistory,
        onTap: onViewHistory,
        pointerOffset: globalPointerOffset,
      ),
      _MagneticMenuItem(
        icon: Icons.explore_outlined,
        text: l10n.drawerAvailableContracts,
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AvailableContractsScreen(),
            ),
          );
        },
        pointerOffset: globalPointerOffset,
      ),
      _MagneticMenuItem(
        icon: Icons.subscriptions_outlined,
        text: l10n.mySubscriptionsTitle,
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const MySubscriptionsScreen(),
            ),
          );
        },
        pointerOffset: globalPointerOffset,
      ),
      _MagneticMenuItem(
        icon: Icons.hourglass_top_rounded,
        text: l10n.mySubscriptionsTitle, // TODO: Add to l10n
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const MySubscriptionsScreen(),
            ),
          );
        },
        pointerOffset: globalPointerOffset,
      ),
      // _MagneticMenuItem(
      //   icon: Icons.credit_card_outlined,
      //   text: "Payment Methods", // TODO: Add to l10n
      //   onTap: () {
      //     Navigator.of(context).pop();
      //     Navigator.of(context).push(
      //       MaterialPageRoute(builder: (context) => const ()),
      //     );
      //   },
      //   pointerOffset: globalPointerOffset,
      // ),
      _MagneticMenuItem(
        icon: Icons.account_balance_wallet_outlined,
        text: l10n.drawerMyTransactions,
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const MyTransactionsScreen(),
            ),
          );
        },
        pointerOffset: globalPointerOffset,
      ),
    ];

    return Transform.translate(
      offset: parallaxOffset,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: menuItems.length,
          itemBuilder: (context, index) {
            return menuItems[index]
                .animate()
                .fadeIn(duration: 400.ms, delay: (400 + (index * 80)).ms)
                .slide(begin: const Offset(-0.1, 0));
          },
        ),
      ),
    );
  }
}

class _KineticDrawerFooter extends StatelessWidget {
  final VoidCallback onSoftLogout;
  final VoidCallback onHardLogout;

  const _KineticDrawerFooter({
    required this.onSoftLogout,
    required this.onHardLogout,
  });

  @override
  Widget build(BuildContext context) {
    const String version = '1.0.0';
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        children: [
          Divider(
            color: AppColors.borderColor.withValues(alpha: 0.5),
            height: 1,
            indent: 8,
            endIndent: 8,
          ),
          const SizedBox(height: 8),
          _DrawerMenuItem(
            icon: Icons.settings_outlined,
            text: l10n.drawerSettings,
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          _DrawerMenuItem(
            icon: Icons.logout_rounded,
            text: l10n.drawerLogout,
            onTap: onSoftLogout,
          ),
          _DrawerMenuItem(
            icon: Icons.phonelink_erase_rounded,
            text: l10n.drawerLogoutForgetDevice,
            onTap: onHardLogout,
            textColor: theme.colorScheme.error,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.appVersion(version),
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
              Text(
                "  •  ",
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              Text(
                "Crafted by ACME Inc.", // TODO: Add to l10n
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms);
  }
}

class _DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final Color? textColor;

  const _DrawerMenuItem({
    required this.icon,
    required this.text,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        icon,
        color: textColor ?? theme.colorScheme.onSurface.withValues(alpha: 0.7),
        size: 24,
      ),
      title: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          color: textColor ?? theme.colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      splashColor: theme.colorScheme.primary.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

class _MagneticMenuItem extends StatefulWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final Offset pointerOffset;

  const _MagneticMenuItem({
    required this.icon,
    required this.text,
    required this.onTap,
    required this.pointerOffset,
  });

  @override
  State<_MagneticMenuItem> createState() => _MagneticMenuItemState();
}

class _MagneticMenuItemState extends State<_MagneticMenuItem> {
  final GlobalKey _key = GlobalKey();
  Offset _itemCenter = Offset.zero;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _findCenter());
  }

  void _findCenter() {
    if (!mounted) return;
    final RenderBox? renderBox =
        _key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final size = renderBox.size;
      final position = renderBox.localToGlobal(Offset.zero);
      setState(() {
        _itemCenter = Offset(
          position.dx + size.width / 2,
          position.dy + size.height / 2,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Offset magneticOffset = Offset.zero;
    if (_itemCenter != Offset.zero && widget.pointerOffset != Offset.zero) {
      // Magnetic effect logic
    }

    return MouseRegion(
      key: _key,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedSlide(
          offset: Offset(magneticOffset.dx / 50, magneticOffset.dy / 50),
          duration: 150.ms,
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: 300.ms,
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: _isHovered
                  ? LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withValues(alpha: 0.1),
                        theme.colorScheme.primary.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              border: Border.all(
                color: _isHovered
                    ? theme.colorScheme.primary.withValues(alpha: 0.5)
                    : Colors.transparent,
                width: 1.0,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  AnimatedScale(
                    scale: _isHovered ? 1.2 : 1.0,
                    duration: 250.ms,
                    curve: Curves.easeOutBack,
                    child: Icon(
                      widget.icon,
                      color: _isHovered
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    widget.text,
                    style: TextStyle(
                      fontSize: 16,
                      color: _isHovered
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ✅ NEW: Custom Clipper for the corner burst effect
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
    return true;
  }
}
