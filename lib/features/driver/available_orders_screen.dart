import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models.dart';
import '../../core/theme.dart';
import '../../data/order_repository.dart';

class AvailableOrdersScreen extends ConsumerWidget {
  const AvailableOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(orderRepositoryProvider);
    return StreamBuilder<List<Order>>(
      stream: repo.ordersStream,
      initialData: repo.orders,
      builder: (context, snap) {
        final orders = (snap.data ?? repo.orders)
            .where((o) => o.status == OrderStatus.placed || o.status == OrderStatus.preparing)
            .toList();
        if (orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: AppTheme.muted),
                const SizedBox(height: 12),
                Text('No orders available', style: TextStyle(color: AppTheme.muted, fontSize: 16)),
                const SizedBox(height: 4),
                Text('New orders appear here in real time.', style: TextStyle(color: AppTheme.muted, fontSize: 13)),
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
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                              Text('${o.itemCount} items · ₹${o.total.toStringAsFixed(0)}',
                                  style: TextStyle(fontSize: 13, color: AppTheme.muted)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.warning.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(o.status.label,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.warning)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 14, color: AppTheme.muted),
                        const SizedBox(width: 4),
                        Expanded(child: Text(o.address, style: TextStyle(fontSize: 12, color: AppTheme.muted))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () {
                        ref.read(orderRepositoryProvider).acceptOrder(o.id, drivers.first);
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Accept & deliver'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
