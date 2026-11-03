import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'config.dart';
import 'models.dart';

/// Map widget that uses real Google Maps tiles when an API key is configured
/// in [AppConfig.googleMapsApiKey], and falls back to a self-contained custom
/// painter otherwise (so the app runs with zero setup).
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
    if (AppConfig.googleMapsApiKey.isNotEmpty) {
      return _GoogleMapView(
        restaurantLat: restaurantLat,
        restaurantLng: restaurantLng,
        customerLat: customerLat,
        customerLng: customerLng,
        driverLat: driverLat,
        driverLng: driverLng,
      );
    }
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

class _GoogleMapView extends StatelessWidget {
  final double restaurantLat, restaurantLng, customerLat, customerLng;
  final double? driverLat, driverLng;
  const _GoogleMapView({
    required this.restaurantLat,
    required this.restaurantLng,
    required this.customerLat,
    required this.customerLng,
    this.driverLat,
    this.driverLng,
  });

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>{
      Marker(markerId: const MarkerId('restaurant'), position: LatLng(restaurantLat, restaurantLng), infoWindow: const InfoWindow(title: 'Restaurant')),
      Marker(markerId: const MarkerId('customer'), position: LatLng(customerLat, customerLng), infoWindow: const InfoWindow(title: 'You')),
    };
    if (driverLat != null && driverLng != null) {
      markers.add(Marker(markerId: const MarkerId('driver'), position: LatLng(driverLat!, driverLng!), infoWindow: const InfoWindow(title: 'Driver')));
    }
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng((restaurantLat + customerLat) / 2, (restaurantLng + customerLng) / 2),
        zoom: 14,
      ),
      markers: markers,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
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

  Offset _project(double lat, double lng, Size size) {
    const minLat = 12.960, maxLat = 12.985;
    const minLng = 77.585, maxLng = 77.605;
    final x = (lng - minLng) / (maxLng - minLng) * size.width;
    final y = (1 - (lat - minLat) / (maxLat - minLat)) * size.height;
    return Offset(x.clamp(24.0, size.width - 24), y.clamp(24.0, size.height - 24));
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFEAF1F8));
    final grid = Paint()..color = const Color(0xFFD6E0EC)..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 48) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += 48) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final road = Paint()
      ..color = const Color(0xFFBFD0E2)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, size.height * 0.35), Offset(size.width, size.height * 0.35), road);
    canvas.drawLine(Offset(size.width * 0.45, 0), Offset(size.width * 0.45, size.height), road);
    canvas.drawLine(Offset(0, size.height * 0.7), Offset(size.width, size.height * 0.7), road);

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

    _marker(canvas, _project(restaurantLat, restaurantLng, size), const Color(0xFFE63946), '🍽', 'Restaurant');
    _marker(canvas, _project(customerLat, customerLng, size), const Color(0xFF2A9D8F), '🏠', 'You');

    if (driverLat != null && driverLng != null) {
      final dp = _project(driverLat!, driverLng!, size);
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
    final lp = TextPainter(
      text: TextSpan(text: label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w700)),
      textDirection: TextDirection.ltr,
    )..layout();
    lp.paint(canvas, Offset(p.dx - lp.width / 2, p.dy + 20));
  }

  @override
  bool shouldRepaint(covariant _MapPainter old) => true;
}
