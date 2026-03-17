// lib/models/sale_model.dart
class SaleModel {
  final String id;
  final String customerName;
  final double totalAmount;
  final DateTime date;
  final String status;
  final List<SaleItem> items;

  SaleModel({
    required this.id,
    required this.customerName,
    required this.totalAmount,
    required this.date,
    required this.status,
    required this.items,
  });

  String get formattedDate {
    return '${date.day}/${date.month}/${date.year}';
  }

  String get formattedDateTime {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  int get itemCount => items.length;

  // Convert to JSON for API calls
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerName': customerName,
      'totalAmount': totalAmount,
      'date': date.toIso8601String(),
      'status': status,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  // Create from JSON
  factory SaleModel.fromJson(Map<String, dynamic> json) {
    return SaleModel(
      id: json['id'],
      customerName: json['customerName'],
      totalAmount: json['totalAmount'].toDouble(),
      date: DateTime.parse(json['date']),
      status: json['status'],
      items: (json['items'] as List)
          .map((itemJson) => SaleItem.fromJson(itemJson))
          .toList(),
    );
  }
}

class SaleItem {
  final String name;
  final int quantity;
  final double price;

  SaleItem({
    required this.name,
    required this.quantity,
    required this.price,
  });

  double get total => quantity * price;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'price': price,
    };
  }

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      name: json['name'],
      quantity: json['quantity'],
      price: json['price'].toDouble(),
    );
  }
}
