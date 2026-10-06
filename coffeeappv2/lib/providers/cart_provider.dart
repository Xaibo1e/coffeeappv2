import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  final Map<int, CartItem> _items = {};

  Map<int, CartItem> get items => _items;

  int get totalItems =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  int get totalPrice =>
      _items.values.fold(0, (sum, item) => sum + item.subtotal);

  // Challenge 3 (plan.md ข้อ 57 / planV2.md ข้อ 59): ห้ามเพิ่มสินค้าเกิน product.stock
  // คืนค่า false เมื่อชนขีดจำกัด เพื่อให้ UI แสดงข้อความแจ้งผู้ใช้ได้
  bool addItem(Product product) {
    final existing = _items[product.id];

    if (existing != null) {
      if (existing.quantity >= product.stock) return false;
      existing.quantity++;
    } else {
      if (product.stock <= 0) return false;
      _items[product.id] = CartItem(product: product);
    }

    notifyListeners();
    return true;
  }

  bool increaseQuantity(int productId) {
    final item = _items[productId];
    if (item == null) return false;
    if (item.quantity >= item.product.stock) return false;

    item.quantity++;
    notifyListeners();
    return true;
  }

  void decreaseQuantity(int productId) {
    if (!_items.containsKey(productId)) return;

    _items[productId]!.quantity--;

    if (_items[productId]!.quantity <= 0) {
      _items.remove(productId);
    }

    notifyListeners();
  }

  void removeItem(int productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}