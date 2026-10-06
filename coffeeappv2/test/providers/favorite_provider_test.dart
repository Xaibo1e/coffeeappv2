import 'package:flutter_test/flutter_test.dart';
import 'package:coffeeappv2/models/product.dart';
import 'package:coffeeappv2/providers/favorite_provider.dart';

// Challenge 1 (plan.md ข้อ 57 / planV2.md ข้อ 59): Favorite
Product _product({int id = 1, String name = 'Americano'}) {
  return Product(id: id, name: name, stock: 20, price: 55, categoryId: 1);
}

void main() {
  group('FavoriteProvider', () {
    late FavoriteProvider favorites;

    setUp(() {
      favorites = FavoriteProvider();
    });

    test('a product starts out not favorited', () {
      expect(favorites.isFavorite(1), isFalse);
    });

    test('toggleFavorite adds a product to favorites', () {
      favorites.toggleFavorite(_product());

      expect(favorites.isFavorite(1), isTrue);
      expect(favorites.favorites, hasLength(1));
    });

    test('toggleFavorite twice removes it again', () {
      final product = _product();
      favorites.toggleFavorite(product);
      favorites.toggleFavorite(product);

      expect(favorites.isFavorite(1), isFalse);
      expect(favorites.favorites, isEmpty);
    });

    test('tracks multiple distinct products independently', () {
      favorites.toggleFavorite(_product(id: 1, name: 'Americano'));
      favorites.toggleFavorite(_product(id: 2, name: 'Cappuccino'));

      expect(favorites.favorites, hasLength(2));
      expect(favorites.isFavorite(1), isTrue);
      expect(favorites.isFavorite(2), isTrue);

      favorites.toggleFavorite(_product(id: 1, name: 'Americano'));

      expect(favorites.isFavorite(1), isFalse);
      expect(favorites.isFavorite(2), isTrue);
      expect(favorites.favorites, hasLength(1));
    });

    test('notifies listeners on toggle', () {
      var notified = false;
      favorites.addListener(() => notified = true);

      favorites.toggleFavorite(_product());

      expect(notified, isTrue);
    });
  });
}