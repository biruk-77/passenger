// // lib/widgets/ride_booking_panel.dart
// import 'dart:ui';
// import 'package:animate_do/animate_do.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../models/vehicle_type.dart';
// import '../providers/map_state_provider.dart';

// class RideBookingPanel extends StatelessWidget {
//   const RideBookingPanel({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // This is a non-const value, so the constructor for Padding must also be non-const
//     final EdgeInsets panelPadding = EdgeInsets.fromLTRB(
//       20,
//       12,
//       20,
//       20 + MediaQuery.of(context).padding.bottom,
//     );

//     return ClipRRect(
//       borderRadius: const BorderRadius.vertical(top: Radius.circular(30.0)),
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
//         child: Container(
//           decoration: BoxDecoration(
//             color: Colors.grey.shade900.withValues(alpha:0.8),
//             borderRadius: const BorderRadius.vertical(
//               top: Radius.circular(30.0),
//             ),
//             border: Border.all(color: Colors.white.withValues(alpha:0.2)),
//           ),
//           child: Padding(
//             padding: panelPadding, // Use the non-const padding here
//             child: Consumer<MapStateProvider>(
//               builder: (context, provider, child) {
//                 return AnimatedSwitcher(
//                   duration: const Duration(milliseconds: 400),
//                   transitionBuilder: (child, animation) =>
//                       FadeTransition(opacity: animation, child: child),
//                   child: _buildPanelContent(provider),
//                 );
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildPanelContent(MapStateProvider provider) {
//     switch (provider.currentMapState) {
//       case MapState.discovery:
//         return DiscoveryPanel(key: const ValueKey('discovery'));
//       case MapState.planning:
//         return PlanningPanel(key: const ValueKey('planning'));
//       case MapState.searchingForDriver:
//         return SearchingPanel(key: const ValueKey('searching'));
//       case MapState.driverOnTheWay:
//       case MapState.ongoingTrip:
//         return DriverInfoPanel(key: const ValueKey('driver_info'));
//     }
//   }
// }

// class DiscoveryPanel extends StatelessWidget {
//   const DiscoveryPanel({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         const _PanelHandle(),
//         const SizedBox(height: 24),
//         const Text(
//           'Set Destination',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 16),
//         const Text(
//           'Tap on the map to select a destination point.',
//           textAlign: TextAlign.center,
//           style: TextStyle(color: Colors.white70, fontSize: 16),
//         ),
//         const SizedBox(height: 24),
//       ],
//     );
//   }
// }

// class PlanningPanel extends StatelessWidget {
//   const PlanningPanel({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<MapStateProvider>();
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         const _PanelHandle(),
//         const SizedBox(height: 24),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             _InfoChip(
//               icon: Icons.timer,
//               label: "Est. Time",
//               value: provider.estimatedTime,
//             ),
//             _InfoChip(
//               icon: Icons.route,
//               label: "Distance",
//               value: provider.estimatedDistance,
//             ),
//           ],
//         ),
//         const Divider(color: Colors.white24, height: 32),
//         SizedBox(height: 100, child: _buildRideOptions(provider)),
//         const SizedBox(height: 24),
//         ElevatedButton(
//           onPressed: (provider.isBooking || provider.vehicleTypes.isEmpty)
//               ? null
//               : provider.confirmRide,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.amber,
//             foregroundColor: Colors.black,
//             minimumSize: const Size(double.infinity, 50),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//           child: provider.isBooking
//               ? const SizedBox(
//                   width: 24,
//                   height: 24,
//                   child: CircularProgressIndicator(
//                     color: Colors.black,
//                     strokeWidth: 3,
//                   ),
//                 )
//               : const Text(
//                   'Request Ride',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//         ),
//       ],
//     );
//   }

//   Widget _buildRideOptions(MapStateProvider provider) {
//     if (provider.isLoadingRideOptions)
//       return const Center(
//         child: CircularProgressIndicator(color: Colors.white),
//       );
//     if (provider.rideOptionsError != null)
//       return Center(
//         child: Text(
//           provider.rideOptionsError!,
//           style: const TextStyle(color: Colors.redAccent),
//         ),
//       );
//     if (provider.vehicleTypes.isEmpty)
//       return const Center(
//         child: Text(
//           'No ride types available.',
//           style: TextStyle(color: Colors.white70),
//         ),
//       );

//     return ListView.builder(
//       scrollDirection: Axis.horizontal,
//       itemCount: provider.vehicleTypes.length,
//       itemBuilder: (context, index) {
//         final ride = provider.vehicleTypes[index];
//         final isSelected = index == provider.selectedRideOptionIndex;
//         return GestureDetector(
//           onTap: () => provider.selectRideOption(index),
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 250),
//             curve: Curves.easeInOut,
//             width: 100,
//             margin: const EdgeInsets.symmetric(horizontal: 8),
//             decoration: BoxDecoration(
//               color: isSelected
//                   ? Colors.white
//                   : Colors.grey.shade800.withValues(alpha:0.5),
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(
//                 color: isSelected ? Colors.amber : Colors.transparent,
//                 width: 2,
//               ),
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   ride.icon,
//                   size: 36,
//                   color: isSelected ? Colors.black : Colors.white,
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   ride.name,
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: isSelected ? Colors.black : Colors.white,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// class SearchingPanel extends StatelessWidget {
//   const SearchingPanel({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         const _PanelHandle(),
//         const SizedBox(height: 32),
//         FadeIn(
//           delay: const Duration(milliseconds: 200),
//           child: const Text(
//             'Connecting you to a driver...',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 22,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         const SizedBox(height: 24),
//         Flash(
//           infinite: true,
//           child: const Icon(Icons.radar, color: Colors.amber, size: 60),
//         ),
//         const SizedBox(height: 24),
//         FadeInUp(
//           delay: const Duration(milliseconds: 400),
//           child: OutlinedButton(
//             onPressed: () => context.read<MapStateProvider>().cancelBooking(),
//             style: OutlinedButton.styleFrom(
//               foregroundColor: Colors.white,
//               side: const BorderSide(color: Colors.white38),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//             child: const Text('Cancel Search'),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class DriverInfoPanel extends StatelessWidget {
//   const DriverInfoPanel({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<MapStateProvider>();
//     final driver = provider.assignedDriverDetails;
//     final vehicle = provider.assignedVehicleDetails;

//     if (driver == null || vehicle == null) {
//       return const Center(
//         child: Text(
//           "Loading driver details...",
//           style: TextStyle(color: Colors.white),
//         ),
//       );
//     }

//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         const _PanelHandle(),
//         const SizedBox(height: 16),
//         Text(
//           provider.currentMapState == MapState.ongoingTrip
//               ? 'En Route to Destination'
//               : 'Your driver is on the way!',
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           'Arriving in ${provider.etaToPickup}',
//           style: const TextStyle(
//             color: Colors.amber,
//             fontSize: 18,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         const Divider(color: Colors.white24, height: 32),
//         Row(
//           children: [
//             CircleAvatar(
//               radius: 30,
//               backgroundColor: Colors.white24,
//               backgroundImage: driver['photoUrl'] != null
//                   ? NetworkImage(driver['photoUrl'])
//                   : null,
//               child: driver['photoUrl'] == null
//                   ? const Icon(Icons.person, color: Colors.white, size: 30)
//                   : null,
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     driver['name'] ?? 'Driver',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Row(
//                     children: [
//                       const Icon(Icons.star, color: Colors.amber, size: 16),
//                       const SizedBox(width: 4),
//                       Text(
//                         driver['rating'].toString(),
//                         style: const TextStyle(color: Colors.white70),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                 color: Colors.black.withValues(alpha:0.3),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Text(
//                 vehicle['licensePlate'] ?? '---',
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   letterSpacing: 1.5,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         Text(
//           "${vehicle['color'] ?? ''} ${vehicle['make'] ?? ''} ${vehicle['model'] ?? ''}",
//           style: const TextStyle(color: Colors.white70),
//         ),
//         const SizedBox(height: 24),
//         Row(
//           children: [
//             Expanded(
//               child: OutlinedButton(
//                 onPressed: () =>
//                     context.read<MapStateProvider>().cancelBooking(),
//                 style: OutlinedButton.styleFrom(
//                   foregroundColor: Colors.redAccent,
//                   side: const BorderSide(color: Colors.redAccent),
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                 ),
//                 child: const Text('Cancel'),
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: ElevatedButton.icon(
//                 onPressed: () {},
//                 icon: const Icon(Icons.call_outlined),
//                 label: const Text('Contact'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.white,
//                   foregroundColor: Colors.black,
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }

// class _PanelHandle extends StatelessWidget {
//   const _PanelHandle();
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 40,
//       height: 5,
//       decoration: BoxDecoration(
//         color: Colors.grey.shade700,
//         borderRadius: BorderRadius.circular(12),
//       ),
//     );
//   }
// }

// class _InfoChip extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;

//   const _InfoChip({
//     required this.icon,
//     required this.label,
//     required this.value,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Icon(icon, color: Colors.white70),
//         const SizedBox(height: 4),
//         Text(
//           value.isNotEmpty ? value : '--',
//           style: const TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//             fontSize: 18,
//           ),
//         ),
//         const SizedBox(height: 2),
//         Text(
//           label,
//           style: const TextStyle(color: Colors.white70, fontSize: 12),
//         ),
//       ],
//     );
//   }
// }
