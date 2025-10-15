// lib/screens/edit_profile_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';

import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../theme/color.dart';
import '../models/passenger.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/glowing_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  final Passenger initialProfileData;
  const EditProfileScreen({super.key, required this.initialProfileData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AuthService _authService;
  bool _isLoading = false;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  List<Map<String, TextEditingController>> _emergencyContacts = [];

  // Use a nullable key because the widget might not be built
  final _passwordSectionKey = GlobalKey<_PasswordEditSectionState>();
  late final AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _authService = Provider.of<AuthService>(context, listen: false);

    _nameController = TextEditingController(
      text: widget.initialProfileData.name,
    );
    _emailController = TextEditingController(
      text: widget.initialProfileData.email,
    );
    _phoneController = TextEditingController(
      text: widget.initialProfileData.phone,
    );

    if (widget.initialProfileData.emergencyContacts != null) {
      _emergencyContacts = widget.initialProfileData.emergencyContacts!
          .map(
            (c) => {
              'name': TextEditingController(text: c.name),
              'phone': TextEditingController(text: c.phone),
            },
          )
          .toList();
    }

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    for (var controllerMap in _emergencyContacts) {
      controllerMap['name']!.dispose();
      controllerMap['phone']!.dispose();
    }
    super.dispose();
  }

  Future<void> _updateProfile() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final l10n = AppLocalizations.of(context)!;

    final List<String> errorMessages = [];
    final List<String> successMessages = [];
    bool overallSuccess = true;

    // --- Part 1: Always Update Profile Details ---
    final contactsPayload = _emergencyContacts
        .map((controllers) {
          final name = controllers['name']!.text.trim();
          final phone = controllers['phone']!.text.trim();
          return (name.isNotEmpty && phone.isNotEmpty)
              ? {'name': name, 'phone': phone}
              : null;
        })
        .whereType<Map<String, String>>()
        .toList();

    // --- ✅ FIX: REMOVED the check for changes. We now ALWAYS send the data. ---
    final profileResult = await _authService.updatePassengerProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      emergencyContacts: contactsPayload.isNotEmpty ? contactsPayload : null,
    );

    if (profileResult['success']) {
      successMessages.add(l10n.profileUpdateSuccess);
    } else {
      overallSuccess = false;
      errorMessages.add(profileResult['message'] ?? 'Profile update failed.');
    }

    // --- Part 2: Update Password (ONLY FOR NON-OTP USERS) ---
    // --- ✅ FIX: This entire block only runs if the user is NOT an OTP user. ---
    if (!widget.initialProfileData.otpRegistered) {
      final passwordData = _passwordSectionKey.currentState?.getPasswordData();
      final currentPassword = passwordData?['current'];
      final newPassword = passwordData?['new'];

      if (newPassword != null && newPassword.isNotEmpty) {
        if (currentPassword != null && currentPassword.isNotEmpty) {
          final passwordResult = await _authService.changePassword(
            currentPassword: currentPassword,
            newPassword: newPassword,
          );

          if (passwordResult['success']) {
            successMessages.add(
              passwordResult['message'] ?? 'Password updated!',
            );
          } else {
            overallSuccess = false;
            errorMessages.add(
              passwordResult['message'] ?? 'Password update failed.',
            );
          }
        } else {
          overallSuccess = false;
          errorMessages.add(l10n.errorEnterCurrentPassword);
        }
      }
    }

    if (!mounted) return;

    // --- Part 3: Show Feedback ---
    String finalMessage;
    Color snackbarColor;

    if (errorMessages.isNotEmpty) {
      finalMessage = errorMessages.join(' \n');
      snackbarColor = AppColors.error;
    } else if (successMessages.isNotEmpty) {
      finalMessage = successMessages.join(' \n');
      snackbarColor = AppColors.success;
    } else {
      // This case should be rare now, but it's good to have a fallback.
      finalMessage = l10n.saveChanges;
      snackbarColor = AppColors.textSecondary;
      overallSuccess = true; // No changes is a "success"
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(finalMessage.trim()),
        backgroundColor: snackbarColor,
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (overallSuccess &&
        (successMessages.isNotEmpty || errorMessages.isEmpty)) {
      Navigator.of(context).pop(true); // Pop screen on success
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(context, themeProvider),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 20.0,
                      ),
                      child: _buildGlassmorphicForm(context, l10n),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) => Transform.translate(
              offset: Offset(
                -50 + (100 * _glowController.value),
                -100 + (150 * _glowController.value),
              ),
              child: child!,
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.5, -0.7),
                  radius: 1.2,
                  colors: [
                    AppColors.accentColor.withOpacity(0.4),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.8],
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) => Transform.translate(
              offset: Offset(
                50 - (100 * _glowController.value),
                100 - (150 * _glowController.value),
              ),
              child: child!,
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.5, 0.7),
                  radius: 1.2,
                  colors: [
                    AppColors.hotPink.withOpacity(0.5),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.8],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, ThemeProvider themeProvider) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  themeProvider.themeMode == ThemeMode.dark
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                  color: AppColors.textPrimary,
                ),
                onPressed: () => themeProvider.toggleTheme(
                  themeProvider.themeMode != ThemeMode.dark,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.language, color: AppColors.textPrimary),
                onPressed: () => _showLanguagePicker(context, localeProvider),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlassmorphicForm(BuildContext context, AppLocalizations l10n) {
    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
              ),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTitles(l10n),
                  const SizedBox(height: 30),
                  _buildSectionHeader(
                    l10n.personalInformation,
                    Icons.person_outline,
                  ),
                  GlowingTextField(
                    controller: _nameController,
                    hintText: l10n.fullName,
                    icon: Icons.person_outline_rounded,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? l10n.errorEnterName
                        : null,
                  ),
                  const SizedBox(height: 16),
                  GlowingTextField(
                    controller: _phoneController,
                    hintText: l10n.phoneNumber,
                    icon: Icons.phone_outlined,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? l10n.errorEnterPhoneNumber
                        : null,
                  ),
                  const SizedBox(height: 16),
                  GlowingTextField(
                    controller: _emailController,
                    hintText: l10n.emailAddress,
                    icon: Icons.alternate_email_rounded,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v != null &&
                          v.isNotEmpty &&
                          !RegExp(
                            r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
                          ).hasMatch(v)) {
                        return l10n.errorInvalidEmail;
                      }
                      return null;
                    },
                  ),

                  // --- ✅ FIX: Conditionally show the password section. ---
                  // This entire block will be hidden if the user registered with OTP.
                  if (widget.initialProfileData.otpRegistered == false) ...[
                    const Divider(height: 48, color: Colors.white24),
                    _buildSectionHeader(l10n.security, Icons.shield_outlined),
                    _PasswordEditSection(key: _passwordSectionKey, l10n: l10n),
                  ],
                  const Divider(height: 48, color: Colors.white24),
                  _buildSectionHeader(
                    l10n.emergencyContacts,
                    Icons.contact_emergency_outlined,
                  ),
                  ..._emergencyContacts.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildEmergencyContactFields(entry.key, l10n),
                    );
                  }),
                  Align(
                    alignment: Alignment.center,
                    child: TextButton.icon(
                      onPressed: _addEmergencyContactField,
                      icon: const Icon(Icons.add_circle_outline, size: 20),
                      label: Text(l10n.addContact),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildSubmitButton(l10n),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitles(AppLocalizations l10n) {
    return Column(
      children: [
        FadeInDown(
          child: Text(
            l10n.editProfileTitle,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(height: 8),
        FadeInDown(
          delay: const Duration(milliseconds: 100),
          child: Text(
            l10n.editProfileSubtitle,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 22),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactFields(int index, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.contactNumber(index + 1),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.brightRed,
                ),
                onPressed: () => _removeEmergencyContactField(index),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GlowingTextField(
            controller: _emergencyContacts[index]['name']!,
            hintText: l10n.contactFullName,
            icon: Icons.person_pin_circle_outlined,
          ),
          const SizedBox(height: 12),
          GlowingTextField(
            controller: _emergencyContacts[index]['phone']!,
            hintText: l10n.contactPhoneNumber,
            icon: Icons.phone_forwarded_outlined,
            keyboardType: TextInputType.phone,
            validator: (v) {
              if (v != null && v.isNotEmpty && v.length < 9) {
                return l10n.errorInvalidPhoneNumber;
              }
              return null;
            },
            isReadOnly: false,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(AppLocalizations l10n) {
    return _isLoading
        ? const CircularProgressIndicator(color: AppColors.goldenrod)
        : ElevatedButton.icon(
            icon: const Icon(Icons.save_as_rounded),
            onPressed: _updateProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.goldenrod,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 55),
              shape: const StadiumBorder(),
            ),
            label: Text(
              l10n.saveChanges,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          );
  }

  void _addEmergencyContactField() {
    setState(
      () => _emergencyContacts.add({
        'name': TextEditingController(),
        'phone': TextEditingController(),
      }),
    );
  }

  void _removeEmergencyContactField(int index) {
    setState(() {
      _emergencyContacts[index]['name']!.dispose();
      _emergencyContacts[index]['phone']!.dispose();
      _emergencyContacts.removeAt(index);
    });
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
              color: Theme.of(context).colorScheme.surface.withOpacity(0.1),
              child: SafeArea(
                child: Wrap(
                  children: AppLocalizations.supportedLocales.map((locale) {
                    return ListTile(
                      title: Text(
                        _getLanguageName(locale.languageCode),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
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

class _PasswordEditSection extends StatefulWidget {
  final AppLocalizations l10n;

  const _PasswordEditSection({super.key, required this.l10n});

  @override
  State<_PasswordEditSection> createState() => _PasswordEditSectionState();
}

class _PasswordEditSectionState extends State<_PasswordEditSection> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isCurrentPasswordObscured = true;
  bool _isNewPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Map<String, String?> getPasswordData() {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    return {
      'current': currentPassword.isNotEmpty ? currentPassword : null,
      'new': newPassword.isNotEmpty ? newPassword : null,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GlowingTextField(
          controller: _currentPasswordController,
          hintText: widget.l10n.currentPassword,
          icon: Icons.lock_clock_rounded,
          isObscured: _isCurrentPasswordObscured,
          suffixIcon: IconButton(
            icon: Icon(
              _isCurrentPasswordObscured
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.textSecondary,
            ),
            onPressed: () => setState(
              () => _isCurrentPasswordObscured = !_isCurrentPasswordObscured,
            ),
          ),
          validator: (v) {
            if (_newPasswordController.text.isNotEmpty &&
                (v == null || v.isEmpty)) {
              return widget.l10n.errorEnterCurrentPassword;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        GlowingTextField(
          controller: _newPasswordController,
          hintText: widget.l10n.newPassword,
          icon: Icons.lock_outline_rounded,
          isObscured: _isNewPasswordObscured,
          suffixIcon: IconButton(
            icon: Icon(
              _isNewPasswordObscured
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.textSecondary,
            ),
            onPressed: () => setState(
              () => _isNewPasswordObscured = !_isNewPasswordObscured,
            ),
          ),
          validator: (v) {
            if (v != null && v.isNotEmpty && v.length < 6)
              return widget.l10n.errorPasswordTooShort;
            return null;
          },
        ),
        const SizedBox(height: 16),
        GlowingTextField(
          controller: _confirmPasswordController,
          hintText: widget.l10n.confirmNewPassword,
          icon: Icons.lock_person_rounded,
          isObscured: _isConfirmPasswordObscured,
          suffixIcon: IconButton(
            icon: Icon(
              _isConfirmPasswordObscured
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.textSecondary,
            ),
            onPressed: () => setState(
              () => _isConfirmPasswordObscured = !_isConfirmPasswordObscured,
            ),
          ),
          validator: (v) {
            if (_newPasswordController.text.isNotEmpty &&
                v != _newPasswordController.text) {
              return widget.l10n.errorPasswordsDoNotMatch;
            }
            return null;
          },
        ),
      ],
    );
  }
}
