// lib/widgets/shared_widgets.dart

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

// --- SHARED WIDGETS FOR ALL PANELS AND HOME SCREEN ---

class MapOverlayButtons extends StatelessWidget {
  final VoidCallback onMenuTap, onGpsTap, onLayersTap, onCancelTap;
  final bool showCancel;
  const MapOverlayButtons({
    super.key,
    required this.onMenuTap,
    required this.onGpsTap,
    required this.onLayersTap,
    required this.showCancel,
    required this.onCancelTap,
  });
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 15,
      left: 15,
      right: 15,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircularButton(icon: Icons.menu_rounded, onTap: onMenuTap),
          if (showCancel)
            FadeIn(
              duration: const Duration(milliseconds: 300),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.close, color: Colors.redAccent),
                label: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.redAccent),
                ),
                onPressed: onCancelTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ),
          Column(
            children: [
              CircularButton(icon: Icons.gps_fixed, onTap: onGpsTap),
              const SizedBox(height: 10),
              CircularButton(icon: Icons.layers_outlined, onTap: onLayersTap),
            ],
          ),
        ],
      ),
    );
  }
}

class CircularButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const CircularButton({super.key, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 45,
        height: 45,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Icon(icon, color: Colors.black54),
      ),
    );
  }
}

class InfoChip extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const InfoChip({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 28),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Text(
          value.isNotEmpty ? value : 'N/A',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class PanelHandle extends StatelessWidget {
  final Color color;
  const PanelHandle({super.key, this.color = const Color(0xFFCCCCCC)});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 5,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  final IconData icon;
  final String title, value;
  final Color titleColor, valueColor, iconColor;

  const DetailRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.titleColor = Colors.black54,
    this.valueColor = Colors.black87,
    this.iconColor = Colors.black54,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: titleColor, fontSize: 13)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: valueColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RatingBar extends StatelessWidget {
  final double initialRating;
  final int itemCount;
  final EdgeInsetsGeometry itemPadding;
  final Widget Function(BuildContext, int) itemBuilder;
  final void Function(double) onRatingUpdate;
  final Color glowColor;
  final Color unratedColor;
  final double minRating;
  final Axis direction;
  final bool allowHalfRating;

  const RatingBar.builder({
    super.key,
    required this.initialRating,
    this.minRating = 0.0,
    this.direction = Axis.horizontal,
    this.allowHalfRating = false,
    this.itemCount = 5,
    this.itemPadding = EdgeInsets.zero,
    required this.itemBuilder,
    required this.onRatingUpdate,
    this.glowColor = Colors.amber,
    this.unratedColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(itemCount, (index) {
        double starRating = index + 1.0;
        Widget starWidget;
        if (initialRating >= starRating) {
          starWidget = Icon(Icons.star, color: glowColor, size: 28);
        } else if (allowHalfRating &&
            initialRating > index &&
            initialRating < starRating) {
          starWidget = Icon(Icons.star_half, color: glowColor, size: 28);
        } else {
          starWidget = Icon(Icons.star_border, color: unratedColor, size: 28);
        }
        return GestureDetector(
          onTap: () => onRatingUpdate(starRating),
          child: Padding(padding: itemPadding, child: starWidget),
        );
      }),
    );
  }
}
