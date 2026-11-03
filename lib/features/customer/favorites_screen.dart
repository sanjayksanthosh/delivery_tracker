import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = [
      ('Classic Burger', '🍔', 'Burger Hub', '₹199', '4.8'),
      ('Margherita', '🍕', 'Pizza Barn', '₹249', '4.6'),
      ('Mango Smoothie', '🥤', 'Juice Bar', '₹129', '4.9'),
      ('French Fries', '🍟', 'Snack Shack', '₹99', '4.7'),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: AppTheme.muted),
                  const SizedBox(height: 12),
                  Text('No favorites yet', style: TextStyle(color: AppTheme.muted, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('Tap the heart on any food to save it here.', style: TextStyle(color: AppTheme.muted, fontSize: 13)),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: favorites.length,
              itemBuilder: (context, i) {
                final (name, emoji, restaurant, price, rating) = favorites[i];
                return Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.rLg),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.primaryYellow.withValues(alpha: 0.25),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.rLg)),
                          ),
                          alignment: Alignment.center,
                          child: Text(emoji, style: const TextStyle(fontSize: 48)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text(restaurant, style: TextStyle(fontSize: 11, color: AppTheme.muted)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star, size: 11, color: Color(0xFFF4A261)),
                                const SizedBox(width: 2),
                                Text(rating, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                                const Spacer(),
                                Text(price, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.primaryOrange)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
