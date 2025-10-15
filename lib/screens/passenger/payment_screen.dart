// lib/screens/passenger/payment_screen.dart
import 'dart:io';
import 'dart:ui'; // ✅ IMPORT ADDED
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../theme/color.dart';
import '../my_transactions_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../models/payments/payment_option.dart';
import '../../services/api_service.dart';
import '../../utils/api_exception.dart';
import '../../utils/logger.dart';

class PaymentScreenData {
  final List<PaymentOption> allOptions;
  final PaymentOption? preferredOption;
  PaymentScreenData({required this.allOptions, this.preferredOption});
}

class PaymentScreen extends StatefulWidget {
  final String subscriptionId;
  final String contractType;
  final num amount;

  const PaymentScreen({
    super.key,
    required this.subscriptionId,
    required this.contractType,
    required this.amount,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with TickerProviderStateMixin {
  // ✅ ADDED TickerProviderStateMixin
  // ✅ ADDED: Animation controllers for the new background
  late final AnimationController _gradientController;
  late final AnimationController _burstController;

  late Future<PaymentScreenData> _dataFuture;
  PaymentOption? _selectedMethod;
  bool _isGatewaySubmitting = false;
  bool _showAllOptions = false;

  @override
  void initState() {
    super.initState();
    // ✅ INITIALIZED: New background controllers
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

    _dataFuture = _fetchInitialData();
  }

  @override
  void dispose() {
    // ✅ DISPOSED: New background controllers
    _gradientController.dispose();
    _burstController.dispose();
    super.dispose();
  }

  // --- EXISTING LOGIC (UNCHANGED) ---
  Future<PaymentScreenData> _fetchInitialData() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      final results = await Future.wait([
        apiService.getPassengerPaymentOptions(),
        apiService.getPaymentPreference(),
      ]);
      final allOptions = results[0] as List<PaymentOption>;
      final preferredOption = results[1] as PaymentOption?;

      if (mounted) {
        setState(() {
          if (preferredOption != null) {
            _selectedMethod = allOptions.firstWhere(
              (opt) => opt.id == preferredOption.id,
              orElse: () {
                if (allOptions.isNotEmpty) {
                  return allOptions.first;
                }
                throw Exception(
                  "Preferred option not found and no other options available.",
                );
              },
            );
          } else if (allOptions.isNotEmpty) {
            _selectedMethod = allOptions.first;
          }
        });
      }
      return PaymentScreenData(
        allOptions: allOptions,
        preferredOption: preferredOption,
      );
    } catch (e) {
      Logger.error("PaymentScreen", "Failed to fetch initial data", e);
      rethrow;
    }
  }

  void _onMethodSelected(PaymentOption newSelection) async {
    if (_selectedMethod?.id == newSelection.id) return;
    setState(() => _selectedMethod = newSelection);

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      await apiService.setPaymentPreference(paymentOptionId: newSelection.id);
      Logger.info("PaymentScreen", "Set preference to ${newSelection.name}");
    } catch (e) {
      Logger.error("PaymentScreen", "Failed to set payment preference", e);
    }
  }

  Future<void> _initiateGatewayPayment() async {
    if (_selectedMethod == null || _isGatewaySubmitting) return;
    setState(() => _isGatewaySubmitting = true);
    final l10n = AppLocalizations.of(context)!;
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      await apiService.paySubscriptionViaGateway(
        subscriptionId: widget.subscriptionId,
        paymentOptionId: _selectedMethod!.id,
      );
      if (mounted) {
        await _showSuccessDialog(
          l10n.paymentSuccessDialogTitle,
          l10n.paymentSuccessDialogContent,
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        await _showErrorDialog(l10n.paymentErrorDialogTitle, e.message);
      }
    } finally {
      if (mounted) setState(() => _isGatewaySubmitting = false);
    }
  }

