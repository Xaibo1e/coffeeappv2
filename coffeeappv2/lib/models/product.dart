class Product {
  final int id;
  final String name;
  final String? description;
  final String? image;
  final int stock;
  final int price;
  final int categoryId;

  Product({
    required this.id,
    required this.name,
    this.description,
    this.image,
    required this.stock,
    required this.price,
    required this.categoryId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: _toInt(json['id']),
      name: json['name'] ?? '',
      description: json['description'],
      image: json['image'],
      stock: _toInt(json['stock']),
      price: _toInt(json['price']),
      categoryId: _toInt(json['category_id']),
    );
  }

  // backend คืนตัวเลขเป็น int ปกติตอน GET แต่คืนเป็น String ตอน POST/PUT
  // (เพราะรับค่าจาก multipart/form-data) — parse ให้ทนทั้งสองแบบ
  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.parse(value.toString());
  }
}