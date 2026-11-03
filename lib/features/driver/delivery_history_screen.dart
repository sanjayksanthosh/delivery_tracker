import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';

class DeliveryHistoryScreen extends StatelessWidget {
  const DeliveryHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = [
      ('Spice Route', '12 Oct 2026', '₹340', 'Delivered'),
      ('Pizza Barn', '11 Oct 2026', '₹280', 'Delivered'),
      ('Sushi Zen', '10 Oct 2026', '₹520', 'Delivered'),
      ('Spice Route', '09 Oct 2026', '₹190', 'Delivered'),
      ('Pizza Barn', '08 Oct 2026', '₹310', 'Delivered'),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Delivery history')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppTheme.freshGreen, const Color(0xFF3D8B6E)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(AppTheme.rXl),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total earnings', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 4),
                      const Text('₹1,640', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      const Text('5 deliveries this week', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(16)),
                  alignment: Alignment.center,
                  child: const Text('🛵', style: TextStyle(fontSize: 28)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Completed deliveries', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 12),
          ...history.map((h) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.rLg),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(color: AppTheme.freshGreen.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                        alignment: Alignment.center,
                        child: const Icon(Icons.check_circle, color: AppTheme.freshGreen),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(h.$1, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                            Text(h.$2, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(h.$3, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.primaryOrange)),
                          Text(h.$4, style: TextStyle(fontSize: 11, color: AppTheme.freshGreen, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
