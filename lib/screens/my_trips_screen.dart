// lib/screens/passenger/my_trips_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/contract/trip.dart';
import '../../viewmodels/my_trips_viewmodel.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../theme/color.dart';
import '../../theme/styles.dart';

// STEP 1: animate_do import added for consistency, though not used in background helpers
import 'package:animate_do/animate_do.dart';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen>
    with TickerProviderStateMixin {
  // STEP 2: ADDED ANIMATION CONTROLLERS
  late final AnimationController _gradientController;
  late final AnimationController _burstController;

  late MyTripsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    // STEP 3: INITIALIZED CONTROLLERS
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

    // Original init logic is preserved
    _viewModel = MyTripsViewModel(
      Provider.of<ApiService>(context, listen: false),
      Provider.of<AuthService>(context, listen: false),
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _viewModel.fetchMyTrips();
      }
    });
  }

  // STEP 3: ADDED DISPOSE METHOD FOR CONTROLLERS & VIEWMODEL
  @override
  void dispose() {
    _gradientController.dispose();
    _burstController.dispose();
    _viewModel.dispose(); // Dispose the view model as well
    super.dispose();
  }

  (String, Color, IconData) _getLocalizedStatus(
    BuildContext context,
    String status,
  ) {
    final l10n = AppLocalizations.of(context)!;
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return (
          l10n.tripStatusCompleted,
          AppColors.success,
          Icons.check_circle_outline,
        );
      case 'STARTED':
        return (
          l10n.tripStatusStarted,
          AppColors.info,
          Icons.play_circle_outline_rounded,
        );
      case 'PENDING':
        return (
          l10n.tripStatusPending,
          AppColors.warning,
          Icons.hourglass_empty_rounded,
        );
      case 'CANCELLED':
        return (
          l10n.tripStatusCancelled,
          AppColors.error,
          Icons.cancel_outlined,
        );
      default:
        return (status, AppColors.textSubtle, Icons.info_outline);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ChangeNotifierProvider<MyTripsViewModel>.value(
      value: _viewModel,
      child: Scaffold(
        // STEP 5: REMOVED OLD BACKGROUND COLOR
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(l10n.myTripsScreenTitle, style: AppTextStyles.screenTitle)
              .animate()
              .fadeIn(duration: 600.ms, delay: 200.ms)
              .slideY(begin: 0.2, end: 0),
          actions: [
            IconButton(
                  icon: const Icon(Icons.refresh, color: AppColors.iconColor),
                  onPressed: _viewModel.fetchMyTrips,
                  tooltip: l10n.myTripsScreenRefresh,
                )
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(
                  delay: 2.seconds,
                  duration: 1.5.seconds,
                  color: AppColors.accentColor.withOpacity(0.5),
                )
                .animate()
                .fadeIn(duration: 600.ms, delay: 400.ms),
          ],
        ),
        // STEP 5: WRAPPED BODY IN A STACK WITH NEW BACKGROUND LAYERS
        body: Stack(
          children: [
            _buildAnimatedGradientBackground(),
            _buildCornerBurstEffect(),
            Consumer<MyTripsViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading && viewModel.trips.isEmpty) {
                  return _buildLoadingState();
                }

                if (viewModel.errorMessage != null) {
                  return _buildErrorState(context, viewModel);
                }

                if (viewModel.trips.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.explore_off_outlined,
                          size: 60,
                          color: AppColors.textSubtle,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.myTripsScreenNoTrips,
                          style: AppTextStyles.cardSubtitle.copyWith(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    // STEP 6: SYNCHRONIZED ANIMATION DELAY
                  ).animate().fadeIn(
                    duration: 500.ms,
                    delay: const Duration(milliseconds: 1200),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  itemCount: viewModel.trips.length,
                  itemBuilder: (context, index) {
                    final trip = viewModel.trips[index];
                    final statusInfo = _getLocalizedStatus(
                      context,
                      trip.status,
                    );

                    return _TripCard(trip: trip, statusInfo: statusInfo)
                        .animate()
                        .fadeIn(
                          duration: 500.ms,
                          delay: (100 * index).ms,
                          curve: Curves.easeOutCubic,
                        )
                        .slideX(begin: 0.2, end: 0, curve: Curves.easeOutCubic)
                        .then(delay: 100.ms)
                        .shimmer(
                          duration: 1.seconds,
                          color: AppColors.primaryColor.withOpacity(0.3),
                        );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: AppColors.primaryColor,
      highlightColor: AppColors.accentColor,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        itemCount: 5,
        itemBuilder: (context, index) => const _ShimmerCard(),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, MyTripsViewModel viewModel) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.signal_wifi_off_rounded,
              color: AppColors.error,
              size: 50,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.myTripsScreenErrorPrefix(viewModel.errorMessage!),
              textAlign: TextAlign.center,
              style: AppTextStyles.cardSubtitle.copyWith(
                color: AppColors.error,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: viewModel.fetchMyTrips,
                  label: Text(
                    l10n.myTripsScreenRetry,
                    style: AppTextStyles.buttonText,
                  ),
                )
                .animate(onPlay: (c) => c.repeat(period: 3.seconds))
                .shake(hz: 2, rotation: 0.01, delay: 1.5.seconds),
          ],
        ),
      ),
      // STEP 6: SYNCHRONIZED ANIMATION DELAY
    ).animate().fadeIn(
      duration: 400.ms,
      delay: const Duration(milliseconds: 1200),
    );
  }

  // STEP 4: COPIED HELPER WIDGETS
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

