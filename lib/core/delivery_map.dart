import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'models.dart';

/// Map widget built on `flutter_map` (OpenStreetMap tiles) — no API key
/// required, so it runs out of the box. Markers are placed from lat/lng.
class DeliveryMap extends StatelessWidget {
  final double restaurantLat;
  final double restaurantLng;
  final double customerLat;
  final double customerLng;
  final double? driverLat;
  final double? driverLng;
  final bool showRoute;

  const DeliveryMap({
    super.key,
    required this.restaurantLat,
    required this.restaurantLng,
    required this.customerLat,
    required this.customerLng,
    this.driverLat,
    this.driverLng,
    this.showRoute = true,
  });

  @override
  Widget build(BuildContext context) {
    final center = LatLng(
      (restaurantLat + customerLat) / 2,
      (restaurantLng + customerLng) / 2,
    );
    final markers = <Marker>[
      Marker(
        point: LatLng(restaurantLat, restaurantLng),
        width: 44,
        height: 44,
        child: _Pin(color: const Color(0xFFE63946), emoji: '🍽', label: 'Restaurant'),
      ),
      Marker(
        point: LatLng(customerLat, customerLng),
        width: 44,
        height: 44,
        child: _Pin(color: const Color(0xFF2A9D8F), emoji: '🏠', label: 'You'),
      ),
    ];
    if (driverLat != null && driverLng != null) {
      markers.add(Marker(
        point: LatLng(driverLat!, driverLng!),
        width: 44,
        height: 44,
        child: _Pin(color: const Color(0xFFF4A261), emoji: '🛵', label: 'Driver'),
      ));
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: FlutterMap(
        options: MapOptions(
          initialCenter: center,
          initialZoom: 14,
          interactionOptions: const InteractionOptions(flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.sanjay.swiftbite',
          ),
          if (showRoute)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: [
                    LatLng(restaurantLat, restaurantLng),
                    if (driverLat != null && driverLng != null) LatLng(driverLat!, driverLng!),
                    LatLng(customerLat, customerLng),
                  ],
                  color: const Color(0xFFE63946).withValues(alpha: 0.5),
                  strokeWidth: 4,
                ),
              ],
            ),
          MarkerLayer(markers: markers),
        ],
      ),
    );
  }
}

class _Pin extends StatelessWidget {
  final Color color;
  final String emoji;
  final String label;
  const _Pin({required this.color, required this.emoji, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 2))],
            border: Border.all(color: Colors.white, width: 2),
          ),
          alignment: Alignment.center,
          child: Text(emoji, style: const TextStyle(fontSize: 16)),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)]),
          child: Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color)),
        ),
      ],
    );
  }
}
