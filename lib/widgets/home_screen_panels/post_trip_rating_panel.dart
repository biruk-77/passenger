/* CRITICAL: DO NOT REMOVE OR ABBREVIATE. 
      This file must be delivered complete. 
      Any changes must preserve the exported public API. */
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../models/nearby_driver.dart';
import 'widgets.dart';
import '../../theme/color.dart';

// Use shared theme colors for consistency with other panels
const String _primaryFont = 'Inter';
const String _headingFont = 'PlayfairDisplay';

class PostTripRatingPanelContent extends StatelessWidget {
  final NearbyDriver? driver;
  final String startAddress;
  final String destinationAddress;
  final double rating;
  final double? finalFare;
  final double? finalDistanceKm;
  final Set<String> selectedTags;
  final void Function(double) onRatingChanged;
  final TextEditingController commentController;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  final VoidCallback onSkip;
  final void Function(String) onTagTapped;

  const PostTripRatingPanelContent({
    super.key,
    required this.driver,
    required this.startAddress,
    required this.destinationAddress,
    required this.rating,
    required this.finalFare,
    required this.finalDistanceKm,
    required this.selectedTags,
    required this.onRatingChanged,
    required this.commentController,
    required this.isSubmitting,
    required this.onSubmit,
    required this.onSkip,
    required this.onTagTapped,

    // ✅ ADDED THESE TO THE CONSTRUCTOR
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final Map<String, String> feedbackTags = {
      'Excellent Service': l10n.postTripTagExcellentService,
      'Clean Car': l10n.postTripTagCleanCar,
      'Safe Driver': l10n.postTripTagSafeDriver,
      'Good Conversation': l10n.postTripTagGoodConversation,
      'Friendly Attitude': l10n.postTripTagFriendlyAttitude,
    };

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            // Align with app theme background treatment
            AppColors.primaryColor,
            AppColors.background,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.0)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              const PanelHandle(),
              const SizedBox(height: 24),
              Text(
                l10n.postTripCompleted,
                style: const TextStyle(
                  fontFamily: _headingFont,
                  color: AppColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.5),
              const SizedBox(height: 16),
              Text(
                l10n.postTripRateExperience,
                style: TextStyle(
                  fontFamily: _primaryFont,
                  color: AppColors.textSecondary.withValues(alpha: 0.9),
                  fontSize: 16,
                ),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.5),
              const SizedBox(height: 24),
              _DriverRatingCard(
                driver: driver,
                rating: rating,
                onRatingChanged: onRatingChanged,
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),
              const SizedBox(height: 24),
              _TripSummaryCard(
                l10n: l10n,
                startAddress: startAddress,
                destinationAddress: destinationAddress,
                finalFare: finalFare,
                finalDistanceKm: finalDistanceKm,
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3),
              const SizedBox(height: 24),

              _FeedbackSection(
                l10n: l10n,
                feedbackTags: feedbackTags,
                selectedTags: selectedTags,
                onTagTapped: onTagTapped,
                commentController: commentController,
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3),
              const SizedBox(height: 32),
              _SubmitButton(
                l10n: l10n,
                isSubmitting: isSubmitting,
                onSubmit: onSubmit,
              ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.3),
              const SizedBox(height: 8),
              TextButton(
                onPressed: onSkip,
                child: Text(
                  l10n.postTripSkip,
                  style: TextStyle(
                    fontFamily: _primaryFont,
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 16,
                  ),
                ),
              ).animate().fadeIn(delay: 800.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _DriverRatingCard extends StatelessWidget {
  final NearbyDriver? driver;
  final double rating;
  final void Function(double) onRatingChanged;

  const _DriverRatingCard({
    required this.driver,
    required this.rating,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    final driverPhotoUrl = driver?.photoUrl;
    final driverName =
        driver?.name ?? AppLocalizations.of(context)!.postTripYourDriver;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.cardBackground.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.borderColor.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.background.withValues(alpha: 0.4),
                backgroundImage: driverPhotoUrl != null
                    ? NetworkImage(driverPhotoUrl)
                    : null,
                child: driverPhotoUrl == null
                    ? const Icon(
                        Icons.person,
                        size: 40,
                        color: AppColors.textSecondary,
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                driverName,
                style: const TextStyle(
                  fontFamily: _primaryFont,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              RatingBar.builder(
                initialRating: rating,
                minRating: 1,
                direction: Axis.horizontal,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 6.0),
                itemBuilder: (context, _) =>
                    const Icon(Icons.star_rounded, color: AppColors.goldenrod),
                onRatingUpdate: onRatingChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TripSummaryCard extends StatelessWidget {
  final AppLocalizations l10n;
  final String startAddress;
  final String destinationAddress;
  final double? finalFare;
  final double? finalDistanceKm;

  const _TripSummaryCard({
    required this.l10n,
    required this.startAddress,
    required this.destinationAddress,
    required this.finalFare,
    required this.finalDistanceKm,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ --- START OF FIX ---
    // The 'intl' package does not support the 'om' locale for number formatting.
    // We provide a fallback to ensure the app doesn't crash.
    final supportedLocalesForNumberFormatting = ['en', 'am'];
    final localeForFormatting =
        supportedLocalesForNumberFormatting.contains(l10n.localeName)
        ? l10n.localeName
        : 'en'; // Fallback to 'en'

    final currencyFormat = NumberFormat.currency(
      locale: localeForFormatting, // Use the safe locale
      symbol: '${l10n.currencySymbol} ',
    );
    // ✅ --- END OF FIX ---

    final formattedFare = finalFare != null
        ? currencyFormat.format(finalFare)
        : '...';
    final formattedDistance = finalDistanceKm != null
        ? '${finalDistanceKm!.toStringAsFixed(1)} km'
        : '...';

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardBackground.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.borderColor.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            children: [
              IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTripSummaryItem(
                      l10n.postTripFinalFare,
                      formattedFare,
                    ),
                    VerticalDivider(color: Colors.white.withValues(alpha: 0.2)),
                    _buildTripSummaryItem(
                      l10n.postTripDistance,
                      formattedDistance,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Divider(
                  color: AppColors.borderColor.withValues(alpha: 0.3),
                ),
              ),
              _buildTripRouteRow(
                Icons.my_location,
                AppColors.electricCyan,
                startAddress,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 4, bottom: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 12,
                    width: 2,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              ),
              _buildTripRouteRow(
                Icons.flag_rounded,
                AppColors.error,
                destinationAddress,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontFamily: _primaryFont,
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontFamily: _primaryFont,
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTripRouteRow(IconData icon, Color color, String address) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            address,
            style: const TextStyle(
              fontFamily: _primaryFont,
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _FeedbackSection extends StatelessWidget {
  final AppLocalizations l10n;
  final Map<String, String> feedbackTags;
  final Set<String> selectedTags;
  final Function(String) onTagTapped;
  final TextEditingController commentController;

  const _FeedbackSection({
    required this.l10n,
    required this.feedbackTags,
    required this.selectedTags,
    required this.onTagTapped,
    required this.commentController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.postTripAddCompliment,
          style: const TextStyle(
            fontFamily: _primaryFont,
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10.0,
          runSpacing: 10.0,
          children: feedbackTags.entries.map((entry) {
            final tagKey = entry.key;
            final tagValue = entry.value;
            final isSelected = selectedTags.contains(tagKey);
            return FilterChip(
              label: Text(tagValue),
              selected: isSelected,
              onSelected: (_) => onTagTapped(tagKey),
              backgroundColor: AppColors.background.withValues(alpha: 0.4),
              selectedColor: AppColors.goldenrod,
              labelStyle: TextStyle(
                fontFamily: _primaryFont,
                color: isSelected
                    ? Colors.black
                    : AppColors.textPrimary.withValues(alpha: 0.85),
                fontWeight: FontWeight.w600,
              ),
              checkmarkColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
                side: BorderSide(
                  color: AppColors.borderColor.withValues(alpha: 0.4),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: commentController,
          maxLines: 3,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontFamily: _primaryFont,
          ),
          decoration: InputDecoration(
            hintText: l10n.postTripAddComment,
            hintStyle: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
            filled: true,
            fillColor: AppColors.cardBackground.withValues(alpha: 0.6),
            contentPadding: const EdgeInsets.all(16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppColors.borderColor.withValues(alpha: 0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.goldenrod),
            ),
          ),
        ),
      ],
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final AppLocalizations l10n;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  const _SubmitButton({
    required this.l10n,
    required this.isSubmitting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isSubmitting ? null : onSubmit,
      child: AnimatedContainer(
        duration: 300.ms,
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.goldenrod,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.goldenrod.withValues(alpha: 0.5),
              blurRadius: 20,
              spreadRadius: -5,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: 200.ms,
            child: Text(
              key: const ValueKey('text'),
              l10n.postTripSubmitFeedback,
              style: const TextStyle(
                fontFamily: _primaryFont,
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
