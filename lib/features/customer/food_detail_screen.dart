import 'package:flutter/material.dart';

import '../../core/models.dart';
import '../../core/theme.dart';

class FoodDetailScreen extends StatelessWidget {
  final MenuItem item;
  final String restaurantName;
  const FoodDetailScreen({super.key, required this.item, required this.restaurantName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryYellow,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  _CircleBtn(icon: Icons.arrow_back, onTap: () => Navigator.of(context).pop()),
                  const Spacer(),
                  _CircleBtn(icon: Icons.bookmark_border, onTap: () {}),
                ],
              ),
            ),
            // Hero food image
            Expanded(
              flex: 5,
              child: Center(
                child: Text(item.emoji, style: const TextStyle(fontSize: 180)),
              ),
            ),
            // White info panel
            Container(
              decoration: const BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: AppTheme.primaryYellow.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(8)),
                        child: Text(restaurantName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                      ),
                      const Spacer(),
                      const Icon(Icons.star, size: 16, color: Color(0xFFF4A261)),
                      const SizedBox(width: 4),
                      const Text('4.8', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 4),
                      Text('(120 reviews)', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(item.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.textPrimary, height: 1.1)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('₹${item.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.primaryOrange)),
                      const SizedBox(width: 16),
                      Icon(Icons.access_time, size: 14, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text('25 min', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(item.description, style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.5)),
                  const SizedBox(height: 8),
                  Text('Read more', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primaryOrange)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _QtySelector(),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {},
                          style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryOrange),
                          child: const Text('Add to cart'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.9),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(10), child: Icon(icon, size: 20, color: AppTheme.textPrimary)),
      ),
    );
  }
}

class _QtySelector extends StatefulWidget {
  @override
  State<_QtySelector> createState() => _QtySelectorState();
}

class _QtySelectorState extends State<_QtySelector> {
  int _q = 1;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(999), border: Border.all(color: AppTheme.border)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(icon: const Icon(Icons.remove, size: 18), onPressed: () => setState(() => _q = (_q > 1) ? _q - 1 : 1), visualDensity: VisualDensity.compact),
          Text('$_q', style: const TextStyle(fontWeight: FontWeight.w700)),
          IconButton(icon: const Icon(Icons.add, size: 18), onPressed: () => setState(() => _q++), visualDensity: VisualDensity.compact),
        ],
      ),
    );
  }
}
