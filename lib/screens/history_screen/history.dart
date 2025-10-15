// lib/screens/history_screen/history.dart (ULTIMATE CALM & DETAILED REDESIGN)

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/foundation.dart';
import '../../models/ride_history.dart';
import '../../models/search_result.dart';
// ✅ =======================================================
// === FIX: Re-added the import as it's now used by the new preview widget ===
// ============================================================
import '../../models/vehicle_type.dart';
import '../../providers/history_provider.dart';
import '../../services/google_maps_service.dart';
import '../../theme/color.dart';
import '../home_screen.dart';
import 'history_detail_screen.dart';

// ... The HistoryScreen and _HistoryListViewState widgets remain the same ...
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabNames = ['All', 'Completed', 'Canceled'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<HistoryProvider>(context, listen: false);
      provider.fetchHistory(tabIndex: 0, isRefresh: true);
    });
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final provider = Provider.of<HistoryProvider>(context, listen: false);
    final currentTab = provider.tabs[_tabController.index]!;
    if (currentTab.historyItems.isEmpty && !currentTab.isLoading) {
      provider.fetchHistory(tabIndex: _tabController.index, isRefresh: true);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ride History',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.goldenrod,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 16,
          ),
          tabs: _tabNames.map((name) => Tab(text: name)).toList(),
        ),
      ),
      backgroundColor: const Color(0xFF121212),
      body: Consumer<HistoryProvider>(
        builder: (context, provider, child) {
          return TabBarView(
            controller: _tabController,
            children: provider.tabs.entries.map((entry) {
              final tabIndex = entry.key;
              final tabData = entry.value;
              return _HistoryListView(
                key: ValueKey('list_$tabIndex'),
                tabData: tabData,
                onRefresh: () =>
                    provider.fetchHistory(tabIndex: tabIndex, isRefresh: true),
                onLoadMore: () => provider.fetchHistory(tabIndex: tabIndex),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _HistoryListView extends StatefulWidget {
  final HistoryTabData tabData;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;
  const _HistoryListView({
    super.key,
    required this.tabData,
    required this.onRefresh,
    required this.onLoadMore,
  });
  @override
  State<_HistoryListView> createState() => _HistoryListViewState();
}

class _HistoryListViewState extends State<_HistoryListView> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      widget.onLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tabData.isLoading && widget.tabData.historyItems.isEmpty) {
      return const _ShimmerLoadingState();
    }

    if (widget.tabData.errorMessage != null &&
        widget.tabData.errorMessage != "No Internet Connection" &&
        widget.tabData.historyItems.isEmpty) {
      return _ErrorState(
        message: widget.tabData.errorMessage!,
        onRetry: widget.onRefresh,
      );
    }
    if (widget.tabData.historyItems.isEmpty) return const _EmptyState();

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      color: AppColors.goldenrod,
      backgroundColor: const Color(0xFF1E293B),
      child: Column(
        children: [
          if (widget.tabData.errorMessage == "No Internet Connection")
            const _NoInternetBanner(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 80.0),
              itemCount:
                  widget.tabData.historyItems.length +
                  (widget.tabData.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == widget.tabData.historyItems.length) {
                  return const _LoadingIndicator();
                }
                final item = widget.tabData.historyItems[index];
                return _HistoryCard(item: item);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final RideHistoryItem item;

  const _HistoryCard({required this.item});

  String _formatCoordinates(LatLng? coords) {
    if (coords == null) return 'Unknown Location';
    return 'Loc: ${coords.latitude.toStringAsFixed(4)}, ${coords.longitude.toStringAsFixed(4)}';
  }

  void _onRebook(BuildContext context) {
    if (item.pickup?.coordinates == null || item.dropoff?.coordinates == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cannot rebook, location data is missing."),
        ),
      );
      return;
    }

    final startDetails = PlaceDetails(
      primaryText: item.pickup!.address ?? 'Pickup Location',
      coordinates: item.pickup!.coordinates,
      placeId: 'history_pickup_${item.id}',
    );

    final endDetails = PlaceDetails(
      primaryText: item.dropoff!.address ?? 'Destination',
      coordinates: item.dropoff!.coordinates,
      placeId: 'history_dropoff_${item.id}',
    );

    final searchResult = SearchResult(
      action: SearchAction.selectPlace,
      start: startDetails,
      end: endDetails,
    );

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => HomeScreen(initialRoute: searchResult),
      ),
      (route) => false,
    );
  }

  void _onTapDetails(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => HistoryDetailScreen(item: item)));
  }

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('MMMM dd, yyyy').format(item.createdAt.toLocal());
    final time = DateFormat('hh:mm a').format(item.createdAt.toLocal());
    final hasLocationData =
        item.pickup?.coordinates != null && item.dropoff?.coordinates != null;

    final pickupAddress =
        item.pickup?.address ?? _formatCoordinates(item.pickup?.coordinates);
    final dropoffAddress =
        item.dropoff?.address ?? _formatCoordinates(item.dropoff?.coordinates);

    return InkWell(
      onTap: () => _onTapDetails(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20.0),
        decoration: BoxDecoration(
          color: const Color(0xFF232323),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        date,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      _StatusChip(status: item.status),
                    ],
                  ),
                  Text(
                    time,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _AddressRow(
                    icon: PhosphorIcons.circleFill,
                    color: Colors.greenAccent,
                    address: pickupAddress,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, top: 4, bottom: 4),
                    child: CustomPaint(
                      painter: _DottedLinePainter(),
                      child: const SizedBox(height: 20, width: 1),
                    ),
                  ),
                  _AddressRow(
                    icon: PhosphorIcons.mapPinFill,
                    color: Colors.redAccent,
                    address: dropoffAddress,
                  ),
                ],
              ),
            ),
            if (hasLocationData)
              _RideMapPreview(item: item, onTap: () => _onTapDetails(context)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.2)),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _DetailItem(
                            icon: PhosphorIcons.money,
                            value: item.fare != null
                                ? 'Birr ${item.fare!.toStringAsFixed(2)}'
                                : 'N/A',
                          ),
                          const _DetailDivider(),
                          _DetailItem(
                            icon: PhosphorIcons.car,
                            value: item.vehicleType.capitalize(),
                          ),
                          if (item.driverName != null) ...[
                            const _DetailDivider(),
                            _DetailItem(
                              icon: PhosphorIcons.user,
                              value: item.driverName!,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (hasLocationData)
                    _ActionButton(
                      icon: PhosphorIcons.repeat,
                      onTap: () => _onRebook(context),
                      label: 'Book Again',
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =======================================================================
// === ✅ NEW WIDGET: Redesigned to show the vehicle on top of the map! ===
// =======================================================================
class _RideMapPreview extends StatelessWidget {
  final RideHistoryItem item;
  final VoidCallback onTap;

  const _RideMapPreview({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Get data needed for the preview
    final pickupCoords = item.pickup!.coordinates!;
    final dropoffCoords = item.dropoff!.coordinates!;
    final mapsService = Provider.of<GoogleMapsService>(context, listen: false);

    // Use the VehicleType model to get the correct image path
    final vehicle = VehicleType.fromName(item.vehicleType);

    // Generate the static map URL
   final mapUrl = mapsService.getStaticMapUrlWithRoute( 
      pickup: pickupCoords,
      dropoff: dropoffCoords,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160, // Increased height for better visuals
        color: const Color(0xFF2D2D2D),
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            // Layer 1: The map background
            Image.network(
              mapUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(
                    PhosphorIcons.mapTrifold,
                    color: Colors.white24,
                    size: 48,
                  ),
                );
              },
            ),

            // Layer 2: The subtle shadow for the 3D effect
            Align(
              alignment: const Alignment(0.0, 0.6), // Position shadow lower
              child: Container(
                width: 150,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),
            ),

            // Layer 3: The large vehicle image
            Center(
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: 20.0,
                ), // Lift the car a bit
                child: Image.asset(
                  vehicle.imagePath,
                  height: 85, // Make the vehicle image large
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Layer 4: The dark gradient at the bottom for text readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.9),
                  ],
                  stops: const [0.5, 0.7, 1.0],
                ),
              ),
            ),

            // Layer 5: The "View Details" button
            const Positioned(
              bottom: 12,
              right: 12,
              child: Text(
                "View Details",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ... (All other helper widgets below this line are unchanged) ...
class _DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    var max = size.height;
    var dashWidth = 2;
    var dashSpace = 3;
    double startY = 0;
    while (startY < max) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _NoInternetBanner extends StatelessWidget {
  const _NoInternetBanner();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.amber.shade800,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(PhosphorIcons.wifiSlash, color: Colors.white, size: 16),
          SizedBox(width: 8),
          Text(
            "You are offline. Showing cached data.",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String label;
  const _ActionButton({
    required this.icon,
    required this.onTap,
    required this.label,
  });
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.1),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _DetailDivider extends StatelessWidget {
  const _DetailDivider();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 12,
      width: 1,
      color: Colors.white24,
      margin: const EdgeInsets.symmetric(horizontal: 12),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String value;
  const _DetailItem({required this.icon, required this.value});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white54, size: 16),
        const SizedBox(width: 6),
        Text(
          value.capitalize(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            address,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ShimmerLoadingState extends StatelessWidget {
  const _ShimmerLoadingState();
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF232323),
      highlightColor: const Color(0xFF2A2A2A),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        itemCount: 4,
        itemBuilder: (_, __) => Container(
          height: 320,
          margin: const EdgeInsets.only(bottom: 20.0),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(PhosphorIcons.filesLight, color: Colors.white38, size: 100),
          SizedBox(height: 24),
          Text(
            'No Rides Yet',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Your past trips will appear here.',
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});
  @override
  Widget build(BuildContext context) {
    Color chipColor;
    Color textColor;
    String displayText = status.capitalize();
    switch (status.toLowerCase()) {
      case 'completed':
        chipColor = AppColors.success;
        textColor = chipColor;
        break;
      case 'canceled':
        chipColor = Colors.redAccent;
        textColor = chipColor;
        break;
      default:
        chipColor = Colors.orangeAccent;
        textColor = chipColor;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: chipColor.withOpacity(0.5)),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  final double size;
  const _LoadingIndicator({this.size = 30.0});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.goldenrod),
          strokeWidth: 2.5,
        ),
      ),
    ),
  );
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(PhosphorIcons.cloudSlash, size: 60, color: Colors.white38),
          const SizedBox(height: 16),
          const Text(
            'Something Went Wrong',
            style: TextStyle(fontSize: 18, color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white38),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, color: AppColors.goldenrod),
            label: const Text(
              'Try Again',
              style: TextStyle(color: AppColors.goldenrod),
            ),
          ),
        ],
      ),
    );
  }
}
