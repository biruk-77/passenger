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

  // --- ✅ NEW: Controllers now exactly match the login screen ---
  late final AnimationController _gradientController;
  late final AnimationController _burstController;

  @override
  void initState() {
    super.initState();
    // --- ✅ NEW: Gradient controller from login screen ---
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);

    // Burst animation controller remains the same
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
    // --- ✅ NEW: Dispose gradient controller ---
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

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          FadeIn(
            delay: const Duration(milliseconds: 800),
            duration: const Duration(milliseconds: 500),
            child: Row(children: [_buildThemeButton(), _buildLanguageButton()]),
          ),
        ],
      ),
      body: Stack(
        children: [
          // --- ✅ NEW: Using the exact same background as the login screen ---
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
                    _buildGlassmorphicForm(context, l10n),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- ✅ NEW: Background widget copied directly from login screen ---
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
                  AppColors.primaryColor.withOpacity(
                    0.2,
                  ), // Adjusted for consistency
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

  // The rest of the file remains the same as your correct version
  // ... (buildThemeButton, buildLanguageButton, buildTitles, etc.)

  Widget _buildThemeButton() {
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
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, _) => IconButton(
        icon: const Icon(PhosphorIcons.translate, color: AppColors.textPrimary),
        onPressed: () => _showLanguagePicker(context, localeProvider),
      ),
    );
  }

  Widget _buildTitles(AppLocalizations l10n) {
    return Column(
      children: [
        FadeInDown(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 800),
          child: Text(
            l10n.registerCreateAccount,
            textAlign: TextAlign.center,
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
            l10n.registerGetStarted,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildGlassmorphicForm(BuildContext context, AppLocalizations l10n) {
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
              color: AppColors.cardBackground.withOpacity(0.5),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.borderColor.withOpacity(0.5)),
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
  }

  Widget _buildRegisterMethodSwitcher(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.7),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSwitcherButton(
            l10n,
            RegisterMethod.phone,
            l10n.loginMethodPhone,
            PhosphorIcons.phone,
          ),
          _buildSwitcherButton(
            l10n,
            RegisterMethod.email,
            l10n.loginMethodEmail,
            PhosphorIcons.envelopeSimple,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitcherButton(
    AppLocalizations l10n,
    RegisterMethod method,
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
              color: AppColors.borderColor.withOpacity(0.5),
              margin: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ],
        ),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) {
          return l10n.errorEnterPhoneNumber;
        }
        if (!RegExp(r'^[0-9]{7,15}$').hasMatch(v.trim())) {
          return 'Please enter a valid phone number.';
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
          validator: (v) {
            if (v == null || v.isEmpty) return l10n.errorEnterPassword;
            if (v.length < 6) return l10n.registerErrorPasswordShort;
            return null;
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
              onPressed: _handleRegister,
              child: Text(
                _selectedMethod == RegisterMethod.phone
                    ? l10n.sendOtpButton
                    : l10n.registerButton,
              ),
            ),
    );
  }

  Widget _buildLoginLink(AppLocalizations l10n) {
    return FadeInUp(
      delay: const Duration(milliseconds: 1400),
      duration: const Duration(milliseconds: 600),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.registerHaveAccount,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const PassengerLoginScreen(),
              ),
            ),
            child: Text(
              l10n.signInButton,
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
              color: AppColors.cardBackground.withOpacity(0.8),
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
