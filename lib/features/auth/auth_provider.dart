import 'package:flutter_riverpod/flutter_riverpod.dart';

enum Role { customer, driver }

class AppUser {
  final String id;
  final String name;
  final Role role;
  const AppUser({required this.id, required this.name, required this.role});
}

class AuthState {
  final AppUser? user;
  final bool loading;
  const AuthState({this.user, this.loading = false});
  bool get isLoggedIn => user != null;
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  Future<bool> login(String name, Role role) async {
    if (name.trim().isEmpty) return false;
    state = AuthState(loading: true);
    await Future.delayed(const Duration(milliseconds: 400));
    final id = role == Role.customer ? 'cust_${name.hashCode}' : 'drv_${name.hashCode}';
    state = AuthState(user: AppUser(id: id, name: name.trim(), role: role));
    return true;
  }

  void logout() => state = const AuthState();
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((_) => AuthNotifier());
final currentUserProvider = Provider<AppUser?>((ref) => ref.watch(authProvider).user);
final currentRoleProvider = Provider<Role?>((ref) => ref.watch(authProvider).user?.role);
