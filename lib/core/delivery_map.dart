import 'package:flutter/material.dart';

import 'models.dart';

/// A self-contained, dependency-free "map" widget.
///
/// It does not need a Google Maps API key, so the app runs out of the box.
/// In production this would be swapped for `google_maps_flutter` with real
/// tiles; the marker positions are driven by the same lat/lng values.
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: CustomPaint(
        painter: _MapPainter(
          restaurantLat: restaurantLat,
          restaurantLng: restaurantLng,
          customerLat: customerLat,
          customerLng: customerLng,
          driverLat: driverLat,
          driverLng: driverLng,
          showRoute: showRoute,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  final double restaurantLat, restaurantLng, customerLat, customerLng;
  final double? driverLat, driverLng;
  final bool showRoute;

  _MapPainter({
    required this.restaurantLat,
    required this.restaurantLng,
    required this.customerLat,
    required this.customerLng,
    this.driverLat,
    this.driverLng,
    required this.showRoute,
  });

  // Project lat/lng into canvas coordinates (simple equirectangular).
  Offset _project(double lat, double lng, Size size) {
    const minLat = 12.960, maxLat = 12.985;
    const minLng = 77.585, maxLng = 77.605;
    final x = (lng - minLng) / (maxLng - minLng) * size.width;
    final y = (1 - (lat - minLat) / (maxLat - minLat)) * size.height;
    return Offset(x.clamp(24.0, size.width - 24), y.clamp(24.0, size.height - 24));
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFEAF1F8));

    // Grid (streets)
    final grid = Paint()..color = const Color(0xFFD6E0EC)..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 48) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += 48) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    // Major roads
    final road = Paint()
      ..color = const Color(0xFFBFD0E2)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, size.height * 0.35), Offset(size.width, size.height * 0.35), road);
    canvas.drawLine(Offset(size.width * 0.45, 0), Offset(size.width * 0.45, size.height), road);
    canvas.drawLine(Offset(0, size.height * 0.7), Offset(size.width, size.height * 0.7), road);

    // Route line
    if (showRoute) {
      final r = _project(restaurantLat, restaurantLng, size);
      final c = _project(customerLat, customerLng, size);
      final d = driverLat != null ? _project(driverLat!, driverLng!, size) : null;
      final end = d ?? c;
      final route = Paint()
        ..color = const Color(0xFFE63946).withValues(alpha: 0.35)
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke;
      final path = Path()..moveTo(r.dx, r.dy);
      if (d != null) {
        path.lineTo(d.dx, d.dy);
        path.lineTo(c.dx, c.dy);
      } else {
        path.lineTo(c.dx, c.dy);
      }
      canvas.drawPath(path, route);
    }

    // Restaurant marker
    _marker(canvas, _project(restaurantLat, restaurantLng, size), const Color(0xFFE63946), '🍽', 'Restaurant');

    // Customer marker
    _marker(canvas, _project(customerLat, customerLng, size), const Color(0xFF2A9D8F), '🏠', 'You');

    // Driver marker (animated pulse via a separate layer is not possible here; draw static)
    if (driverLat != null && driverLng != null) {
      final dp = _project(driverLat!, driverLng!, size);
      // pulse ring
      canvas.drawCircle(dp, 26, Paint()..color = const Color(0xFFF4A261).withValues(alpha: 0.25));
      canvas.drawCircle(dp, 18, Paint()..color = const Color(0xFFF4A261).withValues(alpha: 0.4));
      _marker(canvas, dp, const Color(0xFFF4A261), '🛵', 'Driver');
    }
  }

  void _marker(Canvas canvas, Offset p, Color color, String emoji, String label) {
    canvas.drawCircle(p, 22, Paint()..color = color.withValues(alpha: 0.18));
    canvas.drawCircle(p, 16, Paint()..color = color);
    final tp = TextPainter(
      text: TextSpan(text: emoji, style: const TextStyle(fontSize: 16)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(p.dx - tp.width / 2, p.dy - tp.height / 2));
    // label
    final lp = TextPainter(
      text: TextSpan(text: label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w700)),
      textDirection: TextDirection.ltr,
    )..layout();
    lp.paint(canvas, Offset(p.dx - lp.width / 2, p.dy + 20));
  }

  @override
  bool shouldRepaint(covariant _MapPainter old) => true;
}
