import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart'; // ✅ For consistent icons

// Your project's local imports
import '../l10n/app_localizations.dart';
import '../theme/color.dart';
import '../widgets/glowing_text_field.dart';

class OfflineSmsScreen extends StatefulWidget {
  final String? defaultName;
  final String? defaultPhone;

  const OfflineSmsScreen({super.key, this.defaultName, this.defaultPhone});

  @override
  State<OfflineSmsScreen> createState() => _OfflineSmsScreenState();
}

class _OfflineSmsScreenState extends State<OfflineSmsScreen>
    with TickerProviderStateMixin {
  // --- NATIVE INTEGRATION & PERMISSIONS ---
  static const MethodChannel _smsChannel = MethodChannel(
    'com.dailytransport.pasenger/sms',
  );
  bool _hasSmsPermission = false;
  bool _permissionRequestInProgress = false;

  // --- FORM & UI STATE ---
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pickupController = TextEditingController();
  final _destinationController = TextEditingController();

  bool _isLoadingSms = false;
  bool _isFetchingLocation = false;

  // --- ✅ NEW: Controllers to match login/register screens ---
  late final AnimationController _gradientController;
  late final AnimationController _burstController;

  @override
  void initState() {
    super.initState();
    // --- ✅ NEW: Initialize new controllers ---
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
    if (widget.defaultName != null && widget.defaultName!.isNotEmpty) {
      _nameController.text = widget.defaultName!;
    }
    if (widget.defaultPhone != null && widget.defaultPhone!.isNotEmpty) {
      _phoneController.text = widget.defaultPhone!;
    }
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _burstController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _pickupController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<String?> _getStealthLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        debugPrint("Stealth location failed: No permission.");
        return null;
      }
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint("Stealth location failed: Location services disabled.");
        return null;
      }
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      ).timeout(const Duration(seconds: 7));
      return "${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}";
    } catch (e) {
      debugPrint("Stealth location failed: $e");
      return null;
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled && mounted) {
        _showErrorSnackbar(
          "Location services are disabled. Please enable them.",
        );
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showErrorSnackbar(
            "Location permission is required to use this feature.",
          );
          return;
        }
      }
      if (permission == LocationPermission.deniedForever && mounted) {
        _showErrorSnackbar("Location permissions are permanently denied.");
        return;
      }
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final coords =
          "${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}";
      _pickupController.text = coords;
      _showSuccessSnackbar(
        title: "Location Found!",
        message: "Pickup location set to your current GPS coordinates.",
      );
    } catch (e) {
      debugPrint("Error getting location: $e");
      if (mounted)
        _showErrorSnackbar(
          "Could not get your location. Please ensure you have a clear view of the sky.",
        );
    } finally {
      if (mounted) setState(() => _isFetchingLocation = false);
    }
  }

  Future<bool> _requestSmsPermissions() async {
    if (_permissionRequestInProgress) return _hasSmsPermission;
    _permissionRequestInProgress = true;
    try {
      final status = await Permission.sms.request();
      if (!mounted) return false;
      setState(() => _hasSmsPermission = status.isGranted);
      if (!status.isGranted) {
        _showErrorSnackbar(
          'SMS permission is required to send an offline request.',
        );
      }
      return status.isGranted;
    } finally {
      _permissionRequestInProgress = false;
    }
  }

  Future<void> _sendSmsRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_hasSmsPermission) {
      final granted = await _requestSmsPermissions();
      if (!granted) return;
    }
    setState(() => _isLoadingSms = true);
    try {
      final String? stealthCoords = await _getStealthLocation();
      const String bossSmsNumber = "+251928211778";
      final String name = _nameController.text.trim();
      final String phone = _phoneController.text.trim();
      final String pickup = _pickupController.text.trim();
      final String destination = _destinationController.text.trim();
      final String timestamp = DateFormat(
        'MMM d, hh:mm a',
      ).format(DateTime.now());
      String gpsLine = "";
      if (stealthCoords != null) {
        gpsLine = "\n📍 User's GPS Location: $stealthCoords";
      }
      final String messageBody =
          "--- OFFLINE RIDE REQUEST ---\n\n"
          "ACTION: Please CALL back to the customer to confirm booking.\n\n"
          "--- PASSENGER ---\n"
          "👤 Name: $name\n"
          "📞 Phone: $phone\n\n"
          "--- TRIP ---\n"
          "🕒 Time: $timestamp\n"
          "🟢 Pickup: $pickup"
          "$gpsLine\n"
          "🔴 Destination: $destination\n\n"
          "--------------------------------\n"
          "(Sent from Passenger App)";
      await _smsChannel.invokeMethod<void>('sendSms', {
        'phone': bossSmsNumber,
        'message': messageBody,
      });
      if (mounted) {
        _showSuccessSnackbar(
          title: "Request Sent!",
          message: "Your offline booking request has been sent via SMS.",
        );
        await Future.delayed(const Duration(seconds: 3));
        if (mounted) Navigator.of(context).pop();
      }
    } on PlatformException catch (e) {
      if (mounted)
        _showErrorSnackbar(
          'Failed to send SMS (Code: ${e.code}). Please check permissions.',
        );
    } catch (e) {
      if (mounted)
        _showErrorSnackbar(
          'An unexpected error occurred while sending the SMS.',
        );
    } finally {
      if (mounted) setState(() => _isLoadingSms = false);
    }
  }

  void _showSuccessSnackbar({required String title, required String message}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(message),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: AppColors.textPrimary),
        title: Text(
          l10n.offlineOrderTitle,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
      ),
      body: Stack(
        children: [
          // --- ✅ NEW: Consistent background and animations ---
          _buildAnimatedGradientBackground(),
          _buildCornerBurstEffect(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _buildGlassmorphicForm(context, l10n),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassmorphicForm(BuildContext context, AppLocalizations l10n) {
    // --- ✅ NEW: Increased delay for synchronized animation ---
    return FadeInUp(
      delay: const Duration(milliseconds: 1200),
      duration: const Duration(milliseconds: 600),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cardBackground.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.borderColor.withValues(alpha: 0.5),
              ),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FadeInDown(
                    child: Text(
                      l10n.offlineRequestTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(color: AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeInDown(
                    delay: const Duration(milliseconds: 100),
                    child: Text(
                      l10n.offlineRequestSubtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const Divider(height: 40, color: Colors.white24),
                  _buildInstructionStep(
                    icon: PhosphorIcons.mapPin,
                    title: l10n.step1Title,
                    subtitle: l10n.step1Subtitle,
                    delay: 200,
                  ),
                  _buildInstructionStep(
                    icon: PhosphorIcons.chatText,
                    title: l10n.step2Title,
                    subtitle: l10n.step2Subtitle,
                    delay: 300,
                  ),
                  _buildInstructionStep(
                    icon: PhosphorIcons.phoneCall,
                    title: l10n.step3Title,
                    subtitle: l10n.step3Subtitle,
                    delay: 400,
                  ),
                  const Divider(height: 40, color: Colors.white24),
                  GlowingTextField(
                    controller: _nameController,
                    hintText: l10n.fullName,
                    icon: PhosphorIcons.user,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? l10n.errorEnterName
                        : null,
                  ),
                  const SizedBox(height: 16),
                  GlowingTextField(
                    controller: _phoneController,
                    hintText: l10n.phoneNumber,
                    icon: PhosphorIcons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return l10n.errorEnterPhoneNumber;
                      }
                      final RegExp phoneRegExp = RegExp(
                        r'^(?:\+251|0)?(9\d{8}|7\d{8})$',
                      );
                      if (!phoneRegExp.hasMatch(v.trim())) {
                        return l10n.errorInvalidPhoneNumber;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  GlowingTextField(
                    controller: _pickupController,
                    hintText: l10n.pickupLocationHint,
                    icon: PhosphorIcons.mapPinLine,
                    suffixIcon: _isFetchingLocation
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.goldenrod,
                              ),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(
                              PhosphorIcons.crosshair,
                              color: AppColors.goldenrod,
                            ),
                            onPressed: _getCurrentLocation,
                          ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? l10n.pickupValidationError
                        : null,
                  ),
                  const SizedBox(height: 16),
                  GlowingTextField(
                    controller: _destinationController,
                    hintText: l10n.destinationLocationHint,
                    icon: PhosphorIcons.flag,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? l10n.destinationValidationError
                        : null,
                  ),
                  const SizedBox(height: 32),
                  _isLoadingSms
                      ? const CircularProgressIndicator(
                          color: AppColors.goldenrod,
                        )
                      : ElevatedButton.icon(
                          onPressed: _sendSmsRequest,
                          icon: const Icon(PhosphorIcons.paperPlaneTilt),
                          label: const Text("Send SMS Request"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.goldenrod,
                            foregroundColor: Colors.black,
                            minimumSize: const Size(double.infinity, 55),
                            shape: const StadiumBorder(),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
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

  Widget _buildInstructionStep({
    required IconData icon,
    required String title,
    required String subtitle,
    required int delay,
  }) {
    return FadeInLeft(
      delay: Duration(milliseconds: delay),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.goldenrod, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- ✅ NEW: Copied from login screen ---
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

  // --- ✅ NEW: Copied from login screen ---
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
                  AppColors.goldenrod.withValues(alpha: 0.3),
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

// --- ✅ NEW: Custom Clipper copied from login screen ---
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
