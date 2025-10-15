// // FILE: lib/screens/passenger/pending_subscriptions_screen.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../models/contract/contract_ride.dart'; // Ensure correct path
// import '../../services/api_service.dart';
// import 'payment_screen.dart'; // Ensure correct path

// class PendingSubscriptionsScreen extends StatefulWidget {
//   const PendingSubscriptionsScreen({super.key});

//   @override
//   State<PendingSubscriptionsScreen> createState() =>
//       _PendingSubscriptionsScreenState();
// }

// class _PendingSubscriptionsScreenState
//     extends State<PendingSubscriptionsScreen> {
//   late Future<List<Subscription>> _pendingSubscriptionsFuture;

//   @override
//   void initState() {
//     super.initState();
//     final apiService = Provider.of<ApiService>(context, listen: false);
//     _pendingSubscriptionsFuture = apiService.getMySubscriptions().then(
//       (subs) => subs.where((s) => s.status == 'PENDING').toList(),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Pending Payments')),
//       body: FutureBuilder<List<Subscription>>(
//         future: _pendingSubscriptionsFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }
//           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(
//               child: Padding(
//                 padding: EdgeInsets.all(16.0),
//                 child: Text(
//                   'You have no subscriptions pending payment.',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(fontSize: 16, color: Colors.grey),
//                 ),
//               ),
//             );
//           }

//           final pendingSubs = snapshot.data!;
//           return ListView.builder(
//             itemCount: pendingSubs.length,
//             itemBuilder: (context, index) {
//               final sub = pendingSubs[index];

//               // ✅ FIX: Changed 'sub.amount' to 'sub.price'
//               // The '?? 0' provides a safe default if the price is unexpectedly null.
//               final price = sub.price ?? 0;

//               return ListTile(
//                 leading: const Icon(Icons.receipt_long_outlined),
//                 title: Text(sub.contractType ?? 'Subscription'),
//                 subtitle: Text('Amount: ETB ${price.toStringAsFixed(2)}'),
//                 trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//                 onTap: () {
//                   Navigator.of(context).push(
//                     MaterialPageRoute(
//                       builder: (context) => PaymentScreen(
//                         subscriptionId: sub.id,
//                         contractType: sub.contractType ?? 'N/A',
//                         // ✅ FIX: Changed 'sub.amount' to 'price'
//                         amount: price,
//                       ),
//                     ),
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
