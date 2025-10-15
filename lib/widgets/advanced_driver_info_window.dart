// lib/widgets/advanced_driver_info_window.dart

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

// ✅ IMPORT THE GENERATED LOCALIZATIONS FILE
import '../../l10n/app_localizations.dart';

import '../models/nearby_driver.dart';
import '../theme/color.dart';

class AdvancedDriverInfoWindow extends StatelessWidget {
  final NearbyDriver driver;
  final VoidCallback onSelect;
  final VoidCallback onClose;

  const AdvancedDriverInfoWindow({
    super.key,
    required this.driver,
    required this.onSelect,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    // Get the localizations object for easy access
    final l10n = AppLocalizations.of(context)!;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 70,
      left: 15,
      right: 15,
      child: FadeInDown(
        duration: const Duration(milliseconds: 400),
        child: Material(
          elevation: 0,
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  spreadRadius: -5,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: driver.photoUrl != null
                      ? NetworkImage(driver.photoUrl!)
                      : null,
                  child: driver.photoUrl == null
                      ? const Icon(
                          Icons.person_rounded,
                          size: 30,
                          color: Colors.black45,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              driver.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (driver.rating != null) ...[
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 18,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              driver.rating!.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _buildInfoChip(
                            icon: Icons.directions_car_filled_rounded,
                            text:
                                driver.vehicleType ??
                                l10n.driverInfoWindowVehicleStandard, // ✅ LOCALIZED
                            color: AppColors.primaryColor,
                          ),
                          const SizedBox(width: 6),
                          _buildInfoChip(
                            icon: driver.available
                                ? Icons.check_circle_rounded
                                : Icons.cancel_rounded,
                            text: driver.available
                                ? l10n.driverInfoWindowAvailable
                                : l10n.driverInfoWindowOnTrip, // ✅ LOCALIZED
                            color: driver.available
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: onSelect,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          elevation: 2,
                        ),
                        child: Text(
                          l10n.driverInfoWindowSelect, // ✅ LOCALIZED
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 20,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 20,
                        icon: Icon(Icons.close, color: Colors.grey.shade400),
                        onPressed: onClose,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
