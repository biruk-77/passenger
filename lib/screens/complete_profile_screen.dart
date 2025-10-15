import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';

import '../services/auth_service.dart';
import '../theme/color.dart';
import '../widgets/glowing_text_field.dart';
import '../l10n/app_localizations.dart';
import 'home_screen.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    final passenger = authService.currentPassenger;
    if (passenger != null) {
      _nameController.text =
          (passenger.name.isEmpty ||
              passenger.name.toLowerCase().contains('passenger') ||
              passenger.name.toLowerCase().contains('unnamed'))
          ? ''
          : passenger.name;

      _emailController.text = passenger.email;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    final authService = Provider.of<AuthService>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    final result = await authService.completeInitialProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(), // Keep email optional if needed
    );

    if (!mounted) return;

    if (result['success']) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (Route<dynamic> route) => false, // This predicate removes all routes
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.profileUpdateSuccess),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      _showErrorSnackbar(result['message'] ?? 'An unknown error occurred');
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // TextButton(
          //   onPressed: _skipForNow,
          //   child: Text(
          //     l10n.skip,
          //     style: const TextStyle(color: Colors.white, fontSize: 16),
          //   ),
          // ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                FadeInDown(
                  child: Text(
                    l10n.completeProfileTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FadeInDown(
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    l10n.completeProfileSubtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 48),
                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  child: GlowingTextField(
                    controller: _nameController,
                    hintText: l10n.fullName,
                    icon: Icons.person_outline,
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? l10n.errorEnterName
                        : null,
                  ),
                ),
                const SizedBox(height: 24),
                // FadeInUp(
                //   delay: const Duration(milliseconds: 400),
                //   child: GlowingTextField(
                //     controller: _emailController,
                //     hintText: l10n.emailAddress,
                //     icon: Icons.email_outlined,
                //     keyboardType: TextInputType.emailAddress,
                //     validator: (value) {
                //       if (value != null &&
                //           value.isNotEmpty &&
                //           !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                //         return l10n.errorInvalidEmail;
                //       }
                //       return null;
                //     },
                //   ),
                // ),
                const SizedBox(height: 48),
                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: AppColors.goldenrod,
                        )
                      : ElevatedButton(
                          onPressed: _submitProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.goldenrod,
                            foregroundColor: Colors.black,
                            minimumSize: const Size(double.infinity, 55),
                            shape: const StadiumBorder(),
                          ),
                          child: Text(
                            l10n.finish,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
