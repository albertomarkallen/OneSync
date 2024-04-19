// models.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class MenuItem {
  final String name;
  final int price;
  final int stock;
  final String imagePath;
  final String category;

  MenuItem(
      {required this.name,
      required this.price,
      required this.stock,
      this.imagePath = 'assets/images/placeholder.png',
      required this.category});

  factory MenuItem.snapshot(DocumentSnapshot snapshot) {
    var data = snapshot.data() as Map<String, dynamic>;
    return MenuItem(
        name: data['name'] ?? '',
        price: (data['price'] as num).toInt(),
        stock: data['stock'] as int,
        imagePath: data['imagePath'] ??
            'assets/images/placeholder.png', // Future implementation
        category: data['category'] ?? '');
  }
}
