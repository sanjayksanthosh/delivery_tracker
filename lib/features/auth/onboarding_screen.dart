import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../auth/auth_provider.dart';
import 'role_select_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  final _pages = const [
    ('A special dish\nprepared for you', 'Discover the best food near you, delivered fast.', '🍔'),
    ('Track your order\nin real time', 'Watch your driver move on the map, live.', '🛵'),
    ('Fresh & fast\nevery time', 'Curated restaurants, quality ingredients.', '🥗'),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _pages.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      ref.read(authProvider.notifier).start();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryYellow,
      body: SafeArea(
        child: Column(
          children: [
            // Skip
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => ref.read(authProvider.notifier).start(),
                child: const Text('Skip', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
              ),
            ),
            // Page view
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _pages.length,
                itemBuilder: (context, i) {
                  final (title, desc, emoji) = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 140)),
                        const SizedBox(height: 32),
                        Text(title, textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: AppTheme.textPrimary, height: 1.1)),
                        const SizedBox(height: 12),
                        Text(desc, textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.5)),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Page indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _page ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _page ? AppTheme.darkButton : AppTheme.textSecondary.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            // CTA
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: FilledButton(
                onPressed: _next,
                style: FilledButton.styleFrom(backgroundColor: AppTheme.darkButton),
                child: Text(_page == _pages.length - 1 ? 'Get started' : 'Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
