class Order {
  final int id;
  final double totalAmount;
  final String paymentMethod;
  final String customerName;
  final String customerAddress;
  final String orderStatus;
  final DateTime? createdAt;
  final List<OrderItem> orderItems;
  final double? rating; // Rating from customer
  final bool? isReadByAdmin; // For admin toast trigger

  Order({
    required this.id,
    required this.totalAmount,
    required this.paymentMethod,
    required this.customerName,
    required this.customerAddress,
    required this.orderStatus,
    this.createdAt,
    required this.orderItems,
    this.rating,
    this.isReadByAdmin,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? 0,
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? '',
      customerName: json['customerName'] ?? '',
      customerAddress: json['customerAddress'] ?? '',
      orderStatus: json['orderStatus'] ?? (json['status'] ?? ''),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : (json['orderDate'] != null ? DateTime.tryParse(json['orderDate']) : null),
      orderItems: (json['orderItems'] as List? ?? [])
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      isReadByAdmin: json['isReadByAdmin'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'customerName': customerName,
      'customerAddress': customerAddress,
      'orderStatus': orderStatus,
      'createdAt': createdAt?.toIso8601String(),
      'orderItems': orderItems.map((e) => e.toJson()).toList(),
      'rating': rating,
      'isReadByAdmin': isReadByAdmin,
    };
  }
}

class OrderItem {
  final int quantity;
  final MenuItem menuItem;

  OrderItem({required this.quantity, required this.menuItem});

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      quantity: json['quantity'] ?? 0,
      menuItem: MenuItem.fromJson(json['menuItem'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quantity': quantity,
      'menuItem': menuItem.toJson(),
    };
  }
}

class MenuItem {
  final int id;
  final String name;
  final double price;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
    };
  }
}
