import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models.dart';
import '../../core/theme.dart';
import '../../data/order_repository.dart';
import '../auth/auth_provider.dart';
import 'order_tracking_screen.dart';

class MyOrdersScreen extends ConsumerWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(currentUserProvider)!;
    final repo = ref.watch(orderRepositoryProvider);
    return StreamBuilder<List<Order>>(
      stream: repo.ordersStream,
      initialData: repo.orders,
      builder: (context, snap) {
        final orders = (snap.data ?? repo.orders).where((o) => o.customerId == auth.id).toList();
        if (orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.receipt_long_outlined, size: 64, color: AppTheme.muted),
                const SizedBox(height: 12),
                Text('No orders yet', style: TextStyle(color: AppTheme.muted, fontSize: 16)),
                const SizedBox(height: 4),
                Text('Place your first order to track it live.', style: TextStyle(color: AppTheme.muted, fontSize: 13)),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final o = orders[i];
            return Material(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => OrderTrackingScreen(orderId: o.id))),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(o.items.first.item.emoji, style: const TextStyle(fontSize: 24)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(o.restaurant, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 2),
                            Text('${o.itemCount} items · ₹${o.total.toStringAsFixed(0)}',
                                style: TextStyle(fontSize: 13, color: AppTheme.muted)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: (o.status == OrderStatus.delivered ? AppTheme.success : AppTheme.primary).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(o.status.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: o.status == OrderStatus.delivered ? AppTheme.success : AppTheme.primary,
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
