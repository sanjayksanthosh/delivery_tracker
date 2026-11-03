import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models.dart';
import '../../core/theme.dart';
import '../../data/order_repository.dart';
import 'cart_provider.dart';
import 'cart_screen.dart';

class RestaurantDetailScreen extends ConsumerWidget {
  final Restaurant restaurant;
  const RestaurantDetailScreen({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final count = ref.watch(cartCountProvider);
    final total = ref.watch(cartTotalProvider);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 160,
            backgroundColor: AppTheme.card,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(restaurant.name, style: const TextStyle(color: AppTheme.ink, fontWeight: FontWeight.w700)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(restaurant.emoji, style: const TextStyle(fontSize: 64)),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(restaurant.cuisine, style: TextStyle(color: AppTheme.muted, fontSize: 14)),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final item = restaurant.menu[i];
                final inCart = cart.where((c) => c.item.id == item.id).firstOrNull;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: _MenuItemCard(
                    item: item,
                    qty: inCart?.qty ?? 0,
                    onAdd: () => ref.read(cartProvider.notifier).add(item),
                    onRemove: () => ref.read(cartProvider.notifier).remove(item.id),
                  ),
                );
              },
              childCount: restaurant.menu.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      bottomNavigationBar: count > 0
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => CartScreen(restaurant: restaurant))),
                  child: Text('View cart · $count items · ₹${total.toStringAsFixed(0)}'),
                ),
              ),
            )
          : null,
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final int qty;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  const _MenuItemCard({required this.item, required this.qty, required this.onAdd, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(item.emoji, style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(item.description, style: TextStyle(fontSize: 12, color: AppTheme.muted)),
                const SizedBox(height: 6),
                Text('₹${item.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.primary)),
              ],
            ),
          ),
          if (qty == 0)
            FilledButton.tonal(
              onPressed: onAdd,
              style: FilledButton.styleFrom(
                minimumSize: const Size(44, 40),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('ADD'),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.remove, size: 18), color: AppTheme.primary, onPressed: onRemove, visualDensity: VisualDensity.compact),
                  Text('$qty', style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.primary)),
                  IconButton(icon: const Icon(Icons.add, size: 18), color: AppTheme.primary, onPressed: onAdd, visualDensity: VisualDensity.compact),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
