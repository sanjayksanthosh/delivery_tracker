import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../auth/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final name = user?.name ?? 'Guest';
    final email = '${name.toLowerCase().replaceAll(' ', '')}@swiftbite.app';
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.rLg),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryYellow,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(email, style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () {}),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _MenuSection(title: 'Account', items: [
            _MenuItem(icon: Icons.location_on_outlined, label: 'Saved addresses', onTap: () {}),
            _MenuItem(icon: Icons.receipt_long_outlined, label: 'My orders', onTap: () {}),
            _MenuItem(icon: Icons.favorite_border, label: 'Favorites', onTap: () {}),
            _MenuItem(icon: Icons.payment_outlined, label: 'Payment methods', onTap: () {}),
          ]),
          const SizedBox(height: 16),
          _MenuSection(title: 'Support', items: [
            _MenuItem(icon: Icons.help_outline, label: 'Help & support', onTap: () {}),
            _MenuItem(icon: Icons.info_outline, label: 'About SwiftBite', onTap: () {}),
            _MenuItem(icon: Icons.star_outline, label: 'Rate the app', onTap: () {}),
          ]),
          const SizedBox(height: 16),
          _MenuSection(title: 'Account actions', items: [
            _MenuItem(icon: Icons.logout, label: 'Log out', onTap: () => ref.read(authProvider.notifier).logout(), color: AppTheme.danger),
          ]),
        ],
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;
  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.rLg),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                items[i],
                if (i < items.length - 1) const Divider(height: 1, indent: 52),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _MenuItem({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.textPrimary;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: c),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: c))),
            Icon(Icons.chevron_right, size: 20, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}
