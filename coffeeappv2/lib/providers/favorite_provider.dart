import 'package:flutter/foundation.dart';
import '../models/product.dart';

// Challenge 1 (plan.md ข้อ 57 / planV2.md ข้อ 59): Favorite
// เก็บในหน่วยความจำเท่านั้น ไม่ persist — เหตุผลเดียวกับที่ CartProvider ไม่เก็บ Cart ลง
// Backend สำหรับ MVP (ดู plan.md ข้อ 66 ข้อ 12): ยังไม่มี Favorite API ใน backend จริง
class FavoriteProvider extends ChangeNotifier {
  final Map<int, Product> _favorites = {};

  List<Product> get favorites => _favorites.values.toList();

  bool isFavorite(int productId) => _favorites.containsKey(productId);

  void toggleFavorite(Product product) {
    if (_favorites.containsKey(product.id)) {
      _favorites.remove(product.id);
    } else {
      _favorites[product.id] = product;
    }
    notifyListeners();
  }
}