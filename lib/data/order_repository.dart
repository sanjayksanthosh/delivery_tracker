import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../core/models.dart';

const _uuid = Uuid();

// ---------- Mock catalog ----------

class Restaurant {
  final String id;
  final String name;
  final String cuisine;
  final double rating;
  final String emoji;
  final double lat;
  final double lng;
  final List<MenuItem> menu;
  const Restaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.rating,
    required this.emoji,
    required this.lat,
    required this.lng,
    required this.menu,
  });
}

final restaurants = <Restaurant>[
  Restaurant(
    id: 'r1',
    name: 'Spice Route',
    cuisine: 'Indian · North',
    rating: 4.6,
    emoji: '🍛',
    lat: 12.9716,
    lng: 77.5946,
    menu: const [
      MenuItem(id: 'm1', name: 'Butter Chicken', description: 'Creamy tomato gravy, tender chicken', price: 280, emoji: '🍗', category: 'Mains'),
      MenuItem(id: 'm2', name: 'Garlic Naan', description: 'Fresh from the tandoor', price: 60, emoji: '🫓', category: 'Breads'),
      MenuItem(id: 'm3', name: 'Biryani', description: 'Fragrant basmati, slow-cooked', price: 240, emoji: '🍚', category: 'Mains'),
      MenuItem(id: 'm4', name: 'Mango Lassi', description: 'Chilled yogurt drink', price: 80, emoji: '🥭', category: 'Drinks'),
    ],
  ),
  Restaurant(
    id: 'r2',
    name: 'Pizza Barn',
    cuisine: 'Italian · Pizza',
    rating: 4.4,
    emoji: '🍕',
    lat: 12.9750,
    lng: 77.6000,
    menu: const [
      MenuItem(id: 'm5', name: 'Margherita', description: 'Tomato, mozzarella, basil', price: 320, emoji: '🍕', category: 'Pizza'),
      MenuItem(id: 'm6', name: 'Pepperoni', description: 'Loaded pepperoni', price: 390, emoji: '🍕', category: 'Pizza'),
      MenuItem(id: 'm7', name: 'Garlic Bread', description: 'Cheesy garlic bread', price: 120, emoji: '🍞', category: 'Sides'),
      MenuItem(id: 'm8', name: 'Coke', description: 'Chilled 330ml', price: 60, emoji: '🥤', category: 'Drinks'),
    ],
  ),
  Restaurant(
    id: 'r3',
    name: 'Sushi Zen',
    cuisine: 'Japanese',
    rating: 4.8,
    emoji: '🍣',
    lat: 12.9680,
    lng: 77.5900,
    menu: const [
      MenuItem(id: 'm9', name: 'Salmon Roll', description: '8 pieces, fresh salmon', price: 420, emoji: '🍣', category: 'Rolls'),
      MenuItem(id: 'm10', name: 'Miso Soup', description: 'Traditional miso', price: 120, emoji: '🥣', category: 'Soups'),
      MenuItem(id: 'm11', name: 'Edamame', description: 'Salted soybeans', price: 150, emoji: '🫛', category: 'Sides'),
      MenuItem(id: 'm12', name: 'Green Tea', description: 'Hot or iced', price: 70, emoji: '🍵', category: 'Drinks'),
    ],
  ),
];

final drivers = <Driver>[
  const Driver(id: 'd1', name: 'Ravi Kumar', vehicle: 'Honda Activa · KA-01 AB 1234', rating: 4.9, lat: 12.9700, lng: 77.5920),
  const Driver(id: 'd2', name: 'Priya Sharma', vehicle: 'TVS Jupiter · KA-05 CD 5678', rating: 4.7, lat: 12.9730, lng: 77.5970),
];

// ---------- Order repository ----------

class OrderRepository {
  OrderRepository._();
  static final OrderRepository instance = OrderRepository._();

  final List<Order> _orders = [];
  final _controller = StreamController<List<Order>>.broadcast();
  Timer? _statusTimer;
  Timer? _moveTimer;

  Stream<List<Order>> get ordersStream => _controller.stream;
  List<Order> get orders => List.unmodifiable(_orders);

