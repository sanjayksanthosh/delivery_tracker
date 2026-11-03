enum OrderStatus { placed, preparing, outForDelivery, delivered, cancelled }

extension OrderStatusX on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.placed:
        return 'Order placed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.outForDelivery:
        return 'Out for delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  int get step {
    switch (this) {
      case OrderStatus.placed:
        return 0;
      case OrderStatus.preparing:
        return 1;
      case OrderStatus.outForDelivery:
        return 2;
      case OrderStatus.delivered:
        return 3;
      case OrderStatus.cancelled:
        return -1;
    }
  }

  bool get isTerminal =>
      this == OrderStatus.delivered || this == OrderStatus.cancelled;
}

class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String emoji;
  final String category;

  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.emoji,
    required this.category,
  });
}

class CartItem {
  final MenuItem item;
  int qty;
  CartItem({required this.item, this.qty = 1});

  double get total => item.price * qty;
}

class Order {
  final String id;
  final String customerId;
  final String customerName;
  final String restaurant;
  final List<CartItem> items;
  final double total;
  final String address;
  final double customerLat;
  final double customerLng;
  final double restaurantLat;
  final double restaurantLng;
  double driverLat;
  double driverLng;
  OrderStatus status;
  final DateTime createdAt;
  final String? driverId;
  final String? driverName;

  Order({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.restaurant,
    required this.items,
    required this.total,
    required this.address,
    required this.customerLat,
    required this.customerLng,
    required this.restaurantLat,
    required this.restaurantLng,
    this.driverLat = 0,
    this.driverLng = 0,
    this.status = OrderStatus.placed,
    DateTime? createdAt,
    this.driverId,
    this.driverName,
  }) : createdAt = createdAt ?? DateTime.now();

  int get itemCount => items.fold(0, (s, c) => s + c.qty);
}

class Driver {
  final String id;
  final String name;
  final String vehicle;
  final double rating;
  final double lat;
  final double lng;

  const Driver({
    required this.id,
    required this.name,
    required this.vehicle,
    required this.rating,
    required this.lat,
    required this.lng,
  });
}
