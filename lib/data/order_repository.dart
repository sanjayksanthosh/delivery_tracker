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
  Timer? _simTimer;

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
    _startSimulation(order);
    return order;
  }

  void _startSimulation(Order order) {
    _simTimer?.cancel();
    int tick = 0;
    _simTimer = Timer.periodic(const Duration(seconds: 4), (t) {
      tick++;
      if (order.status.isTerminal) {
        t.cancel();
        return;
      }
      // advance status
      if (tick == 2 && order.status == OrderStatus.placed) {
        order.status = OrderStatus.preparing;
      } else if (tick == 4 && order.status == OrderStatus.preparing) {
        order.status = OrderStatus.outForDelivery;
        // assign driver
        order.driverLat = drivers[0].lat;
        order.driverLng = drivers[0].lng;
      } else if (tick >= 9 && order.status == OrderStatus.outForDelivery) {
        order.status = OrderStatus.delivered;
        t.cancel();
      }
      // move driver toward customer while out for delivery
      if (order.status == OrderStatus.outForDelivery) {
        final frac = (tick - 4) / 5.0;
        final f = frac.clamp(0.0, 1.0);
        order.driverLat = order.restaurantLat + (order.customerLat - order.restaurantLat) * f;
        order.driverLng = order.restaurantLng + (order.customerLng - order.restaurantLng) * f;
      }
      _emit();
    });
  }

  void acceptOrder(String orderId, Driver driver) {
    final o = _orders.firstWhere((e) => e.id == orderId);
    o.status = OrderStatus.outForDelivery;
    o.driverLat = driver.lat;
    o.driverLng = driver.lng;
    _emit();
  }

  void advanceStatus(String orderId) {
    final o = _orders.firstWhere((e) => e.id == orderId);
    if (o.status == OrderStatus.placed) {
      o.status = OrderStatus.preparing;
    } else if (o.status == OrderStatus.preparing) {
      o.status = OrderStatus.outForDelivery;
    } else if (o.status == OrderStatus.outForDelivery) {
      o.status = OrderStatus.delivered;
    }
    _emit();
  }

  List<Order> ordersForCustomer(String customerId) =>
      _orders.where((o) => o.customerId == customerId).toList();

  List<Order> availableForDriver() =>
      _orders.where((o) => o.status == OrderStatus.placed || o.status == OrderStatus.preparing).toList();

  List<Order> activeForDriver(String driverId) =>
      _orders.where((o) => o.status == OrderStatus.outForDelivery).toList();
}

final orderRepositoryProvider = Provider<OrderRepository>((_) => OrderRepository.instance);

final restaurantsProvider = Provider<List<Restaurant>>((_) => restaurants);
final driversProvider = Provider<List<Driver>>((_) => drivers);
