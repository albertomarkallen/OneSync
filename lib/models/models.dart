import 'package:cloud_firestore/cloud_firestore.dart';

class MenuItem {
  final String name;
  final double price;
  final int stock;
  final String imageUrl; // Renamed to imageUrl to reflect that it's a URL
  final String category;

  MenuItem(
      {required this.name,
      required this.price,
      required this.stock,
      this.imageUrl =
          'https://via.placeholder.com/150', // Default to a web placeholder
      required this.category});

  factory MenuItem.snapshot(DocumentSnapshot snapshot) {
    var data = snapshot.data() as Map<String, dynamic>;
    return MenuItem(
        name: data['name'] ?? '',
        price: (data['price'] as num).toDouble(),
        stock: data['stock'] as int,
        imageUrl: data['imageUrl'] ??
            'https://via.placeholder.com/150', // Use an online placeholder if imageUrl is missing
        category: data['category'] ?? '');
  }
}
