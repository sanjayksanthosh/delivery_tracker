import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void add(MenuItem item) {
    final existing = state.where((c) => c.item.id == item.id).firstOrNull;
    if (existing != null) {
      existing.qty += 1;
      state = [...state];
    } else {
      state = [...state, CartItem(item: item)];
    }
  }

  void remove(String itemId) {
    state = state.where((c) => c.item.id != itemId).toList();
  }

  void setQty(String itemId, int qty) {
    if (qty <= 0) {
      remove(itemId);
      return;
    }
    state = state.map((c) {
      if (c.item.id == itemId) c.qty = qty;
      return c;
    }).toList();
  }

  void clear() => state = [];
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((_) => CartNotifier());

final cartTotalProvider = Provider<double>((ref) {
  return ref.watch(cartProvider).fold(0.0, (s, c) => s + c.total);
});

final cartCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).fold(0, (s, c) => s + c.qty);
});
