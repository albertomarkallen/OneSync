import 'package:cloud_firestore/cloud_firestore.dart';

/// A class representing a menu item with details fetched from Firestore.
class MenuItem {
  String name;
  int price;
  int stock;
  String imageUrl;
  String category;

  /// Constructs a [MenuItem] with required fields and an optional image URL.
  MenuItem({
    required this.name,
    required this.price,
    required this.stock,
    required this.imageUrl,
    required this.category,
  });

  /// Creates an instance of [MenuItem] from a Firestore [DocumentSnapshot].
  /// Fields are parsed and validated with fallbacks for missing data.
  factory MenuItem.fromSnapshot(DocumentSnapshot snapshot) {
    var data = snapshot.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception("Snapshot data is null");
    }

    return MenuItem(
      name: data['name'] ?? 'No name provided',
      price: data['price'] != null ? (data['price'] as num).toInt() : 0,
      stock: data['stock'] != null ? (data['stock'] as num).toInt() : 0,
      imageUrl: data['imageUrl'] ?? 'https://via.placeholder.com/150',
      category: data['category'] ?? 'No category',
    );
  }

  /// Updates the stock quantity of the menu item.
  set updateStock(int newStock) {
    if (newStock < 0) {
      throw Exception("Stock cannot be negative");
    }
    stock = newStock;
  }
}
