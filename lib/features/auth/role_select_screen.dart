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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Text('SwiftBite',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                        letterSpacing: -1,
                      )),
              const SizedBox(height: 8),
              Text('Real-time food delivery, tracked live.',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.muted)),
              const SizedBox(height: 48),
              Text('I am a…',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              _RoleCard(
                icon: Icons.shopping_bag_outlined,
                title: 'Customer',
                subtitle: 'Order food and track your delivery live.',
                color: AppTheme.primary,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const LoginScreen(role: Role.customer))),
              ),
              const SizedBox(height: 16),
              _RoleCard(
                icon: Icons.delivery_dining_outlined,
                title: 'Driver',
                subtitle: 'Pick up orders and deliver them.',
                color: AppTheme.success,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const LoginScreen(role: Role.driver))),
              ),
              const Spacer(),
              Text('Demo mode — any name works, password optional.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.muted)),
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
      color: AppTheme.card,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(fontSize: 13, color: AppTheme.muted)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppTheme.muted),
            ],
          ),
        ),
      ),
    );
  }
}
