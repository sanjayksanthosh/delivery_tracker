import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'models.dart';

class DeliveryMap extends StatefulWidget {
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
  State<DeliveryMap> createState() => _DeliveryMapState();
}

class _DeliveryMapState extends State<DeliveryMap> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  LatLng? _from;
  LatLng? _to;
  LatLng? _current;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _from = widget.driverLat != null ? LatLng(widget.driverLat!, widget.driverLng!) : null;
    _to = _from;
    _current = _from;
  }

  @override
  void didUpdateWidget(covariant DeliveryMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newDriver = widget.driverLat != null ? LatLng(widget.driverLat!, widget.driverLng!) : null;
    if (newDriver != null && (_current == null || newDriver != _to)) {
      _from = _current ?? newDriver;
      _to = newDriver;
      _ctrl.forward(from: 0);
    } else if (newDriver == null) {
      _from = null;
      _to = null;
      _current = null;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  LatLng? get _animatedDriver {
    if (_to == null) return null;
    if (_from == null) return _to;
    final t = Curves.easeInOut.transform(_ctrl.value);
    return LatLng(
      _from!.latitude + (_to!.latitude - _from!.latitude) * t,
      _from!.longitude + (_to!.longitude - _from!.longitude) * t,
    );
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = LatLng(widget.restaurantLat, widget.restaurantLng);
    final customer = LatLng(widget.customerLat, widget.customerLng);
    final driver = _animatedDriver;
    final center = LatLng(
      (widget.restaurantLat + widget.customerLat) / 2,
      (widget.restaurantLng + widget.customerLng) / 2,
    );

    final markers = <Marker>[
      Marker(
        point: restaurant,
        width: 48,
        height: 48,
        child: _Pin(color: const Color(0xFFEB6534), emoji: '🍽', label: 'Restaurant'),
      ),
      Marker(
        point: customer,
        width: 48,
        height: 48,
        child: _Pin(color: const Color(0xFF5DA980), emoji: '🏠', label: 'You'),
      ),
    ];
    if (driver != null) {
      markers.add(Marker(
        point: driver,
        width: 52,
        height: 52,
        child: _AnimatedDriverPin(),
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
          if (widget.showRoute)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: [
                    restaurant,
                    if (driver != null) driver,
                    customer,
                  ],
                  color: const Color(0xFFEB6534).withValues(alpha: 0.55),
                  strokeWidth: 4,
                  pattern: StrokePattern.dashed(segments: const [10, 6]),
                ),
              ],
            ),
          MarkerLayer(markers: markers),
        ],
      ),
    );
  }
}

class _AnimatedDriverPin extends StatefulWidget {
  @override
  State<_AnimatedDriverPin> createState() => _AnimatedDriverPinState();
}

class _AnimatedDriverPinState extends State<_AnimatedDriverPin> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) {
        final scale = 1 + (_pulse.value * 0.35);
        return Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: scale,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFBCB4D).withValues(alpha: 0.25 * (1 - _pulse.value)),
                ),
              ),
            ),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFFBCB4D),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: const Color(0xFFFBCB4D).withValues(alpha: 0.5), blurRadius: 10)],
                border: Border.all(color: Colors.white, width: 2.5),
              ),
              alignment: Alignment.center,
              child: const Text('🛵', style: TextStyle(fontSize: 18)),
            ),
          ],
        );
      },
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
