// lib/screens/passenger_register_screen.dart

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
import '../widgets/animated_theme_toggle.dart';
import '../widgets/theme_transition_animation.dart';
import 'otp_verification_screen.dart';
import '../services/auth_service.dart';
import 'passenger_login_screen.dart';
import 'home_screen.dart';

enum RegisterMethod { phone, email }

class PassengerRegisterScreen extends StatefulWidget {
  const PassengerRegisterScreen({super.key});

  @override
  State<PassengerRegisterScreen> createState() =>
      _PassengerRegisterScreenState();
}

class _PassengerRegisterScreenState extends State<PassengerRegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  RegisterMethod _selectedMethod = RegisterMethod.phone;

  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Country _selectedCountry = Country.parse('ET');
  bool _isPasswordObscured = true;

  late final AnimationController _gradientController;
  late final AnimationController _burstController;

  @override
  void initState() {
    super.initState();
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
    _gradientController.dispose();
    _burstController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    if (_selectedMethod == RegisterMethod.phone) {
      await _submitPhoneForm();
    } else {
      await _submitEmailForm();
    }
  }

  Future<void> _submitPhoneForm() async {
    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    final fullPhoneNumber =
        '+${_selectedCountry.phoneCode}${_phoneController.text.trim()}';

    final result = await authService.requestOtp(fullPhoneNumber);

    if (mounted) {
      if (result['success']) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OtpVerificationScreen(phone: fullPhoneNumber),
          ),
        );
      } else {
        _showErrorSnackbar(result['message'] ?? 'Failed to send OTP.');
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _submitEmailForm() async {
    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    final fullPhoneNumber =
        '+${_selectedCountry.phoneCode}${_phoneController.text.trim()}';

    final result = await authService.registerWithEmailPassword(
      name: _nameController.text.trim(),
      phone: fullPhoneNumber,
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (mounted) {
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful! Please log in.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        _showErrorSnackbar(result['message'] ?? 'Registration failed.');
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _pickCountry() {
    showCountryPicker(
      context: context,
      favorite: ['ET'],
      onSelect: (Country country) => setState(() => _selectedCountry = country),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ThemeTransitionAnimation(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            FadeIn(
              delay: const Duration(milliseconds: 800),
              duration: const Duration(milliseconds: 500),
              child: Row(
                children: [
                  _buildThemeButton(),
                  const SizedBox(width: 8),
                  _buildLanguageButton(),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            _buildAnimatedGradientBackground(),
            _buildCornerBurstEffect(),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTitles(l10n),
                      const SizedBox(height: 30),
                      _buildGlassmorphicForm(l10n),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedGradientBackground() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isDark = themeProvider.themeMode == ThemeMode.dark;

        return AnimatedBuilder(
          animation: _gradientController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: isDark
                    ? LinearGradient(
                        // Beautiful Dark Mode - Deep golden/amber theme
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF1A1A1A), // Deep black
                          const Color(0xFF2D2D2D), // Dark gray
                          const Color(0xFF1F1F1F), // Charcoal
                          const Color(0xFF0F0F0F), // Almost black
                        ],
                        stops: const [0.0, 0.3, 0.7, 1.0],
                      )
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF1565C0),
                          const Color(0xFF1976D2),
                          const Color(0xFF42A5F5),
                          const Color(0xFF64B5F6),
                        ],
                        stops: const [0.0, 0.3, 0.7, 1.0],
                      ),
              ),
            );
          },
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
            position: const Offset(double.infinity, 0),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  AppColors.goldenrod.withValues(alpha: 0.2),
                  AppColors.primaryColor.withValues(alpha: 0.15),
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

  Widget _buildThemeButton() {
    return const AnimatedThemeToggle();
  }

  Widget _buildLanguageButton() {
    return Consumer2<LocaleProvider, ThemeProvider>(
      builder: (context, localeProvider, themeProvider, _) {
        final isDark = themeProvider.themeMode == ThemeMode.dark;
        return IconButton(
          icon: Icon(
            PhosphorIcons.translate,
            color: isDark ? AppColors.textPrimary : Colors.white,
          ),
          onPressed: () => _showLanguagePicker(context, localeProvider),
        );
      },
    );
  }

  Widget _buildTitles(AppLocalizations l10n) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isDark = themeProvider.themeMode == ThemeMode.dark;

        return Column(
          children: [
            FadeInDown(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 800),
              child: Text(
                l10n.registerCreateAccount,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: isDark ? AppColors.textPrimary : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 8),
            FadeInDown(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 1000),
              child: Text(
                l10n.registerGetStarted,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isDark ? AppColors.textSecondary : Colors.white.withValues(alpha: 0.85),
                    ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGlassmorphicForm(AppLocalizations l10n) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isDark = themeProvider.themeMode == ThemeMode.dark;

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
                  color: isDark
                      ? const Color(0xFF2D2D2D).withValues(alpha: 0.95) // Dark gray container
                      : Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? AppColors.goldenrod.withValues(alpha: 0.4) // Soft golden glow border
                        : Colors.white.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  boxShadow: isDark
                      ? [
                          BoxShadow(
                            color: AppColors.goldenrod.withValues(alpha: 0.15), // Soft golden glow
                            blurRadius: 24,
                            spreadRadius: -2,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 16,
                            spreadRadius: -8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 24,
                            spreadRadius: -2,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 16,
                            spreadRadius: -8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildRegisterMethodSwitcher(l10n),
                      const SizedBox(height: 24),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.fastOutSlowIn,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) =>
                              FadeTransition(opacity: animation, child: child),
                          child: _selectedMethod == RegisterMethod.phone
                              ? _buildPhoneForm(l10n)
                              : _buildEmailForm(l10n),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildSubmitButton(l10n),
                      const SizedBox(height: 24),
                      _buildLoginLink(l10n),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRegisterMethodSwitcher(AppLocalizations l10n) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isDark = themeProvider.themeMode == ThemeMode.dark;

        return Container(
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1F1F1F).withValues(alpha: 0.8) // Dark charcoal
                : Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(100),
            border: isDark
                ? Border.all(color: AppColors.goldenrod.withValues(alpha: 0.3))
                : Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSwitcherButton(l10n, RegisterMethod.phone, l10n.loginMethodPhone, PhosphorIcons.phone, isDark),
              _buildSwitcherButton(l10n, RegisterMethod.email, l10n.loginMethodEmail, PhosphorIcons.envelopeSimple, isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSwitcherButton(
    AppLocalizations l10n,
    RegisterMethod method,
    String label,
    IconData icon,
    bool isDark,
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
          color: isSelected
              ? (isDark ? AppColors.goldenrod : const Color(0xFF004080))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? (isDark ? Colors.black : Colors.white)
                  : (isDark ? AppColors.textSecondary : const Color(0xFF004080)),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? (isDark ? Colors.black : Colors.white)
                    : (isDark ? AppColors.textSecondary : const Color(0xFF004080)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneField(AppLocalizations l10n) {
    return GlowingTextField(
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
              color: AppColors.borderColor.withValues(alpha: 0.5),
              margin: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ],
        ),
      ),
      validator: (v) {
        final value = v?.trim();
        if (value == null || value.isEmpty) {
          return l10n.errorEnterPhoneNumber;
        }
        final ethiopianPhoneRegex = RegExp(r'^(0?9\d{8}|0?7\d{8})$');
        if (!ethiopianPhoneRegex.hasMatch(value)) {
          return l10n.errorInvalidPhoneNumber;
        }
        return null;
      },
    );
  }

  Widget _buildPhoneForm(AppLocalizations l10n) {
    return Column(
      key: const ValueKey('phone_form'),
      children: [_buildPhoneField(l10n)],
    );
  }

  Widget _buildEmailForm(AppLocalizations l10n) {
    return Column(
      key: const ValueKey('email_form'),
      children: [
        GlowingTextField(
          controller: _nameController,
          hintText: l10n.registerFullName,
          icon: PhosphorIcons.user,
          validator: (v) =>
              v == null || v.isEmpty ? l10n.registerErrorEnterFullName : null,
        ),
        const SizedBox(height: 16),
        _buildPhoneField(l10n),
        const SizedBox(height: 16),
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
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.errorEnterPassword;
            }
            final passwordRegex = RegExp(
              r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^\da-zA-Z]).{6,}$',
            );
            if (!passwordRegex.hasMatch(value)) {
              return l10n.registerErrorEnterConfirmPassword;
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton(AppLocalizations l10n) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isDark = themeProvider.themeMode == ThemeMode.dark;

        return SizedBox(
          width: double.infinity,
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: isDark ? AppColors.goldenrod : Colors.white,
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: isDark
                          ? [AppColors.goldenrod, AppColors.goldenrod.withValues(alpha: 0.8)]
                          : [const Color(0xFF004080), const Color(0xFF0066CC)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? AppColors.goldenrod.withValues(alpha: 0.3)
                            : const Color(0xFF004080).withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _handleRegister,
                    child: Text(
                      _selectedMethod == RegisterMethod.phone
                          ? l10n.sendOtpButton
                          : l10n.registerButton,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildLoginLink(AppLocalizations l10n) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isDark = themeProvider.themeMode == ThemeMode.dark;

        return FadeInUp(
          delay: const Duration(milliseconds: 1400),
          duration: const Duration(milliseconds: 600),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.registerHaveAccount,
                style: TextStyle(
                  color: isDark ? AppColors.textSecondary : Colors.black54, // Dark text for light mode
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const PassengerLoginScreen(),
                  ),
                ),
                child: Text(
                  l10n.signInButton,
                  style: TextStyle(
                    color: isDark ? AppColors.goldenrod : const Color(0xFF004080), // Blue for light mode
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
} // ✅ --- THIS IS THE CRUCIAL MISSING BRACE ---

// ✅ --- This class now correctly lives outside the State class ---
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