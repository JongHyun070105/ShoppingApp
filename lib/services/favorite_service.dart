import 'package:flutter/material.dart';
import '../models/product.dart';
import 'supabase_service.dart';

/// 즐겨찾기 관련 데이터와 로직을 관리하는 서비스
class FavoriteService extends ChangeNotifier {
  final Map<int, bool> _favorites = {};
  List<Product> _favoriteProducts = [];

  // Getters
  List<Product> get favoriteProducts => _favoriteProducts;
  bool isFavorite(int productId) => _favorites[productId] ?? false;

  // 특정 상품의 좋아요 개수 가져오기
  String getFavoriteCount(int productId, List<Product> allProducts) {
    final product = allProducts.firstWhere(
      (p) => p.id == productId,
      orElse: () => Product(
        id: 0,
        productName: '',
        brandName: '',
        price: '0',
        discount: '0',
        imageUrl: '',
        category: '',
        likes: '0',
        reviews: '0',
        isFavorite: false,
      ),
    );
    
    final likesCount = int.tryParse(product.likes) ?? 0;
    return likesCount.toString();
  }

  // 즐겨찾기 상태 초기화 (기존 상태 유지)
  void initializeFavorites(List<Product> products) {
    // 기존 즐겨찾기 상태를 유지하면서 새로운 상품만 추가
    for (final product in products) {
      if (product.id != null) {
        // 이미 로컬에 상태가 있으면 유지, 없으면 DB 상태로 초기화
        _favorites[product.id!] = _favorites.containsKey(product.id!)
            ? (_favorites[product.id!] ?? false)
            : product.isFavorite;
      }
    }
    notifyListeners();
  }

  // 즐겨찾기 토글
  Future<void> toggleFavorite(int productId, List<Product> allProducts) async {
    try {
      // 현재 상태 확인
      final currentStatus = _favorites[productId] ?? false;
      final newStatus = !currentStatus;

      // 즉시 로컬 상태 업데이트 (UI 반응성 향상)
      _favorites[productId] = newStatus;
      
      // 로컬 상품 데이터의 좋아요 개수도 업데이트
      _updateLocalProductLikes(productId, newStatus, allProducts);
      
      notifyListeners();

      // Supabase에서 토글
      try {
        await SupabaseService.toggleFavorite(productId);
      } catch (e) {
        logger.e('Error updating favorite in Supabase: $e');
        // 에러 시 원래 상태로 되돌리기
        _favorites[productId] = currentStatus;
        _updateLocalProductLikes(productId, currentStatus, allProducts);
        notifyListeners();
      }
    } catch (e) {
      logger.e('Error toggling favorite: $e');
    }
  }

  // 로컬 상품 데이터의 좋아요 개수 업데이트
  void _updateLocalProductLikes(int productId, bool isLiked, List<Product> allProducts) {
    final productIndex = allProducts.indexWhere(
      (product) => product.id == productId,
    );
    if (productIndex != -1) {
      final currentProduct = allProducts[productIndex];
      final currentLikes = int.tryParse(currentProduct.likes) ?? 0;
      final newLikes = isLiked ? currentLikes + 1 : currentLikes - 1;
      final finalLikes = newLikes < 0 ? 0 : newLikes; // 음수 방지

      // 새로운 상품 객체 생성하여 리스트 업데이트
      allProducts[productIndex] = Product(
        id: currentProduct.id,
        productName: currentProduct.productName,
        brandName: currentProduct.brandName,
        price: currentProduct.price,
        discount: currentProduct.discount,
        imageUrl: currentProduct.imageUrl,
        category: currentProduct.category,
        likes: finalLikes.toString(),
        reviews: currentProduct.reviews,
        isFavorite: isLiked,
      );
    }
  }

  // 즐겨찾기 상품 목록 업데이트
  void updateFavoriteProducts(List<Product> allProducts) {
    _favoriteProducts = allProducts
        .where((product) => product.id != null && _favorites[product.id!] == true)
        .toList();
    notifyListeners();
  }

  // 즐겨찾기 상품 로드
  Future<void> loadFavoriteProducts() async {
    try {
      _favoriteProducts = await SupabaseService.getFavoriteProducts();
      notifyListeners();
    } catch (e) {
      logger.e('Error loading favorite products: $e');
    }
  }
}

