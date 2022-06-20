import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Future<void> toggleFavoriteStatus(String? authToken, String? userId) async {
    final url = Uri.parse(
        'https://flutter-shop-f66be-default-rtdb.europe-west1.firebasedatabase.app/userFavorites/$userId/$id.json?auth=$authToken');

    isFavorite = !isFavorite;
    notifyListeners();

    try {
      final response = await http.put(url,
          body: jsonEncode(isFavorite));

      if(response.statusCode >= 400) {
        isFavorite = !isFavorite;
        notifyListeners();
        throw HttpException('Failed update product.');
      }
    } catch (err) {
      throw HttpException('Failed update product.');
    }
  }

  Product(
      {required this.id,
      required this.title,
      required this.description,
      required this.price,
      required this.imageUrl,
      this.isFavorite = false});
}
