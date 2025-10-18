// lib/screens/passenger_login_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:country_picker/country_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/color.dart';
import '../theme/styles.dart';
import '../widgets/glowing_text_field.dart';
import 'otp_verification_screen.dart';
import '../services/auth_service.dart';
import 'passenger_register_screen.dart';
import 'home_screen.dart';
import '../utils/logger.dart';

import 'offline_sms_screen.dart';

enum LoginMethod { phone, email }

class PassengerLoginScreen extends StatefulWidget {
  const PassengerLoginScreen({super.key});

  @override
  State<PassengerLoginScreen> createState() => _PassengerLoginScreenState();
}

class _PassengerLoginScreenState extends State<PassengerLoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  LoginMethod _selectedMethod = LoginMethod.phone;

  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Country _selectedCountry = Country.parse('ET');
  bool _isPasswordObscured = true;

  late final AnimationController _gradientController;
  // --- ✅ NEW: Controller for the corner burst effect ---
  late final AnimationController _burstController;

  @override
  void initState() {
    super.initState();
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);

    // --- ✅ NEW: Initialize and start the burst animation ---
    _burstController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    // Start the animation after a short delay to let the screen build
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _burstController.forward();
      }
    });
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _burstController.dispose(); // --- ✅ NEW: Dispose the new controller ---
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// ✅ --- THIS IS THE FINAL, CORRECTED, AND SMART LOGIN FUNCTION ---
  /// ✅ --- MANUAL NAVIGATION AFTER SUCCESSFUL LOGIN ---
  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);

    Map<String, dynamic> result;

    if (_selectedMethod == LoginMethod.phone) {
      final fullPhoneNumber =
          '+${_selectedCountry.phoneCode}${_phoneController.text.trim()}';

      // --- STEP 1: Attempt a silent login with a stored refresh token ---
      Logger.info("Auth", "Attempting silent login first...");
      result = await authService.loginWithRefreshToken();

      if (mounted && result['success'] == true) {
        // ✅ Silent login SUCCEEDED - Navigate manually
        Logger.success(
          "Auth",
          "Silent login successful! Navigating to HomeScreen...",
        );

        // Manual navigation to HomeScreen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      } else {
        // ❌ Silent login FAILED. Proceed with the normal OTP flow.
        Logger.warning("Auth", "Silent login failed. Starting OTP flow...");
        result = await authService.requestOtp(fullPhoneNumber);

        if (mounted && result['success'] == true) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  OtpVerificationScreen(phone: fullPhoneNumber),
            ),
          );
        } else {
          if (mounted) {
            _showErrorSnackbar(result['message'] ?? 'Failed to request OTP.');
          }
        }
      }
    } else {
      // --- Email & Password Login Flow (with manual navigation) ---
      result = await authService.loginWithEmailPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        if (result['success'] == true) {
          // ✅ Email login SUCCESSFUL - Navigate manually to HomeScreen
          Logger.success(
            "Auth",
            "Email login successful! Navigating to HomeScreen...",
          );

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );
        } else {
          _showErrorSnackbar(result['message'] ?? 'Invalid email or password.');
        }
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _pickCountry() {
    // ... (Your existing _pickCountry function is fine) ...
    showCountryPicker(
      context: context,
      favorite: ['ET'],
      countryListTheme: CountryListThemeData(
        backgroundColor: AppColors.cardBackground,
        bottomSheetHeight: MediaQuery.of(context).size.height * 0.7,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        inputDecoration: InputDecoration(
          prefixIcon: const Icon(
            PhosphorIcons.magnifyingGlass,
            color: AppColors.textSecondary,
          ),
          hintText: 'Search Country',
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderColor),
          ),
        ),
      ),
      onSelect: (Country country) => setState(() => _selectedCountry = country),
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
        actions: [
          // Animate the buttons to fade in
          FadeIn(
            delay: const Duration(milliseconds: 800),
            duration: const Duration(milliseconds: 500),
            child: Row(children: [_buildThemeButton(), _buildLanguageButton()]),
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildAnimatedGradientBackground(),
          // --- ✅ NEW: The corner burst effect widget ---
          _buildCornerBurstEffect(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTitles(l10n),
                    const SizedBox(height: 40),
                    _buildGlassmorphicForm(l10n),
                    const SizedBox(height: 24),
                    _buildOfflineSmsButton(l10n),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- ✅ NEW WIDGET for the corner burst animation ---
  Widget _buildCornerBurstEffect() {
    return AnimatedBuilder(
      animation: _burstController,
      builder: (context, child) {
        // Use a curved animation for a nice ease-out effect
        final animation = CurvedAnimation(
          parent: _burstController,
          curve: Curves.easeOutCubic,
        );
        return ClipPath(
          clipper: _CircleClipper(
            // Animate the radius of the circle
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

  Widget _buildAnimatedGradientBackground() {
    // ... (This widget is fine as is) ...
    return AnimatedBuilder(
      animation: _gradientController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(
                -2.0 + (_gradientController.value * 4),
                1.0 - (_gradientController.value * 5),
              ),
              radius: 1.5,
              colors: [
                AppColors.primaryColor.withValues(alpha: 0.7),
                const Color.fromARGB(255, 6, 9, 16),
              ],
              stops: const [0.0, 1.0],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeButton() {
    // ... (This widget is fine as is) ...
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) => IconButton(
        icon: Icon(
          themeProvider.themeMode == ThemeMode.dark
              ? PhosphorIcons.sun
              : PhosphorIcons.moon,
          color: AppColors.textPrimary,
        ),
        onPressed: () => themeProvider.toggleTheme(
          themeProvider.themeMode != ThemeMode.dark,
        ),
      ),
    );
  }

  Widget _buildLanguageButton() {
    // ... (This widget is fine as is) ...
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, _) => IconButton(
        icon: const Icon(PhosphorIcons.translate, color: AppColors.textPrimary),
        onPressed: () => _showLanguagePicker(context, localeProvider),
      ),
    );
  }

  Widget _buildTitles(AppLocalizations l10n) {
    // Added slightly longer delays to sync with the new burst effect
    return Column(
      children: [
        FadeInDown(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 800),
          child: Text(
            l10n.loginWelcomeBack,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        FadeInDown(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 1000),
          child: Text(
            l10n.signInButton, // Add this to your l10n files: 'Sign in to continue your journey'
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildGlassmorphicForm(AppLocalizations l10n) {
    // Added slightly longer delay
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      delay: const Duration(milliseconds: 1200),
      child: ClipRRect(
        // ... (rest of the form widget is fine) ...
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
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
                  _buildLoginMethodSwitcher(l10n),
                  const SizedBox(height: 24),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.fastOutSlowIn,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                      child: _selectedMethod == LoginMethod.phone
                          ? _buildPhoneForm(l10n)
                          : _buildEmailForm(l10n),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSubmitButton(l10n),
                  const SizedBox(height: 24),
                  _buildRegisterLink(l10n),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- No changes needed for the widgets below this line ---

  Widget _buildLoginMethodSwitcher(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSwitcherButton(
            l10n,
            LoginMethod.phone,
            l10n.loginMethodPhone,
            PhosphorIcons.phone,
          ),
          _buildSwitcherButton(
            l10n,
            LoginMethod.email,
            l10n.loginMethodEmail,
            PhosphorIcons.envelopeSimple,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitcherButton(
    AppLocalizations l10n,
    LoginMethod method,
    String label,
    IconData icon,
  ) {
    final isSelected = _selectedMethod == method;
    return GestureDetector(
      onTap: () {
        if (_selectedMethod != method) {
          setState(() => _selectedMethod = method);
          _formKey.currentState?.reset();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.goldenrod : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.black : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.black : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneForm(AppLocalizations l10n) {
    return Column(
      key: const ValueKey('phone_form'),
      children: [
        GlowingTextField(
          controller: _phoneController,
          hintText: l10n.phoneNumber,
          keyboardType: TextInputType.phone,
          prefixWidget: GestureDetector(
            onTap: _pickCountry,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 8),
                  child: Text(
                    _selectedCountry.flagEmoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                Text(
                  '+${_selectedCountry.phoneCode}',
                  style: AppTextStyles.cardSubtitle,
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: AppColors.borderColor,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ],
            ),
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty)
              return l10n.errorEnterPhoneNumber;
            if (!RegExp(r'^[0-9]{7,15}$').hasMatch(v.trim()))
              return 'Please enter a valid phone number.';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildEmailForm(AppLocalizations l10n) {
    return Column(
      key: const ValueKey('email_form'),
      children: [
        GlowingTextField(
          controller: _emailController,
          hintText: l10n.email,
          icon: PhosphorIcons.envelopeSimple,
          keyboardType: TextInputType.emailAddress,
          validator: (v) {
            if (v == null || v.isEmpty) return l10n.errorEnterEmail;
            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v))
              return l10n.errorInvalidEmail;
            return null;
          },
        ),
        const SizedBox(height: 16),
        GlowingTextField(
          controller: _passwordController,
          hintText: l10n.password,
          icon: PhosphorIcons.lock,
          isObscured: _isPasswordObscured,
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordObscured ? PhosphorIcons.eyeSlash : PhosphorIcons.eye,
              color: AppColors.textSecondary,
            ),
            onPressed: () =>
                setState(() => _isPasswordObscured = !_isPasswordObscured),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return l10n.errorEnterPassword;
            if (v.length < 6) return l10n.registerErrorPasswordShort;

            final passwordRegex = RegExp(
              r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&.#^()_\-]).{6,}$',
            );

            if (!passwordRegex.hasMatch(v)) {
              return l10n.errorEnterregex; // Add this to your l10n
            }

            if (!passwordRegex.hasMatch(v)) {
              return l10n
                  .errorEnterPassword; // Make sure to add this in your l10n file
            }

            return null; // Valid password
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.goldenrod),
            )
          : ElevatedButton(
              onPressed: _handleLogin,
              child: Text(
                _selectedMethod == LoginMethod.phone
                    ? l10n.sendOtpButton
                    : l10n.signInButton,
              ),
            ),
    );
  }

  Widget _buildRegisterLink(AppLocalizations l10n) {
    return FadeInUp(
      delay: const Duration(milliseconds: 1400),
      duration: const Duration(milliseconds: 600),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.dontHaveAccount,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const PassengerRegisterScreen(),
              ),
            ),
            child: Text(
              l10n.register,
              style: const TextStyle(
                color: AppColors.goldenrod,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineSmsButton(AppLocalizations l10n) {
    return FadeInUp(
      delay: const Duration(milliseconds: 1500),
      duration: const Duration(milliseconds: 600),
      child: TextButton.icon(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const OfflineSmsScreen()),
          );
        },
        icon: const Icon(
          PhosphorIcons.paperPlaneTilt,
          color: AppColors.textSecondary,
          size: 20,
        ),
        label: Text(
          l10n.smsOfflineLogin,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, LocaleProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: AppColors.cardBackground.withValues(alpha: 0.8),
              child: SafeArea(
                child: Wrap(
                  children: AppLocalizations.supportedLocales.map((locale) {
                    final isSelected = provider.locale == locale;
                    return ListTile(
                      leading: Icon(
                        isSelected
                            ? PhosphorIcons.checkCircleFill
                            : PhosphorIcons.circle,
                        color: isSelected
                            ? AppColors.goldenrod
                            : AppColors.textSecondary,
                      ),
                      title: Text(
                        _getLanguageName(locale.languageCode),
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      onTap: () {
                        provider.setLocale(locale);
                        Navigator.of(context).pop();
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'am':
        return 'አማርኛ';
      case 'om':
        return 'Afan Oromoo';
      case 'ti':
        return 'ትግርኛ';
      case 'so':
        return 'Soomaali';
      default:
        return code;
    }
  }
}

// --- ✅ NEW: Custom Clipper for the burst effect ---
class _CircleClipper extends CustomClipper<Path> {
  final double radius;
  final Offset position;

  _CircleClipper({required this.radius, required this.position});

  @override
  Path getClip(Size size) {
    final path = Path();
    // Use the actual position, resolving infinity to the screen width
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
