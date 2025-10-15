// // FILE: lib/screens/contract/payment_screen.dart
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:dotted_border/dotted_border.dart';
// import 'package:provider/provider.dart';

// // Your project's models and services
// import '../../models/payments/payment_option.dart';
// import '../../services/api_service.dart';
// import '../../utils/api_exception.dart';
// import '../../utils/logger.dart';

// // Data class to hold the results of our initial API calls
// class PaymentScreenData {
//   final List<PaymentOption> allOptions;
//   final PaymentOption? preferredOption;
//   PaymentScreenData({required this.allOptions, this.preferredOption});
// }

// class PaymentScreen extends StatefulWidget {
//   final String subscriptionId;
//   final String contractType;
//   final num amount;

//   const PaymentScreen({
//     super.key,
//     required this.subscriptionId,
//     required this.contractType,
//     required this.amount,
//   });

//   @override
//   State<PaymentScreen> createState() => _PaymentScreenState();
// }

// class _PaymentScreenState extends State<PaymentScreen> {
//   // --- STATE VARIABLES ---
//   late Future<PaymentScreenData> _dataFuture;
//   PaymentOption? _selectedMethod;
//   bool _isGatewaySubmitting = false;
//   bool _showAllOptions = false;

//   @override
//   void initState() {
//     super.initState();
//     _dataFuture = _fetchInitialData();
//   }

//   // --- LOGIC METHODS ---

//   Future<PaymentScreenData> _fetchInitialData() async {
//     final apiService = Provider.of<ApiService>(context, listen: false);
//     try {
//       // Fetch both sets of data concurrently
//       final results = await Future.wait([
//         apiService.getPassengerPaymentOptions(),
//         apiService.getPaymentPreference(),
//       ]);
//       final allOptions = results[0] as List<PaymentOption>;
//       final preferredOption = results[1] as PaymentOption?;

//       // Set the initial selected method based on the fetched data
//       if (mounted) {
//         setState(() {
//           if (preferredOption != null) {
//             _selectedMethod = allOptions.firstWhere(
//               (opt) => opt.id == preferredOption.id,
//               orElse: () =>
//                   allOptions.first, // Fallback if preferred not in list
//             );
//           } else if (allOptions.isNotEmpty) {
//             _selectedMethod = allOptions.first; // Default to first option
//           }
//         });
//       }
//       return PaymentScreenData(
//         allOptions: allOptions,
//         preferredOption: preferredOption,
//       );
//     } catch (e) {
//       Logger.error("PaymentScreen", "Failed to fetch initial data", e);
//       rethrow; // Let the FutureBuilder handle the error UI
//     }
//   }

//   void _onMethodSelected(PaymentOption newSelection) async {
//     if (_selectedMethod?.id == newSelection.id) return;
//     setState(() => _selectedMethod = newSelection);

//     // Set the preference in the background for next time
//     try {
//       final apiService = Provider.of<ApiService>(context, listen: false);
//       await apiService.setPaymentPreference(paymentOptionId: newSelection.id);
//       Logger.info("PaymentScreen", "Set preference to ${newSelection.name}");
//     } catch (e) {
//       Logger.error("PaymentScreen", "Failed to set payment preference", e);
//     }
//   }

//   Future<void> _initiateGatewayPayment() async {
//     if (_selectedMethod == null || _isGatewaySubmitting) return;

//     setState(() => _isGatewaySubmitting = true);

//     try {
//       final apiService = Provider.of<ApiService>(context, listen: false);
//       await apiService.paySubscriptionViaGateway(
//         subscriptionId: widget.subscriptionId,
//         paymentOptionId: _selectedMethod!.id,
//       );

//       Logger.success("PaymentScreen", "Payment STK push initiated.");
//       if (mounted) {
//         await _showSuccessDialog(
//           'Confirmation Sent!',
//           'A request has been sent to your phone. Please enter your PIN to approve the payment.',
//         );
//       }
//     } on ApiException catch (e) {
//       Logger.error("PaymentScreen", "Failed to initiate payment", e);
//       if (mounted) {
//         await _showErrorDialog('Payment Error', e.message);
//       }
//     } finally {
//       if (mounted) setState(() => _isGatewaySubmitting = false);
//     }
//   }

//   void _showManualPaymentSheet() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (_) => _ManualPaymentSheet(
//         subscriptionId: widget.subscriptionId,
//         amount: widget.amount.toDouble(),
//         onSuccess: () {
//           _showSuccessDialog(
//             'Upload Successful',
//             'Your payment proof has been submitted and is pending review.',
//           );
//         },
//       ),
//     );
//   }

//   Future<void> _showSuccessDialog(String title, String content) {
//     return showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (ctx) => AlertDialog(
//         title: Text(title),
//         content: Text(content),
//         actions: [
//           TextButton(
//             onPressed: () =>
//                 Navigator.of(ctx).popUntil((route) => route.isFirst),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _showErrorDialog(String title, String content) {
//     return showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: Text(title),
//         content: Text(content),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(ctx).pop(),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Complete Your Payment')),
//       body: FutureBuilder<PaymentScreenData>(
//         future: _dataFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Center(
//               child: Text('Error loading payment methods: ${snapshot.error}'),
//             );
//           }
//           if (!snapshot.hasData || snapshot.data!.allOptions.isEmpty) {
//             return const Center(child: Text('No payment methods available.'));
//           }