class _TripCard extends StatelessWidget {
  final Trip trip;
  final (String, Color, IconData) statusInfo;

  const _TripCard({required this.trip, required this.statusInfo});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

    // ✅✅✅ START OF FIX ✅✅✅
    // Safely format the dates. If a date is null, use the "N/A" string.
    final pickupTimeFormatted = trip.actualPickupTime != null
        ? dateFormat.format(trip.actualPickupTime!)
        : l10n.myTripsScreenNotAvailable;

    final dropoffTimeFormatted = trip.actualDropoffTime != null
        ? dateFormat.format(trip.actualDropoffTime!)
        : l10n.myTripsScreenNotAvailable;
    // ✅✅✅ END OF FIX ✅✅✅

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.electricCyan.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: -5,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(statusInfo.$3, color: statusInfo.$2, size: 18)
                        .animate(
                          onPlay: (controller) =>
                              controller.repeat(reverse: true),
                        )
                        .scaleXY(
                          end: 1.2,
                          duration: 1.5.seconds,
                          curve: Curves.easeInOut,
                        )
                        .then(delay: 2.seconds),
                    const SizedBox(width: 8),
                    Text(
                      statusInfo.$1,
                      style: AppTextStyles.cardSubtitle.copyWith(
                        color: statusInfo.$2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${l10n.myTripsScreenTripIdPrefix}${trip.id.substring(0, 8)}...',
                      style: AppTextStyles.cardSubtitle.copyWith(
                        color: AppColors.textSubtle,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Divider(
                  height: 24,
                  color: AppColors.borderColor.withOpacity(0.2),
                ),
                _buildInfoRow(
                  l10n.myTripsScreenFromPrefix,
                  trip.pickupLocation ?? l10n.myTripsScreenNotAvailable,
                ),
                const SizedBox(height: 4),
                _buildInfoRow(
                  l10n.myTripsScreenToPrefix,
                  trip.dropoffLocation ?? l10n.myTripsScreenNotAvailable,
                ),
                const SizedBox(height: 12),

                // ✅✅✅ FIX APPLIED HERE ✅✅✅
                _buildDetailRow(
                  Icons.schedule_rounded,
                  '${l10n.myTripsScreenPickupPrefix}$pickupTimeFormatted',
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.schedule_rounded,
                  '${l10n.myTripsScreenDropoffPrefix}$dropoffTimeFormatted',
                ),

                // ✅✅✅ END OF FIX ✅✅✅
                if (trip.fareAmount != null)
                  _buildDetailRow(
                    Icons.payments_outlined,
                    '${l10n.myTripsScreenFarePrefix}${trip.fareAmount!.toStringAsFixed(2)}',
                  ),
                if (trip.rating != null)
                  _buildDetailRow(
                    Icons.star_border_rounded,
                    '${l10n.myTripsScreenRatingPrefix}${trip.rating}/5',
                    color: AppColors.goldenrod,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Text.rich(
      TextSpan(
        text: title,
        style: AppTextStyles.cardSubtitle.copyWith(color: AppColors.textSubtle),
        children: [
          TextSpan(
            text: value,
            style: AppTextStyles.cardTitle.copyWith(fontSize: 16),
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDetailRow(IconData icon, String text, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(top: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color ?? AppColors.textSubtle),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTextStyles.cardSubtitle.copyWith(
              color: color ?? AppColors.textSubtle,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(width: 100, height: 16, color: Colors.white),
              Container(width: 80, height: 16, color: Colors.white),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.transparent),
          Container(width: double.infinity, height: 16, color: Colors.white),
          const SizedBox(height: 8),
          Container(width: 200, height: 16, color: Colors.white),
        ],
      ),
    );
  }
}

// STEP 4: COPIED CUSTOM CLIPPER CLASS
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
