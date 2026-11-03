import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models.dart';
import '../../core/theme.dart';
import '../../data/order_repository.dart';
import 'restaurant_detail_screen.dart';

const _categories = [
  ('Burger', '🍔'),
  ('Pizza', '🍕'),
  ('Fries', '🍟'),
  ('Drinks', '🥤'),
  ('Meat', '🥩'),
  ('Desserts', '🍰'),
];

class CustomerHomeScreen extends ConsumerStatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  ConsumerState<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends ConsumerState<CustomerHomeScreen> {
  int _selectedCategory = 0;
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToRestaurants() {
    // Scroll down to restaurants section
    _scrollController.animateTo(
      600,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final restaurants = ref.watch(restaurantsProvider);
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Top nav
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(
              children: [
                _IconBtn(icon: Icons.menu, onTap: () {}),
                const Spacer(),
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(color: AppTheme.primaryOrange, borderRadius: BorderRadius.circular(8)),
                      alignment: Alignment.center,
                      child: const Text('S', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(width: 6),
                    const Text('SwiftBite', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                  ],
                ),
                const Spacer(),
                _IconBtn(icon: Icons.notifications_none, onTap: () {}),
              ],
            ),
          ),
        ),
        // Hero
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: GestureDetector(
              onTap: _scrollToRestaurants,
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: AppTheme.primaryYellow,
                  borderRadius: BorderRadius.circular(AppTheme.rXl),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      bottom: -20,
                      child: Text('🍔', style: TextStyle(fontSize: 160, color: Colors.white.withValues(alpha: 0.3))),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('A special dish\nprepared for you',
                              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.textPrimary, height: 1.1)),
                          const SizedBox(height: 8),
                          Text('Discover the best food near you',
                              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(color: AppTheme.darkButton, borderRadius: BorderRadius.circular(999)),
                            child: const Text('Order now', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Categories
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                GestureDetector(
                  onTap: () {},
                  child: Text('See all', style: TextStyle(fontSize: 13, color: AppTheme.primaryOrange, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 92,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final (name, emoji) = _categories[i];
                final selected = i == _selectedCategory;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = i),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: selected ? AppTheme.primaryOrange : AppTheme.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: selected ? AppTheme.primaryOrange : AppTheme.border),
                        ),
                        alignment: Alignment.center,
                        child: Text(emoji, style: const TextStyle(fontSize: 28)),
                      ),
                      const SizedBox(height: 6),
                      Text(name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? AppTheme.primaryOrange : AppTheme.textSecondary)),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        // Popular foods (promo cards)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Popular foods', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                GestureDetector(
                  onTap: () {},
                  child: Text('See all', style: TextStyle(fontSize: 13, color: AppTheme.primaryOrange, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 200,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final items = [
                  ('Classic Burger', '🍔', '4.8', '₹199', '25 min', 0),
                  ('Margherita', '🍕', '4.6', '₹249', '20 min', 1),
                  ('French Fries', '🍟', '4.7', '₹99', '15 min', 2),
                  ('Mango Smoothie', '🥤', '4.9', '₹129', '10 min', 3),
                ];
                final (name, emoji, rating, price, eta, restIdx) = items[i];
                return GestureDetector(
                  onTap: () {
                    final r = restaurants[restIdx % restaurants.length];
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => RestaurantDetailScreen(restaurant: r)));
                  },
                  child: Container(
                    width: 150,
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(AppTheme.rLg),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 110,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryYellow.withValues(alpha: 0.25),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.rLg)),
                          ),
                          alignment: Alignment.center,
                          child: Text(emoji, style: const TextStyle(fontSize: 52)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star, size: 12, color: Color(0xFFF4A261)),
                                  const SizedBox(width: 2),
                                  Text(rating, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                                  const Spacer(),
                                  Text(price, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.primaryOrange)),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(eta, style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        // Popular restaurants
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Popular restaurants', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                GestureDetector(
                  onTap: () {},
                  child: Text('See all', style: TextStyle(fontSize: 13, color: AppTheme.primaryOrange, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) {
              final r = restaurants[i];
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: _RestaurantCard(restaurant: r, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => RestaurantDetailScreen(restaurant: r)))),
              );
            },
            childCount: restaurants.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border),
          ),
          child: Icon(icon, size: 20, color: AppTheme.textPrimary),
        ),
      ),
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback onTap;
  const _RestaurantCard({required this.restaurant, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(AppTheme.rLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.rLg),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.rLg),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.primaryYellow.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(restaurant.emoji, style: const TextStyle(fontSize: 36)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(restaurant.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                    const SizedBox(height: 2),
                    Text(restaurant.cuisine, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 13, color: Color(0xFFF4A261)),
                        const SizedBox(width: 3),
                        Text(restaurant.rating.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 10),
                        Icon(Icons.access_time, size: 13, color: AppTheme.textSecondary),
                        const SizedBox(width: 3),
                        Text('25 min', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                        const SizedBox(width: 10),
                        Icon(Icons.delivery_dining, size: 13, color: AppTheme.textSecondary),
                        const SizedBox(width: 3),
                        Text('Free', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
