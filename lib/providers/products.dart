import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'product.dart';
import '../models/http_exception.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];
  final String? authToken;
  final String? userId;

  List<Product> get items {
    return [..._items];
  }

  Products(this.authToken, this.userId, this._items);

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndSetProducts() async {
    var url = Uri.parse(
        'https://flutter-shop-f66be-default-rtdb.europe-west1.firebasedatabase.app/products.json?auth=$authToken');

    try {
      final response = await http.get(url);
      final extractedData = jsonDecode(response.body);
      if (extractedData == null) {
        return;
      }

      url = Uri.parse(
          'https://flutter-shop-f66be-default-rtdb.europe-west1.firebasedatabase.app/userFavorites/$userId.json?auth=$authToken');

      final favoriteRespopnse = await http.get(url);
      final favoriteData = jsonDecode(favoriteRespopnse.body);

      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(
          Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            imageUrl: prodData['imageUrl'],
            isFavorite: favoriteData == null ? false : favoriteData[prodId] ?? false,
          ),
        );
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (err) {
      throw err;
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse(
        'https://flutter-shop-f66be-default-rtdb.europe-west1.firebasedatabase.app/products.json?auth=$authToken');
    try {
      var response = await http.post(url,
          body: jsonEncode({
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
          }));

      final newProduct = Product(
          id: jsonDecode(response.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl);

      _items.add(newProduct);

      notifyListeners();
    } catch (err) {
      throw err;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url = Uri.parse(
          'https://flutter-shop-f66be-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json?auth=$authToken');

      try {
        await http.patch(url,
            body: jsonEncode({
              'title': newProduct.title,
              'description': newProduct.description,
              'price': newProduct.price,
              'imageUrl': newProduct.imageUrl
            }));
      } catch (err) {
        print(err);
      }
      _items[prodIndex] = newProduct;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(
        'https://flutter-shop-f66be-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json?auth=$authToken');
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    Product? existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();

    try {
      final response = await http.delete(url);
      if (response.statusCode >= 400) {
        throw HttpException('Could not delete product.');
      }
    } catch (err) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
  }
}
