class Crop {
  final String id;
  final String name;
  final String price;
  final String category;
  final String imageUrl;

  Crop({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    this.imageUrl = '',
  });

  factory Crop.fromMap(Map<String, dynamic> map) {
    return Crop(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: map['price'] ?? '',
      category: map['category'] ?? 'Grains',
    );
  }
}
