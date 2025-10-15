// lib/screens/otp_verification_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../services/auth_service.dart';
import '../theme/color.dart';
import '../l10n/app_localizations.dart'; // <-- Ensure this is imported
import 'complete_profile_screen.dart';
import 'home_screen.dart';
import '../utils/logger.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phone;

  const OtpVerificationScreen({super.key, required this.phone});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isLoading = false;
  String? _errorMessage;

  Timer? _resendTimer;
  int _resendCooldown = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    _listenForSms();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    _resendTimer?.cancel();
    SmsAutoFill().unregisterListener();
    super.dispose();
  }

  Future<void> _listenForSms() async {
    await SmsAutoFill().listenForCode();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    _resendCooldown = 30;
    _canResend = false;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendCooldown > 0) {
        setState(() => _resendCooldown--);
      } else {
        timer.cancel();
        setState(() => _canResend = true);
      }
    });
  }

  Future<void> _verifyOtp(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final String otp = _pinController.text.trim();
    if (otp.length != 6) {
      setState(() => _errorMessage = l10n.enterValidOtp);
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // ✅ THIS LINE IS NOW CORRECTED
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      final result = await authService.verifyOtpAndLogin(
        phone: widget.phone,
        otp: otp,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        final bool isProfileComplete = result['profileComplete'] ?? false;

        if (isProfileComplete) {
          Logger.success("OTP", "Profile complete. Navigating to HomeScreen.");
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );
        } else {
          Logger.info(
            "OTP",
            "Profile incomplete. Navigating to CompleteProfileScreen.",
          );
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const CompleteProfileScreen(),
            ),
            (route) => false,
          );
        }
      } else {
        final String errorMsg = result['message'] ?? 'Verification failed.';
        Logger.warning("OTP", "OTP/Login failed: $errorMsg");
        setState(() {
          _isLoading = false;
          _errorMessage = errorMsg;
          _pinController.clear();
          _focusNode.requestFocus();
        });
      }
    } catch (e, stack) {
      Logger.error("OTP", "Uncaught error during OTP verification", e, stack);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'An unexpected error occurred.';
        _pinController.clear();
        _focusNode.requestFocus();
      });
    }
  }

  Future<void> _resendOtp(BuildContext context) async {
    if (!_canResend) return;
    final l10n = AppLocalizations.of(context)!;
    final authService = Provider.of<AuthService>(context, listen: false);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.resendingOtp), // <-- LOCALIZED
          backgroundColor: AppColors.textSecondary,
        ),
      );
    await authService.requestOtp(widget.phone);
    setState(_startResendTimer);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: const TextStyle(
        fontSize: 24,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.goldenrod, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.goldenrod.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.error, width: 2),
      ),
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryColor, AppColors.secondaryColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: BackButton(color: AppColors.textPrimary),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      FadeInDown(
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: AppColors.goldenrod.withOpacity(0.1),
                          child: const Icon(
                            Icons.phonelink_lock_rounded,
                            size: 40,
                            color: AppColors.goldenrod,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      FadeInDown(
                        delay: const Duration(milliseconds: 200),
                        child: Text(
                          l10n.enterCode, // <-- LOCALIZED
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FadeInDown(
                        delay: const Duration(milliseconds: 300),
                        child: Text(
                          l10n.otpScreenSubtitle(widget.phone), // <-- LOCALIZED
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      FadeInUp(
                        delay: const Duration(milliseconds: 400),
                        child: Pinput(
                          length: 6,
                          controller: _pinController,
                          focusNode: _focusNode,
                          autofocus: true,
                          defaultPinTheme: defaultPinTheme,
                          focusedPinTheme: focusedPinTheme,
                          errorPinTheme: errorPinTheme,
                          onCompleted: (pin) => _verifyOtp(context),
                          pinputAutovalidateMode:
                              PinputAutovalidateMode.onSubmit,
                          pinAnimationType: PinAnimationType.fade,
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (_errorMessage != null)
                        FadeIn(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.error,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      FadeInUp(
                        delay: const Duration(milliseconds: 600),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: AppColors.goldenrod,
                              )
                            : SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => _verifyOtp(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.goldenrod,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    l10n.verifyButton, // <-- LOCALIZED
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 24),
                      FadeInUp(
                        delay: const Duration(milliseconds: 700),
                        child: TextButton(
                          onPressed: _canResend
                              ? () => _resendOtp(context)
                              : null,
                          style: TextButton.styleFrom(
                            foregroundColor: _canResend
                                ? AppColors.goldenrod
                                : AppColors.textSubtle,
                          ),
                          child: Text(
                            _canResend
                                ? l10n
                                      .didNotReceiveCodeResend // <-- LOCALIZED
                                : l10n.resendCodeIn(
                                    _resendCooldown,
                                  ), // <-- LOCALIZED
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
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
