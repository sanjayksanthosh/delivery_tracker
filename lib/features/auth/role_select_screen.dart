import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../auth/auth_provider.dart';
import 'login_screen.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryYellow,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              // Logo
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.darkButton,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Text('S', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 10),
                  const Text('SwiftBite', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                ],
              ),
              const SizedBox(height: 40),
              Text('A special dish\nprepared for you',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 44,
                        height: 1.05,
                        color: AppTheme.textPrimary,
                      )),
              const SizedBox(height: 12),
              Text('Real-time food delivery with live tracking. Order, track, enjoy.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary)),
              const Spacer(),
              _RoleCard(
                icon: Icons.shopping_bag_outlined,
                title: 'Customer',
                subtitle: 'Order food and track your delivery live.',
                color: AppTheme.primaryOrange,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const LoginScreen(role: Role.customer))),
              ),
              const SizedBox(height: 12),
              _RoleCard(
                icon: Icons.delivery_dining_outlined,
                title: 'Delivery Partner',
                subtitle: 'Pick up orders and deliver them.',
                color: AppTheme.freshGreen,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const LoginScreen(role: Role.driver))),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const LoginScreen(role: Role.customer))),
                style: FilledButton.styleFrom(backgroundColor: AppTheme.darkButton),
                child: const Text('Start with email or phone'),
              ),
              const SizedBox(height: 12),
              Text('Demo mode — any name works, password optional.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _RoleCard({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(AppTheme.rLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.rLg),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.rLg),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
