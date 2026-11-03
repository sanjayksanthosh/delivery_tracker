import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/theme.dart';
import 'features/auth/auth_provider.dart';
import 'features/auth/onboarding_screen.dart';
import 'features/auth/role_select_screen.dart';
import 'features/customer/customer_shell.dart';
import 'features/driver/driver_shell.dart';

void main() {
  runApp(const ProviderScope(child: DeliveryApp()));
}

class DeliveryApp extends ConsumerWidget {
  const DeliveryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    Widget home;
    if (!auth.isLoggedIn) {
      home = const OnboardingScreen();
    } else if (auth.user!.role == Role.customer) {
      home = const CustomerShell();
    } else {
      home = const DriverShell();
    }
    return MaterialApp(
      title: 'SwiftBite',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light().copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(AppTheme.light().textTheme),
      ),
      home: home,
    );
  }
}
