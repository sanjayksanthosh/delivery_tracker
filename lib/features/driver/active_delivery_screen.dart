import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/delivery_map.dart';
import '../../core/models.dart';
import '../../core/theme.dart';
import '../../data/order_repository.dart';
import '../auth/auth_provider.dart';

class ActiveDeliveryScreen extends ConsumerWidget {
  const ActiveDeliveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(currentUserProvider)!;
    final repo = ref.watch(orderRepositoryProvider);
    return StreamBuilder<List<Order>>(
      stream: repo.ordersStream,
      initialData: repo.orders,
      builder: (context, snap) {
        final orders = (snap.data ?? repo.orders).where((o) => o.status == OrderStatus.outForDelivery).toList();
        if (orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.navigation_outlined, size: 64, color: AppTheme.muted),
                const SizedBox(height: 12),
                Text('No active delivery', style: TextStyle(color: AppTheme.muted, fontSize: 16)),
                const SizedBox(height: 4),
                Text('Accept an order from the Available tab.', style: TextStyle(color: AppTheme.muted, fontSize: 13)),
              ],
            ),
          );
        }
        final order = orders.first;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SizedBox(
              height: 260,
              child: DeliveryMap(
                restaurantLat: order.restaurantLat,
                restaurantLng: order.restaurantLng,
                customerLat: order.customerLat,
                customerLng: order.customerLng,
                driverLat: order.driverLat,
                driverLng: order.driverLng,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order.restaurant, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(order.address, style: TextStyle(fontSize: 13, color: AppTheme.muted)),
                  const SizedBox(height: 4),
                  Text('${order.customerName} · ${order.itemCount} items · ₹${order.total.toStringAsFixed(0)}',
                      style: TextStyle(fontSize: 13, color: AppTheme.muted)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (order.status == OrderStatus.outForDelivery)
              FilledButton.icon(
                onPressed: () => ref.read(orderRepositoryProvider).advanceStatus(order.id),
                icon: const Icon(Icons.check_circle),
                label: const Text('Mark as delivered'),
                style: FilledButton.styleFrom(backgroundColor: AppTheme.success),
              ),
            if (order.status == OrderStatus.delivered)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: AppTheme.success),
                    SizedBox(width: 8),
                    Text('Delivered!', style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
