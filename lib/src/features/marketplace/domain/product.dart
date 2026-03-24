class Product {
  final String id;
  final String name;
  final String category;
  final String price;
  final String imageUrl;
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    this.imageUrl = '',
  });
}
