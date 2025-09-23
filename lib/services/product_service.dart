import 'package:flutter/material.dart';
import '../models/product.dart';
import 'supabase_service.dart';

/// 상품 관련 데이터와 로직을 관리하는 서비스
class ProductService extends ChangeNotifier {
  List<Product> _allProducts = [];
  final Map<int, int> _reviewCounts = {};
  bool _isLoading = false;

  // Getters
  List<Product> get allProducts => _allProducts;
  bool get isLoading => _isLoading;
  
  // 특정 상품의 리뷰 개수 가져오기
  int getReviewCount(int productId) {
    return _reviewCounts[productId] ?? 0;
  }

  // 리뷰 개수 설정
  void setReviewCount(int productId, int count) {
    _reviewCounts[productId] = count;
    notifyListeners();
  }

  // 카테고리별 필터링된 상품 목록 반환
  List<Product> getProductsByCategory(String category) {
    var filteredProducts = _allProducts;

    if (category != '전체') {
      filteredProducts = filteredProducts.where((product) {
        // 카테고리 필드가 있으면 카테고리로 필터링
        if (product.category != null && product.category!.isNotEmpty) {
          return product.category == category;
        }

        // 카테고리 필드가 없으면 상품명으로 필터링
        return _matchesCategoryByProductName(product.productName, category);
      }).toList();
    }

    return filteredProducts;
  }

  // 인기 상품 목록 반환 (좋아요 + 리뷰 개수 기준 정렬)
  List<Product> getPopularProducts(String category) {
    var filteredProducts = getProductsByCategory(category);
    
    // 인기도 점수 계산하여 정렬
    filteredProducts.sort((a, b) {
      final aId = a.id;
      final bId = b.id;
      
      if (aId == null || bId == null) return 0;
      
      // 좋아요 개수
      final aLikes = int.tryParse(a.likes) ?? 0;
      final bLikes = int.tryParse(b.likes) ?? 0;
      
      // 리뷰 개수
      final aReviews = _reviewCounts[aId] ?? 0;
      final bReviews = _reviewCounts[bId] ?? 0;
      
      // 인기도 점수 계산 (좋아요 * 2 + 리뷰 * 1)
      final aPopularity = (aLikes * 2) + aReviews;
      final bPopularity = (bLikes * 2) + bReviews;
      
      // 내림차순 정렬 (인기 순)
      return bPopularity.compareTo(aPopularity);
    });
    
    return filteredProducts;
  }

  // 상품명으로 카테고리 매칭
  bool _matchesCategoryByProductName(String productName, String category) {
    final name = productName.toLowerCase();
    
    switch (category) {
      case '티셔츠':
        return name.contains('티셔츠') || name.contains('반팔') || name.contains('긴팔');
      case '셔츠':
        return name.contains('셔츠') || name.contains('블라우스');
      case '후드':
        return name.contains('후드');
      case '아우터':
        return name.contains('자켓') || name.contains('코트') || name.contains('아우터');
      case '바람막이':
        return name.contains('바람막이') || name.contains('윈드브레이커');
      case '청바지':
        return name.contains('청바지') || name.contains('진');
      case '반바지':
        return name.contains('반바지') || name.contains('숏');
      case '바지':
        return name.contains('바지') && 
               !name.contains('청바지') && 
               !name.contains('반바지');
      case '신발':
        return name.contains('신발') || name.contains('운동화') || 
               name.contains('스니커') || name.contains('부츠') || 
               name.contains('샌들');
      case '액세서리':
        return name.contains('가방') || name.contains('백팩') || 
               name.contains('시계') || name.contains('향수') || 
               name.contains('오드퍼퓸');
      default:
        return true;
    }
  }

  // 검색 결과 반환
  List<Product> searchProducts(String query, String category) {
    var filteredProducts = getProductsByCategory(category);
    
    if (query.isEmpty) return filteredProducts;
    
    final searchQuery = query.toLowerCase();
    return filteredProducts.where((product) {
      return product.productName.toLowerCase().contains(searchQuery) ||
             product.brandName.toLowerCase().contains(searchQuery) ||
             (product.category?.toLowerCase().contains(searchQuery) ?? false);
    }).toList();
  }

  // 특정 상품의 좋아요 개수 가져오기
  String getFavoriteCount(int productId) {
    final product = _allProducts.firstWhere(
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

  // 모든 상품 로드
  Future<void> loadAllProducts() async {
    _setLoading(true);

    try {
      // 모든 상품 로드
      final products = await SupabaseService.getAllProducts();
      _allProducts = products;

      // 리뷰 개수 초기화
      await _initializeReviewCounts(products);
    } catch (e) {
      print('Error loading products: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 리뷰 개수 초기화
  Future<void> _initializeReviewCounts(List<Product> products) async {
    try {
      // 모든 리뷰를 한 번에 가져와서 상품별로 그룹화
      final allReviews = await SupabaseService.getAllReviews();
      
      // 리뷰 개수 초기화
      _reviewCounts.clear();
      
      // 각 상품별로 리뷰 개수 계산
      for (final product in products) {
        if (product.id != null) {
          final productReviews = allReviews.where((review) => review.productId == product.id).toList();
          _reviewCounts[product.id!] = productReviews.length;
        }
      }
    } catch (e) {
      print('Error loading review counts: $e');
      // 에러 시 모든 상품의 리뷰 개수를 0으로 설정
      for (final product in products) {
        if (product.id != null) {
          _reviewCounts[product.id!] = 0;
        }
      }
    }
  }

  // 로딩 상태 설정
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}

