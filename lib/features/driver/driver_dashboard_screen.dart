import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models.dart';
import '../../core/theme.dart';
import '../../data/order_repository.dart';
import '../auth/auth_provider.dart';

class DriverDashboardScreen extends ConsumerStatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  ConsumerState<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends ConsumerState<DriverDashboardScreen> {
  bool _online = true;

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(orderRepositoryProvider);
    return StreamBuilder<List<Order>>(
      stream: repo.ordersStream,
      initialData: repo.orders,
      builder: (context, snap) {
        final orders = (snap.data ?? repo.orders).where((o) => o.status == OrderStatus.placed || o.status == OrderStatus.preparing).toList();
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Welcome + toggle
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppTheme.primaryOrange, AppTheme.primaryDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(AppTheme.rXl),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Welcome back,', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text(ref.watch(currentUserProvider)?.name ?? 'Driver', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(999)),
                          child: Text(_online ? '🟢 Online' : '⚪ Offline', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _online,
                    onChanged: (v) => setState(() => _online = v),
                    activeThumbColor: Colors.white,
                    activeTrackColor: AppTheme.freshGreen,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Earnings summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.rLg),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  _EarningStat(label: 'Today', value: '₹420'),
                  _EarningStat(label: 'This week', value: '₹2,180'),
                  _EarningStat(label: 'Deliveries', value: '14'),
                  _EarningStat(label: 'Rating', value: '4.9★'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Available orders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                Text('${orders.length} new', style: TextStyle(fontSize: 13, color: AppTheme.primaryOrange, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),
            if (orders.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.rLg), border: Border.all(color: AppTheme.border)),
                child: Column(
                  children: [
                    Icon(Icons.inbox_outlined, size: 48, color: AppTheme.muted),
                    const SizedBox(height: 8),
                    Text('No orders available', style: TextStyle(color: AppTheme.muted, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('New orders appear here in real time.', style: TextStyle(color: AppTheme.muted, fontSize: 12)),
                  ],
                ),
              )
            else
              ...orders.map((o) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _OrderCard(order: o, onAccept: () => ref.read(orderRepositoryProvider).acceptOrder(o.id, drivers.first)),
                  )),
          ],
        );
      },
    );
  }
}

class _EarningStat extends StatelessWidget {
  final String label;
  final String value;
  const _EarningStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onAccept;
  const _OrderCard({required this.order, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.rLg),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: AppTheme.primaryOrange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                alignment: Alignment.center,
                child: Text(order.items.first.item.emoji, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.restaurant, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    Text('${order.itemCount} items · ₹${order.total.toStringAsFixed(0)}', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: AppTheme.warning.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                child: Text(order.status.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.warning)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 14, color: AppTheme.textSecondary),
              const SizedBox(width: 4),
              Expanded(child: Text(order.address, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary))),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onAccept,
            icon: const Icon(Icons.check),
            label: const Text('Accept order'),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryOrange),
          ),
        ],
      ),
    );
  }
}
