import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/product.dart';
import 'package:logger/logger.dart';

var logger = Logger(printer: PrettyPrinter());

class RecentProductsService {
  static const String _recentProductsKey = 'recent_products';
  static const int _maxRecentProducts = 10;

  // 최근 본 상품 저장
  static Future<void> addRecentProduct(Product product) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentProductsJson = prefs.getStringList(_recentProductsKey) ?? [];

      // 기존 상품들을 Product 객체로 변환
      List<Product> recentProducts = recentProductsJson
          .map((json) => Product.fromJson(jsonDecode(json)))
          .toList();

      // 중복 제거 (같은 ID의 상품이 있으면 제거)
      recentProducts.removeWhere((p) => p.id == product.id);

      // 새 상품을 맨 앞에 추가
      recentProducts.insert(0, product);

      // 최대 개수 제한
      if (recentProducts.length > _maxRecentProducts) {
        recentProducts = recentProducts.take(_maxRecentProducts).toList();
      }

      // JSON으로 변환하여 저장
      final updatedJson = recentProducts
          .map((product) => jsonEncode(product.toJson()))
          .toList();

      await prefs.setStringList(_recentProductsKey, updatedJson);
    } catch (e) {
      logger.e('Error adding recent product: $e');
    }
  }

  // 최근 본 상품 조회
  static Future<List<Product>> getRecentProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentProductsJson = prefs.getStringList(_recentProductsKey) ?? [];

      return recentProductsJson
          .map((json) => Product.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      logger.e('Error getting recent products: $e');
      return [];
    }
  }

  // 최근 본 상품 전체 삭제
  static Future<void> clearRecentProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_recentProductsKey);
    } catch (e) {
      logger.e('Error clearing recent products: $e');
    }
  }

  // 특정 상품을 최근 본 상품에서 삭제
  static Future<void> removeRecentProduct(int productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentProductsJson = prefs.getStringList(_recentProductsKey) ?? [];

      List<Product> recentProducts = recentProductsJson
          .map((json) => Product.fromJson(jsonDecode(json)))
          .toList();

      recentProducts.removeWhere((product) => product.id == productId);

      final updatedJson = recentProducts
          .map((product) => jsonEncode(product.toJson()))
          .toList();

      await prefs.setStringList(_recentProductsKey, updatedJson);
    } catch (e) {
      logger.e('Error removing recent product: $e');
    }
  }
}
