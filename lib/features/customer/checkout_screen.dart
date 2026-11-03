import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models.dart';
import '../../core/theme.dart';
import '../../data/order_repository.dart';
import '../auth/auth_provider.dart';
import '../customer/cart_provider.dart';
import '../customer/order_tracking_screen.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final Restaurant restaurant;
  const CheckoutScreen({super.key, required this.restaurant});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _address = TextEditingController(text: '12, MG Road, Bengaluru');
  final _instructions = TextEditingController();
  int _paymentMethod = 0; // 0 = UPI, 1 = Card, 2 = COD
  bool _placing = false;

  @override
  void dispose() {
    _address.dispose();
    _instructions.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (_address.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a delivery address')));
      return;
    }
    final cart = ref.read(cartProvider);
    if (cart.isEmpty) return;
    setState(() => _placing = true);
    final auth = ref.read(currentUserProvider)!;
    final repo = ref.read(orderRepositoryProvider);
    final order = repo.placeOrder(
      customerId: auth.id,
      customerName: auth.name,
      restaurant: widget.restaurant,
      items: cart.map((c) => CartItem(item: c.item, qty: c.qty)).toList(),
      address: _address.text.trim(),
    );
    ref.read(cartProvider.notifier).clear();
    if (!mounted) return;
    setState(() => _placing = false);
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => OrderTrackingScreen(orderId: order.id)));
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);
    const deliveryFee = 30.0;
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Delivery address
          _SectionCard(
            title: 'Delivery address',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _address,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _instructions,
                  decoration: const InputDecoration(
                    labelText: 'Delivery instructions (optional)',
                    prefixIcon: Icon(Icons.note_outlined),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Order summary
          _SectionCard(
            title: 'Order summary',
            child: Column(
              children: [
                ...cart.map((c) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text('${c.item.name} × ${c.qty}', style: const TextStyle(fontSize: 14))),
                          Text('₹${c.total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Payment method
          _SectionCard(
            title: 'Payment method',
            child: Column(
              children: [
                _PaymentOption(index: 0, selected: _paymentMethod, label: 'UPI', icon: Icons.account_balance_wallet, onTap: () => setState(() => _paymentMethod = 0)),
                _PaymentOption(index: 1, selected: _paymentMethod, label: 'Card', icon: Icons.credit_card, onTap: () => setState(() => _paymentMethod = 1)),
                _PaymentOption(index: 2, selected: _paymentMethod, label: 'Cash on delivery', icon: Icons.money, onTap: () => setState(() => _paymentMethod = 2)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Price breakdown
          _SectionCard(
            title: 'Price details',
            child: Column(
              children: [
                _PriceRow(label: 'Subtotal', value: total),
                _PriceRow(label: 'Delivery fee', value: deliveryFee),
                const Divider(height: 16),
                _PriceRow(label: 'Total', value: total + deliveryFee, bold: true),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _placing ? null : _placeOrder,
            style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryOrange),
            child: _placing
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text('Place order · ₹${(total + deliveryFee).toStringAsFixed(0)}'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

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
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final int index;
  final int selected;
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _PaymentOption({required this.index, required this.selected, required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = index == selected;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.rMd),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryOrange.withValues(alpha: 0.08) : AppTheme.background,
          borderRadius: BorderRadius.circular(AppTheme.rMd),
          border: Border.all(color: isSelected ? AppTheme.primaryOrange : AppTheme.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: isSelected ? AppTheme.primaryOrange : AppTheme.textSecondary),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(fontSize: 14, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400, color: AppTheme.textPrimary)),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_circle, size: 20, color: AppTheme.primaryOrange),
          ],
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final double value;
  final bool bold;
  const _PriceRow({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, fontWeight: bold ? FontWeight.w700 : FontWeight.w400, color: bold ? AppTheme.textPrimary : AppTheme.textSecondary)),
          Text('₹${value.toStringAsFixed(0)}', style: TextStyle(fontSize: 14, fontWeight: bold ? FontWeight.w700 : FontWeight.w400, color: bold ? AppTheme.primaryOrange : AppTheme.textPrimary)),
        ],
      ),
    );
  }
}
