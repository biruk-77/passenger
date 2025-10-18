/* CRITICAL: DO NOT REMOVE OR ABBREVIATE.
This file must be delivered complete.
Any changes must preserve the exported public API. */

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';

import '../../models/contract/contract_ride.dart';
import '../../services/api_service.dart';
import '../../utils/logger.dart';
import '../../theme/color.dart'; // Import your app colors
import 'payment_screen.dart';

class _LocationData {
  final String name;
  final double latitude;
  final double longitude;
  _LocationData(this.name, this.latitude, this.longitude);
}

class CreateSubscriptionScreen extends StatefulWidget {
  final String contractId;
  final String contractType;
  final String startAddress;
  final String destinationAddress;
  final LatLng startPoint;
  final LatLng destinationPoint;

  const CreateSubscriptionScreen({
    super.key,
    required this.contractId,
    required this.contractType,
    required this.startAddress,
    required this.destinationAddress,
    required this.startPoint,
    required this.destinationPoint,
  });

  @override
  State<CreateSubscriptionScreen> createState() =>
      _CreateSubscriptionScreenState();
}

class _CreateSubscriptionScreenState extends State<CreateSubscriptionScreen> {
  late final _LocationData _pickupLocation;
  late final _LocationData _dropoffLocation;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pickupLocation = _LocationData(
      widget.startAddress,
      widget.startPoint.latitude,
      widget.startPoint.longitude,
    );
    _dropoffLocation = _LocationData(
      widget.destinationAddress,
      widget.destinationPoint.latitude,
      widget.destinationPoint.longitude,
    );
  }

  Future<void> _selectDateRange(AppLocalizations l10n) async {
    final now = DateTime.now();
    final dateRange = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 730)),
      helpText: l10n.selectDateRange,
    );

    if (dateRange != null && mounted) {
      setState(() {
        _startDate = dateRange.start;
        _endDate = dateRange.end;
      });
    }
  }

  Future<void> _submitSubscriptionRequest() async {
    final l10n = AppLocalizations.of(context)!;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text(l10n.pleaseSelectDateRange),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final newSubscription = await apiService.createSubscription(
        contractId: widget.contractId,
        pickupLocation: _pickupLocation.name,
        pickupLatitude: _pickupLocation.latitude,
        pickupLongitude: _pickupLocation.longitude,
        dropoffLocation: _dropoffLocation.name,
        dropoffLatitude: _dropoffLocation.latitude,
        dropoffLongitude: _dropoffLocation.longitude,
        startDate: _startDate!,
        endDate: _endDate!,
      );

      Logger.success(
        "CreateSubscription",
        "Subscription created: ${newSubscription.id}",
      );
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => PaymentScreen(
              subscriptionId: newSubscription.id,
              contractType: newSubscription.contractType,
              amount: newSubscription.finalFare,
            ),
          ),
        );
      }
    } catch (e) {
      Logger.error("CreateSubscription", "Failed to create subscription.", e);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final safeLocale =
        DateFormat.localeExists(Localizations.localeOf(context).toLanguageTag())
        ? Localizations.localeOf(context).toLanguageTag()
        : 'en_US';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(l10n.newSubscriptionRequest),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryColor, AppColors.secondaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20.0),
            children: [
              Text(
                l10n.subscribingTo(widget.contractType),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.reviewRequestPrompt,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _RouteCard(
                title: l10n.yourRoute,
                pickup: _pickupLocation.name,
                dropoff: _dropoffLocation.name,
              ),
              const SizedBox(height: 20),
              _TappableInfoCard(
                icon: Icons.date_range,
                title: l10n.subscriptionDuration,
                subtitle: _startDate == null
                    ? l10n.selectDateRange
                    : '${DateFormat.yMMMd(safeLocale).format(_startDate!)} - ${DateFormat.yMMMd(safeLocale).format(_endDate!)}',
                onTap: () => _selectDateRange(l10n),
              ),
              const SizedBox(height: 40),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(color: AppColors.goldenrod),
                )
              else
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.goldenrod,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: _submitSubscriptionRequest,
                  icon: const Icon(Icons.send_rounded),
                  label: Text(l10n.proceedToPayment),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- UI/UX WIDGETS ---

class _RouteCard extends StatelessWidget {
  final String title;
  final String pickup;
  final String dropoff;
  const _RouteCard({
    required this.title,
    required this.pickup,
    required this.dropoff,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Divider(height: 24, color: Colors.white.withValues(alpha: 0.3)),
          _RouteRow(icon: Icons.my_location, location: pickup),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: CustomPaint(
              painter: _DottedLinePainter(),
              child: const SizedBox(height: 20),
            ),
          ),
          _RouteRow(icon: Icons.flag, location: dropoff),
        ],
      ),
    );
  }
}

class _RouteRow extends StatelessWidget {
  final IconData icon;
  final String location;
  const _RouteRow({required this.icon, required this.location});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            location,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }
}

class _TappableInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _TappableInfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: Colors.white, size: 24),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white),
        onTap: onTap,
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    const dashHeight = 5;
    const dashSpace = 3;
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// --- SUCCESS SCREEN ---
class SubscriptionPendingScreen extends StatelessWidget {
  const SubscriptionPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                color: AppColors.success,
                size: 100,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.requestSubmitted,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.approvalNotificationPrompt,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                child: Text(l10n.done),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
