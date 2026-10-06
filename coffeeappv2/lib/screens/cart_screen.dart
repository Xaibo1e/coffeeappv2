import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_item_tile.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  // plan.md ข้อ 38: Cart -> Confirm -> Dialog -> Order Successful -> Clear Cart -> Home
  // ยังไม่มี Order API ใน MVP นี้จึงเป็นการจำลอง (ดู backendapi.md ข้อ 2 "ไม่มี Order API")
  Future<void> _confirmOrder(BuildContext context, int total) async {
    final cart = context.read<CartProvider>();

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Order Confirmed'),
        content: Text('Total: ฿$total\n\nThank you for your order.'),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    cart.clearCart();

    if (context.mounted) {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final items = cart.items.values.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: items.isEmpty
          ? const Center(child: Text('Your cart is empty'))
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) =>
                  CartItemTile(cartItem: items[index]),
            ),
      bottomNavigationBar: items.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Items: ${cart.totalItems}'),
                        Text(
                          'Total: ฿${cart.totalPrice}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => _confirmOrder(context, cart.totalPrice),
                        child: const Text('Confirm Order'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}