import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../config/api_config.dart';
import '../models/product.dart';

class ProductService {
  Future<List<Product>> getProducts(String token) async {
    final response = await http.get(
      Uri.parse(ApiConfig.products),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Cannot load products');
    }

    final data = jsonDecode(response.body);

    // backend คืน Array ตรงๆ ไม่ห่อด้วย { products: [...] } (ดู backendapi.md ข้อ 2)
    final List list = data is List ? data : (data['products'] as List);

    return list
        .map((json) => Product.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Product> getProductById(String token, int id) async {
    final response = await http.get(
      Uri.parse(ApiConfig.productById(id)),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Cannot load product');
    }

    final data = jsonDecode(response.body);

    // ⚠️ backend คืน Array เสมอแม้ query ด้วย id เดียว (พฤติกรรมของ mysql2)
    // ไม่ใช่ Object เดี่ยวตามที่ plan.md ข้อ 24 สื่อไว้ — ดู backendapi.md ข้อ 2/6
    final Map<String, dynamic> productJson = data is List
        ? data.first as Map<String, dynamic>
        : data as Map<String, dynamic>;

    return Product.fromJson(productJson);
  }

  // Challenge 5 (plan.md ข้อ 57 / planV2.md ข้อ 59) — Admin Product CRUD.
  // Backend รับ multipart/form-data เท่านั้นสำหรับ create/update (ใช้ multer,
  // field รูป = "photo" — ดู backendapi.md ข้อ 2) ไม่ใช่ JSON แบบ endpoint อื่น
  Future<Product> createProduct({
    required String token,
    required String name,
    String? description,
    required String barcode,
    required int stock,
    required int price,
    required int categoryId,
    required int userId,
    XFile? imageFile,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse(ApiConfig.products))
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['name'] = name
      ..fields['description'] = description ?? ''
      ..fields['barcode'] = barcode
      ..fields['stock'] = stock.toString()
      ..fields['price'] = price.toString()
      ..fields['category_id'] = categoryId.toString()
      ..fields['user_id'] = userId.toString()
      ..fields['status_id'] = '1';

    if (imageFile != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'photo',
          await imageFile.readAsBytes(),
          filename: imageFile.name,
        ),
      );
    }

    return _sendProductForm(request, 'Cannot create product');
  }

  Future<Product> updateProduct({
    required String token,
    required int id,
    String? name,
    String? description,
    String? barcode,
    int? stock,
    int? price,
    int? categoryId,
    XFile? imageFile,
  }) async {
    final request = http.MultipartRequest(
      'PUT',
      Uri.parse(ApiConfig.productById(id)),
    )..headers['Authorization'] = 'Bearer $token';

    if (name != null) request.fields['name'] = name;
    if (description != null) request.fields['description'] = description;
    if (barcode != null) request.fields['barcode'] = barcode;
    if (stock != null) request.fields['stock'] = stock.toString();
    if (price != null) request.fields['price'] = price.toString();
    if (categoryId != null) request.fields['category_id'] = categoryId.toString();

    if (imageFile != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'photo',
          await imageFile.readAsBytes(),
          filename: imageFile.name,
        ),
      );
    }

    return _sendProductForm(request, 'Cannot update product');
  }

  Future<Product> _sendProductForm(
    http.MultipartRequest request,
    String fallbackErrorMessage,
  ) async {
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (data['status'] != 'ok') {
      throw Exception(data['message']?.toString() ?? fallbackErrorMessage);
    }

    return Product.fromJson(data['product'] as Map<String, dynamic>);
  }

  Future<void> deleteProduct(String token, int id) async {
    final response = await http.delete(
      Uri.parse(ApiConfig.productById(id)),
      headers: {'Authorization': 'Bearer $token'},
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (data['status'] != 'ok') {
      throw Exception(data['message']?.toString() ?? 'Cannot delete product');
    }
  }
}