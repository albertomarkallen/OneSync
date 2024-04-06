// models.dart
class MenuItem {
  final String name;
  final double price;
  final int stock;
  final String imagePath;
  final String category;

  MenuItem(
      {required this.name,
      required this.price,
      required this.stock,
      this.imagePath = 'assets/images/placeholder.png',
      required this.category});

  static List<String> getUniqueCategories(List<MenuItem> items) {
    final categoriesSet = Set<String>();
    items.forEach((item) {
      if (item.category != null) categoriesSet.add(item.category!);
    });
    return categoriesSet.toList();
  }
}
