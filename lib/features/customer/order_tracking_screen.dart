import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/delivery_map.dart';
import '../../core/models.dart';
import '../../core/theme.dart';
import '../../data/order_repository.dart';

class OrderTrackingScreen extends ConsumerStatefulWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends ConsumerState<OrderTrackingScreen> {
  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(orderRepositoryProvider);
    return StreamBuilder<List<Order>>(
      stream: repo.ordersStream,
      initialData: repo.orders,
      builder: (context, snap) {
        final orders = snap.data ?? repo.orders;
        Order? order;
        for (final o in orders) {
          if (o.id == widget.orderId) { order = o; break; }
        }
        if (order == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return _build(context, order);
      },
    );
  }

  Widget _build(BuildContext context, Order order) {
    final driver = (order.status == OrderStatus.outForDelivery || order.status == OrderStatus.delivered)
        ? (order.driverName ?? 'Ravi Kumar')
        : null;
    return Scaffold(
      appBar: AppBar(title: Text('Order #${order.id}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Map
          SizedBox(
            height: 260,
            child: DeliveryMap(
              restaurantLat: order.restaurantLat,
              restaurantLng: order.restaurantLng,
              customerLat: order.customerLat,
              customerLng: order.customerLng,
              driverLat: (order.status == OrderStatus.outForDelivery || order.status == OrderStatus.delivered) ? order.driverLat : null,
              driverLng: (order.status == OrderStatus.outForDelivery || order.status == OrderStatus.delivered) ? order.driverLng : null,
            ),
          ),
          const SizedBox(height: 16),
          // Status timeline
          _StatusTimeline(status: order.status),
          const SizedBox(height: 16),
          // Order summary
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
                const Divider(height: 20),
                ...order.items.map((c) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${c.item.name} × ${c.qty}', style: const TextStyle(fontSize: 14)),
                          Text('₹${c.total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    Text('₹${order.total.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.primary)),
                  ],
                ),
              ],
            ),
          ),
          if (driver != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: const Text('🛵', style: TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(driver, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        Text('On the way · ETA ~5 min', style: TextStyle(fontSize: 13, color: AppTheme.muted)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('4.9 ★', style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.w700, fontSize: 13)),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
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
                  Text('Delivered! Enjoy your meal.', style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  final OrderStatus status;
  const _StatusTimeline({required this.status});

  @override
  Widget build(BuildContext context) {
    final steps = [OrderStatus.placed, OrderStatus.preparing, OrderStatus.outForDelivery, OrderStatus.delivered];
    final current = status.step;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          for (int i = 0; i < steps.length; i++) ...[
            Expanded(
              child: Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: i <= current ? AppTheme.primary : AppTheme.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: i <= current ? AppTheme.primary : AppTheme.border,
                        width: 2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: i <= current
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : Text('${i + 1}', style: TextStyle(fontSize: 12, color: AppTheme.muted, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 6),
                  Text(steps[i].label, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: i <= current ? FontWeight.w700 : FontWeight.w400, color: i <= current ? AppTheme.ink : AppTheme.muted)),
                ],
              ),
            ),
            if (i < steps.length - 1)
              Container(
                height: 2,
                width: 24,
                margin: const EdgeInsets.only(bottom: 22),
                color: i < current ? AppTheme.primary : AppTheme.border,
              ),
          ],
        ],
      ),
    );
  }
}