//           final data = snapshot.data!;
//           final allOptions = data.allOptions;
//           final preferredOption = data.preferredOption;

//           return ListView(
//             padding: const EdgeInsets.all(16.0),
//             children: [
//               _buildHeader(Theme.of(context).textTheme),
//               const Divider(height: 32.0),

//               if (preferredOption != null) ...[
//                 _buildSectionHeader('PREFERRED METHOD'),
//                 _buildPaymentMethodTile(preferredOption),
//                 const SizedBox(height: 20),
//                 _buildSectionHeader('OTHER GATEWAYS'),
//               ],

//               if (preferredOption == null)
//                 _buildSectionHeader('CHOOSE A GATEWAY'),

//               ..._getVisibleOptions(
//                 allOptions,
//                 preferredOption,
//               ).map((method) => _buildPaymentMethodTile(method)),

//               _buildShowAllButton(allOptions, preferredOption),

//               const SizedBox(height: 24),
//               _buildSubmitButton(),

//               _buildManualPaymentDivider(),
//               _buildManualPaymentButton(),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   // --- BUILDER WIDGETS ---

//   List<PaymentOption> _getVisibleOptions(
//     List<PaymentOption> all,
//     PaymentOption? preferred,
//   ) {
//     final others = all.where((opt) => opt.id != preferred?.id).toList();
//     final listToConsider = preferred != null ? others : all;
//     return _showAllOptions ? listToConsider : listToConsider.take(3).toList();
//   }

//   Widget _buildShowAllButton(
//     List<PaymentOption> all,
//     PaymentOption? preferred,
//   ) {
//     final others = all.where((opt) => opt.id != preferred?.id).toList();
//     final listToCheck = preferred != null ? others : all;

//     if (!_showAllOptions && listToCheck.length > 3) {
//       return Padding(
//         padding: const EdgeInsets.only(top: 8.0),
//         child: TextButton.icon(
//           icon: const Icon(Icons.add_circle_outline),
//           label: const Text('View More Options'),
//           onPressed: () => setState(() => _showAllOptions = true),
//         ),
//       );
//     }
//     return const SizedBox.shrink();
//   }

//   Widget _buildSectionHeader(String title) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
//       child: Text(
//         title.toUpperCase(),
//         style: TextStyle(
//           color: Colors.grey.shade600,
//           fontWeight: FontWeight.bold,
//           fontSize: 12,
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader(TextTheme textTheme) {
//     return Column(
//       children: [
//         Icon(
//           Icons.phonelink_ring_outlined,
//           size: 60,
//           color: Theme.of(context).colorScheme.primary,
//         ),
//         const SizedBox(height: 16),
//         Text(
//           'Confirm Your Payment',
//           style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           'Total Amount: ETB ${widget.amount.toStringAsFixed(2)}',
//           style: textTheme.titleLarge?.copyWith(
//             color: Theme.of(context).colorScheme.primary,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 12),
//         Text(
//           'Select your preferred payment gateway or upload a bank receipt.',
//           textAlign: TextAlign.center,
//           style: textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
//         ),
//       ],
//     );
//   }

//   Widget _buildPaymentMethodTile(PaymentOption method) {
//     final isSelected = _selectedMethod?.id == method.id;
//     return Card(
//       elevation: isSelected ? 4 : 1,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(8),
//         side: BorderSide(
//           color: isSelected
//               ? Theme.of(context).colorScheme.primary
//               : Colors.grey.shade300,
//           width: isSelected ? 2 : 1,
//         ),
//       ),
//       margin: const EdgeInsets.symmetric(vertical: 5.0),
//       child: ListTile(
//         leading: SizedBox(
//           width: 40,
//           height: 40,
//           child: (method.logo != null && method.logo!.isNotEmpty)
//               ? Image.network(
//                   method.logo!,
//                   errorBuilder: (_, __, ___) => const CircleAvatar(
//                     backgroundColor: Colors.black12,
//                     child: Icon(Icons.business, color: Colors.black54),
//                   ),
//                 )
//               : const CircleAvatar(
//                   backgroundColor: Colors.black12,
//                   child: Icon(Icons.business, color: Colors.black54),
//                 ),
//         ),
//         title: Text(
//           method.name,
//           style: const TextStyle(fontWeight: FontWeight.w500),
//         ),
//         trailing: isSelected
//             ? Icon(
//                 Icons.check_circle,
//                 color: Theme.of(context).colorScheme.primary,
//               )
//             : const Icon(Icons.circle_outlined, color: Colors.grey),
//         onTap: () => _onMethodSelected(method),
//       ),
//     );
//   }

//   Widget _buildSubmitButton() {
//     return _isGatewaySubmitting
//         ? const Center(child: CircularProgressIndicator())
//         : ElevatedButton.icon(
//             style: ElevatedButton.styleFrom(
//               padding: const EdgeInsets.symmetric(vertical: 16),
//               textStyle: const TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             onPressed: _selectedMethod == null ? null : _initiateGatewayPayment,
//             icon: const Icon(Icons.send_to_mobile),
//             label: Text(
//               _selectedMethod != null
//                   ? 'Pay with ${_selectedMethod!.name}'
//                   : 'Select a Gateway',
//             ),
//           );
//   }

//   Widget _buildManualPaymentDivider() {
//     return const Padding(
//       padding: EdgeInsets.symmetric(vertical: 20.0),
//       child: Row(
//         children: [
//           Expanded(child: Divider()),
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 8.0),
//             child: Text('OR', style: TextStyle(color: Colors.grey)),
//           ),
//           Expanded(child: Divider()),
//         ],
//       ),
//     );
//   }

