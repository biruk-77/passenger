// lib/screens/history_screen/history_detail_screen.dart (DEFINITIVE CORRECTED VERSION)

import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
// A. IMPORT WAS MISSING for Provider

import '../../models/ride_history.dart';
// A. IMPORT WAS MISSING
import '../../theme/color.dart';
import '../../utils/constants.dart';
import '../../utils/map_style.dart';


class HistoryDetailScreen extends StatefulWidget {
  final RideHistoryItem item;
  const HistoryDetailScreen({super.key, required this.item});

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  bool _isLoadingRoute = true;

  @override
  void initState() {
    super.initState();
    _setMarkers();
    // Use a post-frame callback to safely access Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchRouteDetails();
    });
  }

  void _setMarkers() {
    if (widget.item.pickup?.coordinates != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('pickup'),
          position: widget.item.pickup!.coordinates,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          infoWindow: const InfoWindow(title: 'Pickup Location'),
        ),
      );
    }
    if (widget.item.dropoff?.coordinates != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('dropoff'),
          position: widget.item.dropoff!.coordinates,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: 'Dropoff Location'),
        ),
      );
    }
  }

  // B. POLYLINEPOINTS LOGIC CORRECTED
 // --- START OF THE DEFINITIVE, FINAL FIX ---

  Future<void> _fetchRouteDetails() async {
    final pickupCoords = widget.item.pickup?.coordinates;
    final dropoffCoords = widget.item.dropoff?.coordinates;

    if (pickupCoords == null || dropoffCoords == null) {
      if (mounted) {
        setState(() => _isLoadingRoute = false);
      }
      return;
    }

    // CORRECT: The constructor REQUIRES the apiKey.
    PolylinePoints polylinePoints = PolylinePoints(apiKey: ApiConstants.googleApiKey);

    try {
      // CORRECT: The method call uses a NAMED 'request' parameter and does NOT
      // pass the apiKey again, as it's already in the instance.
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: PointLatLng(pickupCoords.latitude, pickupCoords.longitude),
          destination: PointLatLng(
            dropoffCoords.latitude,
            dropoffCoords.longitude,
          ),
          mode: TravelMode.driving,
        ),
      );

      if (result.points.isNotEmpty) {
        if (mounted) {
          setState(() {
            _polylines.add(
              Polyline(
                polylineId: const PolylineId('route'),
                points: result.points
                    .map((p) => LatLng(p.latitude, p.longitude))
                    .toList(),
                color: AppColors.primaryColor,
                width: 5,
              ),
            );
          });
        }
      } else {
        debugPrint("Could not find a route: ${result.errorMessage}");
      }
    } catch (e) {
      debugPrint("Error fetching route with PolylinePoints: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoadingRoute = false);
      }
    }
  }
  

  @override
  Widget build(BuildContext context) {
    final bounds = _createBounds();
    final date = DateFormat(
      'EEEE, MMM dd, yyyy',
    ).format(widget.item.createdAt.toLocal());
    final time = DateFormat('hh:mm a').format(widget.item.createdAt.toLocal());
    final currencyFormat = NumberFormat.currency(
      locale: 'en_US',
      symbol: 'Birr ',
    );

    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target:
                  widget.item.pickup?.coordinates ??
                  const LatLng(9.005401, 38.763611),
              zoom: 14,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              controller.setMapStyle(mapStyle);
              Future.delayed(const Duration(milliseconds: 500), () {
                if (bounds != null) {
                  controller.animateCamera(
                    CameraUpdate.newLatLngBounds(bounds, 70),
                  );
                }
              });
            },
            markers: _markers,
            polylines: _polylines,
          ),
          Positioned(
            top: 40,
            left: 16,
            child: FloatingActionButton(
              mini: true,
              onPressed: () => Navigator.of(context).pop(),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              child: const Icon(Icons.arrow_back),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.35,
            minChildSize: 0.35,
            maxChildSize: 0.8,
            builder: (context, scrollController) {
              return FadeInUp(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        date,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 16,
                        ),
                      ),
                      const Divider(color: Colors.black12, height: 32),
                      if (widget.item.driverName != null) ...[
                        _DetailSection(
                          title: 'YOUR DRIVER',
                          child: Row(
                            children: [
                              const CircleAvatar(
                                radius: 24,
                                backgroundColor: AppColors.primaryColor,
                                child: Icon(
                                  PhosphorIcons.user,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  widget.item.driverName!,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      _DetailSection(
                        title: 'TOTAL FARE',
                        child: Text(
                          currencyFormat.format(widget.item.fare ?? 0),
                          style: const TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _DetailSection(
                        title: 'YOUR TRIP',
                        child: Column(
                          children: [
                            _AddressRow(
                              icon: PhosphorIcons.circleFill,
                              color: AppColors.success,
                              address:
                                  widget.item.pickup?.address ??
                                  "Not available",
                            ),
                            const SizedBox(height: 16),
                            _AddressRow(
                              icon: PhosphorIcons.mapPinFill,
                              color: Colors.redAccent,
                              address:
                                  widget.item.dropoff?.address ??
                                  "Not available",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  LatLngBounds? _createBounds() {
    final pickup = widget.item.pickup?.coordinates;
    final dropoff = widget.item.dropoff?.coordinates;

    if (pickup == null || dropoff == null) return null;

    return LatLngBounds(
      southwest: LatLng(
        pickup.latitude < dropoff.latitude ? pickup.latitude : dropoff.latitude,
        pickup.longitude < dropoff.longitude
            ? pickup.longitude
            : dropoff.longitude,
      ),
      northeast: LatLng(
        pickup.latitude > dropoff.latitude ? pickup.latitude : dropoff.latitude,
        pickup.longitude > dropoff.longitude
            ? pickup.longitude
            : dropoff.longitude,
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final Widget child;
  const _DetailSection({required this.title, required this.child});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 12,
            letterSpacing: 1.2,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _AddressRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String address;
  const _AddressRow({
    required this.icon,
    required this.color,
    required this.address,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            address,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
