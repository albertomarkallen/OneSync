import 'package:cloud_firestore/cloud_firestore.dart';

class MenuItem {
  String name;
  int price;
  int stock;
  String imageUrl;
  String category;

  MenuItem(
      {required this.name,
      required this.price,
      required this.stock,
      this.imageUrl = 'https://via.placeholder.com/150',
      required this.category});

  factory MenuItem.snapshot(DocumentSnapshot snapshot) {
    var data = snapshot.data() as Map<String, dynamic>;
    return MenuItem(
        name: data['name'] ?? '',
        price: (data['price'] as num).toInt(),
        stock: data['stock'] as int,
        imageUrl: data['imageUrl'] ?? 'https://via.placeholder.com/150',
        category: data['category'] ?? '');
  }

  // Setter for stock
  set updateStock(int newStock) {
    stock = newStock;
  }
}
