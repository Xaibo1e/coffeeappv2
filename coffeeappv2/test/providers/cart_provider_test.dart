import 'package:flutter_test/flutter_test.dart';
import 'package:coffeeappv2/models/product.dart';
import 'package:coffeeappv2/providers/cart_provider.dart';

// planV2.md ข้อ 57 Session 6: Integration Test — ครอบคลุม Cart Test Cases จาก
// plan.md ข้อ 60 (Add Product, Add Product ซ้ำ, Increase, Decrease, Remove,
// Total Items, Total Price, Clear Cart) และ Quantity = 0 จาก Session 6 Test Cases
Product _product({
  int id = 1,
  String name = 'Americano',
  int price = 55,
  int stock = 20,
}) {
  return Product(
    id: id,
    name: name,
    stock: stock,
    price: price,
    categoryId: 1,
  );
}

void main() {
  group('CartProvider', () {
    late CartProvider cart;

    setUp(() {
      cart = CartProvider();
    });

    test('addItem adds a new product with quantity 1', () {
      cart.addItem(_product());

      expect(cart.items.length, 1);
      expect(cart.items[1]!.quantity, 1);
    });

    test('addItem on an existing product increases quantity instead of duplicating', () {
      final product = _product();
      cart.addItem(product);
      cart.addItem(product);

      expect(cart.items.length, 1);
      expect(cart.items[1]!.quantity, 2);
    });

    test('increaseQuantity increments quantity', () {
      cart.addItem(_product());
      cart.increaseQuantity(1);

      expect(cart.items[1]!.quantity, 2);
    });

    test('decreaseQuantity decrements quantity', () {
      cart.addItem(_product());
      cart.increaseQuantity(1);
      cart.decreaseQuantity(1);

      expect(cart.items[1]!.quantity, 1);
    });

    test('decreaseQuantity removes the item once quantity reaches 0', () {
      cart.addItem(_product());
      cart.decreaseQuantity(1);

      expect(cart.items.containsKey(1), isFalse);
    });

    test('removeItem removes the product regardless of its quantity', () {
      final product = _product();
      cart.addItem(product);
      cart.addItem(product);
      cart.removeItem(1);

      expect(cart.items.containsKey(1), isFalse);
    });

    test('totalItems sums quantities across every product', () {
      cart.addItem(_product(id: 1, price: 55));
      cart.addItem(_product(id: 2, price: 65));
      cart.increaseQuantity(1);

      expect(cart.totalItems, 3);
    });

    test('totalPrice sums subtotal (price x quantity) across every product', () {
      cart.addItem(_product(id: 1, price: 55));
      cart.increaseQuantity(1);
      cart.addItem(_product(id: 2, price: 65));

      expect(cart.totalPrice, 175);
    });

    test('clearCart empties the cart', () {
      cart.addItem(_product());
      cart.clearCart();

      expect(cart.items, isEmpty);
      expect(cart.totalItems, 0);
      expect(cart.totalPrice, 0);
    });

    test('notifies listeners when the cart changes', () {
      var notified = false;
      cart.addListener(() => notified = true);

      cart.addItem(_product());

      expect(notified, isTrue);
    });

    // Challenge 3 (plan.md ข้อ 57 / planV2.md ข้อ 59): Product Stock Validation
    group('stock validation', () {
      test('addItem returns true and succeeds while under stock', () {
        final result = cart.addItem(_product(stock: 2));
        expect(result, isTrue);
        expect(cart.items[1]!.quantity, 1);
      });

      test('addItem returns false and stops once quantity reaches stock', () {
        final product = _product(stock: 2);
        cart.addItem(product); // qty 1
        cart.addItem(product); // qty 2 (at cap)
        final result = cart.addItem(product); // should be rejected

        expect(result, isFalse);
        expect(cart.items[1]!.quantity, 2);
      });

      test('addItem rejects a product with zero stock outright', () {
        final result = cart.addItem(_product(stock: 0));

        expect(result, isFalse);
        expect(cart.items.containsKey(1), isFalse);
      });

      test('increaseQuantity returns false and stops once quantity reaches stock', () {
        cart.addItem(_product(stock: 2));
        cart.increaseQuantity(1); // qty 2 (at cap)
        final result = cart.increaseQuantity(1); // should be rejected

        expect(result, isFalse);
        expect(cart.items[1]!.quantity, 2);
      });
    });
  });
}