  void _showManualPaymentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ManualPaymentSheet(
        subscriptionId: widget.subscriptionId,
        amount: widget.amount.toDouble(),
        onSuccess: () {
          final l10n = AppLocalizations.of(context)!;
          _showSuccessDialog(
            l10n.paymentManualSuccessTitle,
            l10n.paymentManualSuccessContent,
          );
        },
      ),
    );
  }

  Future<void> _showSuccessDialog(String title, String content) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Close dialog
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const MyTransactionsScreen()),
              );
            },
            child: Text(AppLocalizations.of(ctx)!.paymentOkButton),
          ),
        ],
      ),
    );
  }

  Future<void> _showErrorDialog(String title, String content) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppLocalizations.of(ctx)!.paymentOkButton),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent, // ✅ Use transparent background
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(l10n.paymentScreenTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: Stack(
        // ✅ Wrap in Stack for the background
        children: [
          _buildAnimatedGradientBackground(),
          _buildCornerBurstEffect(),
          SafeArea(
            // ✅ Add SafeArea to avoid notch/system UI
            child: FutureBuilder<PaymentScreenData>(
              future: _dataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        l10n.paymentErrorLoading(snapshot.error.toString()),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.allOptions.isEmpty) {
                  return Center(
                    child: Text(
                      l10n.paymentNoMethodsAvailable,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  );
                }

                final data = snapshot.data!;
                return ListView(
                  padding: const EdgeInsets.all(16.0),
                  children:
                      [
                            _buildHeader(l10n),
                            const SizedBox(height: 32.0),
                            if (data.preferredOption != null) ...[
                              _buildSectionHeader(l10n.paymentPreferredMethod),
                              _buildPaymentMethodTile(data.preferredOption!),
                              const SizedBox(height: 20),
                              _buildSectionHeader(l10n.paymentOtherGateways),
                            ] else
                              _buildSectionHeader(l10n.paymentChooseGateway),
                            ..._getVisibleOptions(
                                  data.allOptions,
                                  data.preferredOption,
                                )
                                .map(
                                  (method) => _buildPaymentMethodTile(method),
                                )
                                .toList(),
                            _buildShowAllButton(
                              l10n,
                              data.allOptions,
                              data.preferredOption,
                            ),
                            const SizedBox(height: 24),
                            _buildSubmitButton(l10n),
                            _buildManualPaymentDivider(l10n),
                            _buildManualPaymentButton(l10n),
                          ]
                          .animate(interval: 50.ms)
                          .fadeIn(duration: 300.ms)
                          .slideY(begin: 0.2),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS BELOW ARE NOW THEME-AWARE ---

  List<PaymentOption> _getVisibleOptions(
    List<PaymentOption> all,
    PaymentOption? preferred,
  ) {
    final others = all.where((opt) => opt.id != preferred?.id).toList();
    final listToConsider = preferred != null ? others : all;
    return _showAllOptions ? listToConsider : listToConsider.take(3).toList();
  }

  Widget _buildShowAllButton(
    AppLocalizations l10n,
    List<PaymentOption> all,
    PaymentOption? preferred,
  ) {
    final theme = Theme.of(context);
    final others = all.where((opt) => opt.id != preferred?.id).toList();
    final listToCheck = preferred != null ? others : all;

    if (!_showAllOptions && listToCheck.length > 3) {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: TextButton.icon(
          icon: Icon(
            Icons.add_circle_outline,
            color: theme.colorScheme.primary,
          ),
          label: Text(
            l10n.paymentViewMoreOptions,
            style: TextStyle(color: theme.colorScheme.primary),
          ),
          onPressed: () => setState(() => _showAllOptions = true),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(
          Icons.phonelink_ring_outlined,
          size: 60,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(l10n.paymentConfirmTitle, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          l10n.paymentTotalAmount(widget.amount.toStringAsFixed(2)),
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.paymentSelectGateway,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodTile(PaymentOption method) {
    final theme = Theme.of(context);
    final isSelected = _selectedMethod?.id == method.id;
    return Card(
      color: theme.colorScheme.surface,
      elevation: isSelected ? 8 : 2,
      shadowColor: isSelected
          ? theme.colorScheme.primary.withOpacity(0.5)
          : theme.shadowColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.dividerColor.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        leading: SizedBox(
          width: 40,
          height: 40,
          child: (method.logo != null && method.logo!.isNotEmpty)
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    method.logo!,
                    errorBuilder: (_, __, ___) => Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.business,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.business,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
        ),
        title: Text(method.name, style: theme.textTheme.titleMedium),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
            : Icon(
                Icons.circle_outlined,
                color: theme.dividerColor.withOpacity(0.5),
              ),
        onTap: () => _onMethodSelected(method),
      ),
    );
  }

  Widget _buildSubmitButton(AppLocalizations l10n) {
    return _isGatewaySubmitting
        ? const Center(child: CircularProgressIndicator())
        : ElevatedButton.icon(
            onPressed: _selectedMethod == null ? null : _initiateGatewayPayment,
            icon: const Icon(Icons.send_to_mobile),
            label: Text(
              _selectedMethod != null
                  ? l10n.paymentPayWith(_selectedMethod!.name)
                  : l10n.paymentSelectAGateway,
            ),
          );
  }

  Widget _buildManualPaymentDivider(AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Row(
        children: [
          Expanded(child: Divider(color: theme.dividerColor)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              l10n.paymentOr,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          Expanded(child: Divider(color: theme.dividerColor)),
        ],
      ),
    );
  }

  Widget _buildManualPaymentButton(AppLocalizations l10n) {
    final theme = Theme.of(context);
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: theme.colorScheme.primary,
        side: BorderSide(color: theme.colorScheme.primary),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      onPressed: _showManualPaymentSheet,
      icon: const Icon(Icons.upload_file),
      label: Text(l10n.paymentUploadBankReceipt),
    );
  }

  // ✅ HELPER WIDGETS COPIED FROM TEMPLATE
  Widget _buildAnimatedGradientBackground() {
    final theme = Theme.of(context);
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
                theme.colorScheme.secondary.withOpacity(0.7),
                theme.scaffoldBackgroundColor,
              ],
              stops: const [0.0, 1.0],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCornerBurstEffect() {
    final theme = Theme.of(context);
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
                  theme.colorScheme.primary.withOpacity(0.3),
                  theme.colorScheme.secondary.withOpacity(0.2),
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

class _ManualPaymentSheet extends StatefulWidget {
  final String subscriptionId;
  final double amount;
  final VoidCallback onSuccess;

  const _ManualPaymentSheet({
    required this.subscriptionId,
    required this.amount,
    required this.onSuccess,
  });

  @override
  State<_ManualPaymentSheet> createState() => _ManualPaymentSheetState();
}

class _ManualPaymentSheetState extends State<_ManualPaymentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _txnRefController = TextEditingController();
  File? _receiptImage;
  bool _isSubmitting = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() => _receiptImage = File(pickedFile.path));
    }
  }

  Future<void> _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false) ||
        _receiptImage == null ||
        _isSubmitting)
      return;

    setState(() => _isSubmitting = true);
    final l10n = AppLocalizations.of(context)!;
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      await apiService.submitManualPayment(
        subscriptionId: widget.subscriptionId,
        transactionReference: _txnRefController.text,
        receiptImage: _receiptImage!,
        amount: widget.amount,
      );

      if (mounted) {
        Navigator.of(context).pop();
        widget.onSuccess();
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.paymentErrorSnackbar(e.message))),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.paymentManualUploadTitle,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.paymentManualUploadSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _txnRefController,
                decoration: InputDecoration(
                  labelText: l10n.paymentTxnReferenceLabel,
                  prefixIcon: const Icon(Icons.receipt_long_outlined),
                ),
                validator: (value) => (value?.isEmpty ?? true)
                    ? l10n.paymentTxnReferenceRequired
                    : null,
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: DottedBorder(
             
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _receiptImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              _receiptImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload_outlined,
                                size: 40,
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.6,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.paymentTapToSelectReceipt,
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _isSubmitting
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.send_rounded),
                      label: Text(l10n.paymentSubmitForReview),
                      onPressed: _submitForm,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

// ✅ CUSTOM CLIPPER CLASS COPIED FROM TEMPLATE
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
