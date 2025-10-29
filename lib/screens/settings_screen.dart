// lib/screens/settings_screen.dart
// STEP 1: ADDED IMPORT
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../services/auth_service.dart';
import '../theme/color.dart'; // IMPORTED FOR BACKGROUND COLORS

// --- ✅ Import the new screens we will create ---
import 'settings_subscreens/help_support_screen.dart';
import 'settings_subscreens/privacy_policy_screen.dart';
import 'settings_subscreens/terms_of_service_screen.dart';
// --- End of imports ---

// A helper class to hold language data for a better UI
class Language {
  final String code;
  final String nativeName; // The name in its own language (e.g., "አማርኛ")
  final String englishName; // The name in English (e.g., "Amharic")

  Language({
    required this.code,
    required this.nativeName,
    required this.englishName,
  });
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  // This static list is the single source of truth for supported languages.
  static final List<Language> supportedLanguages = [
    Language(code: 'en', nativeName: 'English', englishName: 'English'),
    Language(code: 'am', nativeName: 'አማርኛ', englishName: 'Amharic'),
    Language(code: 'om', nativeName: 'Afan Oromoo', englishName: 'Oromo'),
    Language(code: 'ti', nativeName: 'ትግርኛ', englishName: 'Tigrinya'),
    Language(code: 'so', nativeName: 'Soomaali', englishName: 'Somali'),
  ];

  // --- STEP 2: ADDED ANIMATION CONTROLLERS ---
  late final AnimationController _gradientController;
  late final AnimationController _burstController;

  @override
  void initState() {
    super.initState();
    // --- STEP 3: INITIALIZED NEW CONTROLLERS ---
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
    // --- STEP 3: DISPOSED NEW CONTROLLERS ---
    _gradientController.dispose();
    _burstController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // --- ALL EXISTING LOGIC IS PRESERVED ---
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentPassenger = authService.currentPassenger;

    final Language currentLanguage = supportedLanguages.firstWhere(
      (lang) => lang.code == (localeProvider.locale?.languageCode ?? 'en'),
      orElse: () => supportedLanguages.first,
    );

    return Scaffold(
      // --- AppBar background made transparent to show the new background ---
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        backgroundColor: Colors.transparent, // MODIFIED FOR VISUAL EFFECT
        elevation: 0,
      ),
      // --- STEP 5: REFACATORED BODY WITH STACK ---
      body: Stack(
        children: [
          _buildAnimatedGradientBackground(),
          _buildCornerBurstEffect(),
          // --- EXISTING LISTVIEW REMAINS THE TOP LAYER (UNCHANGED) ---
          ListView(
            children: [
              // --- Account Section ---
              _buildSectionHeader(context, l10n.settingsSectionAccount),
              Container(
                color: Theme.of(context).colorScheme.surface,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: currentPassenger?.photoUrl != null
                        ? NetworkImage(currentPassenger!.photoUrl!)
                        : null,
                    child: currentPassenger?.photoUrl == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(currentPassenger?.name ?? l10n.drawerGuestUser),
                  subtitle: Text(currentPassenger?.email ?? ''),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // TODO: You already have an EditProfileScreen, you can navigate to it here.
                  },
                ),
              ),

              // --- Preferences Section ---
              _buildSectionHeader(context, l10n.settingsSectionPreferences),
              Container(
                color: Theme.of(context).colorScheme.surface,
                child: Column(
                  children: [
                    _buildSettingsTile(
                      context,
                      title: l10n.settingsLanguage,
                      subtitle: currentLanguage.nativeName,
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _showLanguagePicker(context, localeProvider),
                    ),
                    _buildSettingsTile(
                      context,
                      title: l10n.settingsDarkMode,
                      trailing: Switch(
                        value: themeProvider.themeMode == ThemeMode.dark,
                        onChanged: (value) => themeProvider.toggleTheme(value),
                      ),
                      onTap: () => themeProvider.toggleTheme(
                        themeProvider.themeMode != ThemeMode.dark,
                      ),
                    ),
                  ],
                ),
              ),

              // --- About Section ---
              _buildSectionHeader(context, l10n.settingsSectionAbout),
              Container(
                color: Theme.of(context).colorScheme.surface,
                child: Column(
                  children: [
                    _buildSettingsTile(
                      context,
                      title: l10n.settingsHelpSupport,
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const HelpSupportScreen(),
                        ),
                      ),
                    ),
                    _buildSettingsTile(
                      context,
                      title: l10n.settingsTermsOfService,
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const TermsOfServiceScreen(),
                        ),
                      ),
                    ),
                    _buildSettingsTile(
                      context,
                      title: l10n.settingsPrivacyPolicy,
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PrivacyPolicyScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- ALL HELPER METHODS BELOW ARE UNCHANGED ---
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(
            context,
          ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: subtitle != null
          ? Text(subtitle, style: TextStyle(color: Colors.grey.shade600))
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }

  void _showLanguagePicker(BuildContext context, LocaleProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  AppLocalizations.of(context)!.selectLanguage,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: supportedLanguages.map((language) {
                    return ListTile(
                      title: Text(language.nativeName),
                      subtitle: language.nativeName != language.englishName
                          ? Text(language.englishName)
                          : null,
                      onTap: () {
                        provider.setLocale(Locale(language.code));
                        Navigator.of(context).pop();
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- STEP 4: COPIED HELPER WIDGETS ---
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
}

// --- STEP 4: COPIED CUSTOM CLIPPER CLASS ---
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
