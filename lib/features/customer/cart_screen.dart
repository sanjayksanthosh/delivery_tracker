import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models.dart';
import '../../core/theme.dart';
import '../../data/order_repository.dart';
import '../auth/auth_provider.dart';
import 'cart_provider.dart';
import 'checkout_screen.dart';

class CartScreen extends ConsumerStatefulWidget {
  final Restaurant restaurant;
  const CartScreen({super.key, required this.restaurant});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final _address = TextEditingController(text: '12, MG Road, Bengaluru');
  bool _placing = false;

  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  void _checkout() {
    final cart = ref.read(cartProvider);
    if (cart.isEmpty) return;
    final restaurants = ref.read(restaurantsProvider);
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => CheckoutScreen(restaurant: restaurants.first)));
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Your cart')),
      body: cart.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 64, color: AppTheme.muted),
                  const SizedBox(height: 12),
                  Text('Cart is empty', style: TextStyle(color: AppTheme.muted, fontSize: 16)),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ...cart.map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Row(
                          children: [
                            Text(c.item.emoji, style: const TextStyle(fontSize: 28)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(c.item.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                                  Text('₹${c.item.price.toStringAsFixed(0)} × ${c.qty}',
                                      style: TextStyle(fontSize: 13, color: AppTheme.muted)),
                                ],
                              ),
                            ),
                            Text('₹${c.total.toStringAsFixed(0)}',
                                style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.primary)),
                          ],
                        ),
                      ),
                    )),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      Text('₹${total.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.primary)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: cart.isEmpty ? null : _checkout,
                  child: const Text('Proceed to checkout'),
                ),
              ],
            ),
    );
  }
}