  void _emit() => _controller.add(List.unmodifiable(_orders));

  Order placeOrder({
    required String customerId,
    required String customerName,
    required Restaurant restaurant,
    required List<CartItem> items,
    required String address,
  }) {
    final total = items.fold<double>(0, (s, c) => s + c.total);
    final order = Order(
      id: _uuid.v4().substring(0, 8).toUpperCase(),
      customerId: customerId,
      customerName: customerName,
      restaurant: restaurant.name,
      items: items,
      total: total,
      address: address,
      customerLat: 12.9780,
      customerLng: 77.6020,
      restaurantLat: restaurant.lat,
      restaurantLng: restaurant.lng,
      driverLat: restaurant.lat,
      driverLng: restaurant.lng,
    );
    _orders.insert(0, order);
    _emit();
    _runLifecycle(order);
    return order;
  }

  void _runLifecycle(Order order) {
    // Status progression: placed -> preparing (2s) -> outForDelivery (5s) -> auto-deliver (16s)
    int elapsed = 0;
    _statusTimer?.cancel();
    _statusTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (order.status.isTerminal) {
        t.cancel();
        _moveTimer?.cancel();
        return;
      }
      elapsed++;
      if (elapsed == 2 && order.status == OrderStatus.placed) {
        order.status = OrderStatus.preparing;
        _emit();
      } else if (elapsed == 5 && order.status == OrderStatus.preparing) {
        order.status = OrderStatus.outForDelivery;
        order.driverLat = order.restaurantLat;
        order.driverLng = order.restaurantLng;
        _emit();
        _startMovement(order);
      } else if (elapsed >= 16 && order.status == OrderStatus.outForDelivery) {
        order.status = OrderStatus.delivered;
        order.driverLat = order.customerLat;
        order.driverLng = order.customerLng;
        _emit();
        t.cancel();
        _moveTimer?.cancel();
      }
    });
  }

  void _startMovement(Order order) {
    _moveTimer?.cancel();
    const steps = 60; // ~12s at 200ms
    int i = 0;
    _moveTimer = Timer.periodic(const Duration(milliseconds: 200), (t) {
      if (order.status != OrderStatus.outForDelivery) {
        t.cancel();
        return;
      }
      i++;
      final frac = (i / steps).clamp(0.0, 1.0);
      order.driverLat = order.restaurantLat + (order.customerLat - order.restaurantLat) * frac;
      order.driverLng = order.restaurantLng + (order.customerLng - order.restaurantLng) * frac;
      _emit();
      if (i >= steps) t.cancel();
    });
  }

  void acceptOrder(String orderId, Driver driver) {
    final o = _orders.firstWhere((e) => e.id == orderId);
    if (o.status == OrderStatus.placed) o.status = OrderStatus.preparing;
    _emit();
  }

  void advanceStatus(String orderId) {
    final o = _orders.firstWhere((e) => e.id == orderId);
    if (o.status == OrderStatus.placed) {
      o.status = OrderStatus.preparing;
    } else if (o.status == OrderStatus.preparing) {
      o.status = OrderStatus.outForDelivery;
      o.driverLat = o.restaurantLat;
      o.driverLng = o.restaurantLng;
      _startMovement(o);
    } else if (o.status == OrderStatus.outForDelivery) {
      o.status = OrderStatus.delivered;
      o.driverLat = o.customerLat;
      o.driverLng = o.customerLng;
      _moveTimer?.cancel();
    }
    _emit();
  }

  List<Order> ordersForCustomer(String customerId) =>
      _orders.where((o) => o.customerId == customerId).toList();

  List<Order> availableForDriver() =>
      _orders.where((o) => o.status == OrderStatus.placed || o.status == OrderStatus.preparing).toList();

  List<Order> activeForDriver() =>
      _orders.where((o) => o.status == OrderStatus.outForDelivery).toList();
}

final orderRepositoryProvider = Provider<OrderRepository>((_) => OrderRepository.instance);

final restaurantsProvider = Provider<List<Restaurant>>((_) => restaurants);
final driversProvider = Provider<List<Driver>>((_) => drivers);