//   Widget _buildManualPaymentButton() {
//     return OutlinedButton.icon(
//       style: OutlinedButton.styleFrom(
//         padding: const EdgeInsets.symmetric(vertical: 16),
//         textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         foregroundColor: Theme.of(context).colorScheme.primary,
//       ),
//       onPressed: _showManualPaymentSheet,
//       icon: const Icon(Icons.upload_file),
//       label: const Text('Upload Bank Receipt'),
//     );
//   }
// }

// // A separate StatefulWidget for the bottom sheet to manage its own form state.
// class _ManualPaymentSheet extends StatefulWidget {
//   final String subscriptionId;
//   final double amount;
//   final VoidCallback onSuccess;

//   const _ManualPaymentSheet({
//     required this.subscriptionId,
//     required this.amount,
//     required this.onSuccess,
//   });

//   @override
//   State<_ManualPaymentSheet> createState() => _ManualPaymentSheetState();
// }

// class _ManualPaymentSheetState extends State<_ManualPaymentSheet> {
//   final _formKey = GlobalKey<FormState>();
//   final _txnRefController = TextEditingController();
//   File? _receiptImage;
//   bool _isSubmitting = false;

//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(
//       source: ImageSource.gallery,
//       imageQuality: 80,
//     );
//     if (pickedFile != null) {
//       setState(() => _receiptImage = File(pickedFile.path));
//     }
//   }

//   Future<void> _submitForm() async {
//     if (!(_formKey.currentState?.validate() ?? false)) return;
//     if (_receiptImage == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select a receipt image.')),
//       );
//       return;
//     }
//     if (_isSubmitting) return;

//     setState(() => _isSubmitting = true);

//     try {
//       final apiService = Provider.of<ApiService>(context, listen: false);
//       // Use the correct ApiService method
//       await apiService.submitManualPayment(
//         subscriptionId: widget.subscriptionId,
//         transactionReference: _txnRefController.text,
//         receiptImage: _receiptImage!,
//         amount: widget.amount,
//       );

//       if (mounted) {
//         Navigator.of(context).pop(); // Close the bottom sheet
//         widget.onSuccess(); // Call the success callback
//       }
//     } on ApiException catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
//       }
//     } finally {
//       if (mounted) setState(() => _isSubmitting = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.fromLTRB(
//         16,
//         16,
//         16,
//         16 + MediaQuery.of(context).viewInsets.bottom,
//       ),
//       child: SingleChildScrollView(
//         child: Form(
//           key: _formKey,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Manual Payment Upload',
//                 style: Theme.of(context).textTheme.titleLarge,
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'Enter the bank transaction reference and upload a screenshot of your receipt.',
//                 style: Theme.of(context).textTheme.bodySmall,
//               ),
//               const SizedBox(height: 24),
//               TextFormField(
//                 controller: _txnRefController,
//                 decoration: const InputDecoration(
//                   labelText: 'Transaction Reference',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.receipt_long),
//                 ),
//                 validator: (value) =>
//                     (value?.isEmpty ?? true) ? 'This field is required' : null,
//               ),
//               const SizedBox(height: 16),
//               GestureDetector(
//                 onTap: _pickImage,
//                 child: DottedBorder(
//                   borderType: BorderType.RRect,
//                   radius: const Radius.circular(12),
//                   dashPattern: const [6, 6],
//                   color: Colors.grey.shade600,
//                   strokeWidth: 2,
//                   child: Container(
//                     height: 150,
//                     width: double.infinity,
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade100,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: _receiptImage != null
//                         ? ClipRRect(
//                             borderRadius: BorderRadius.circular(10),
//                             child: Image.file(
//                               _receiptImage!,
//                               fit: BoxFit.cover,
//                             ),
//                           )
//                         : Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(
//                                 Icons.cloud_upload_outlined,
//                                 size: 40,
//                                 color: Colors.grey.shade700,
//                               ),
//                               const SizedBox(height: 8),
//                               Text(
//                                 'Tap to select receipt image',
//                                 style: TextStyle(color: Colors.grey.shade800),
//                               ),
//                             ],
//                           ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),
//               _isSubmitting
//                   ? const Center(child: CircularProgressIndicator())
//                   : SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton.icon(
//                         icon: const Icon(Icons.send_outlined),
//                         label: const Text('Submit for Review'),
//                         onPressed: _submitForm,
//                         style: ElevatedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                         ),
//                       ),
//                     ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
