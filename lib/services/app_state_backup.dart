import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import 'supabase_service.dart';
import 'recent_products_service.dart';
import 'package:logger/logger.dart';

var logger = Logger(printer: PrettyPrinter());

class OptimizedAppState extends ChangeNotifier {
  // 싱글톤 인스턴스
  static final OptimizedAppState _instance = OptimizedAppState._internal();
  factory OptimizedAppState() => _instance;
  OptimizedAppState._internal();

  // 데이터 상태
  List<Product> _allProducts = [];
  List<Product> _recentProducts = [];
  bool _isLoading = false;
  final Map<int, bool> _favorites = {};
  final Map<int, int> _reviewCounts = {}; // 상품별 리뷰 개수
  String _selectedCategory = '전체'; // 선택된 카테고리
  List<CartItem> _cartItems = []; // 장바구니 아이템들
  final int _currentUserId = 1; // 현재 사용자 ID (임시)

  // Getters
  List<Product> get allProducts => _getFilteredProducts();
  List<Product> get recentProducts => _recentProducts;
  List<Product> get favoriteProducts => _allProducts
      .where((product) => product.id != null && _favorites[product.id!] == true)
      .toList();

  // 인기 상품 목록 (좋아요 + 리뷰 개수 기준 정렬)
  List<Product> get popularProducts => _getPopularProducts();
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;
  List<CartItem> get cartItems => _cartItems;
  int get cartItemCount =>
      _cartItems.fold(0, (sum, item) => sum + item.quantity);
  bool isFavorite(int productId) => _favorites[productId] ?? false;

  // 특정 상품의 좋아요 개수 가져오기 (DB의 likes 필드 사용)
  String getFavoriteCount(int productId) {
    // 상품을 찾아서 실제 likes 값 사용
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

  // 특정 상품의 리뷰 개수 가져오기
  int getReviewCount(int productId) {
    return _reviewCounts[productId] ?? 0;
  }

  // 리뷰 개수 설정
  void setReviewCount(int productId, int count) {
    _reviewCounts[productId] = count;
    notifyListeners();
  }

  // 카테고리별 필터링된 상품 목록 반환 (검색어 필터링 제거)
  List<Product> _getFilteredProducts() {
    var filteredProducts = _allProducts;

    // 카테고리 필터링
    if (_selectedCategory != '전체') {
      filteredProducts = filteredProducts.where((product) {
        // 카테고리 필드가 있으면 카테고리로 필터링
        if (product.category != null && product.category!.isNotEmpty) {
          return product.category == _selectedCategory;
        }

        // 카테고리 필드가 없으면 상품명으로 필터링
        switch (_selectedCategory) {
          case '티셔츠':
            return product.productName.toLowerCase().contains('티셔츠') ||
                product.productName.toLowerCase().contains('반팔') ||
                product.productName.toLowerCase().contains('긴팔');
          case '셔츠':
            return product.productName.toLowerCase().contains('셔츠') ||
                product.productName.toLowerCase().contains('블라우스');
          case '후드':
            return product.productName.toLowerCase().contains('후드');
          case '아우터':
            return product.productName.toLowerCase().contains('자켓') ||
                product.productName.toLowerCase().contains('코트') ||
                product.productName.toLowerCase().contains('아우터');
          case '바람막이':
            return product.productName.toLowerCase().contains('바람막이') ||
                product.productName.toLowerCase().contains('윈드브레이커');
          case '청바지':
            return product.productName.toLowerCase().contains('청바지') ||
                product.productName.toLowerCase().contains('진');
          case '반바지':
            return product.productName.toLowerCase().contains('반바지') ||
                product.productName.toLowerCase().contains('숏');
          case '바지':
            return product.productName.toLowerCase().contains('바지') &&
                !product.productName.toLowerCase().contains('청바지') &&
                !product.productName.toLowerCase().contains('반바지');
          case '신발':
            return product.productName.toLowerCase().contains('신발') ||
                product.productName.toLowerCase().contains('운동화') ||
                product.productName.toLowerCase().contains('스니커') ||
                product.productName.toLowerCase().contains('부츠') ||
                product.productName.toLowerCase().contains('샌들');
          case '액세서리':
            return product.productName.toLowerCase().contains('가방') ||
                product.productName.toLowerCase().contains('백팩') ||
                product.productName.toLowerCase().contains('시계') ||
                product.productName.toLowerCase().contains('향수') ||
                product.productName.toLowerCase().contains('오드퍼퓸');
          default:
            return true;
        }
      }).toList();
    }

    return filteredProducts;
  }

  // 인기 상품 목록 반환 (좋아요 + 리뷰 개수 기준 정렬)
  List<Product> _getPopularProducts() {
    var filteredProducts = _getFilteredProducts();

    // 인기도 점수 계산하여 정렬
    filteredProducts.sort((a, b) {
      final aId = a.id;
      final bId = b.id;

      if (aId == null || bId == null) return 0;

      // 좋아요 개수 (실제로는 DB의 likes 필드 사용, 임시로 즐겨찾기 상태 사용)
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

  // 카테고리 설정
  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // 장바구니에 상품 추가
  Future<void> addToCart(
    int productId, {
    int quantity = 1,
    String selectedOptions = '',
  }) async {
    try {
      final result = await SupabaseService.addToCart(
        userId: _currentUserId,
        productId: productId,
        quantity: quantity,
        selectedOptions: selectedOptions,
      );

      if (result != null) {
        // 기존 아이템이 있는지 확인하고 업데이트하거나 새로 추가
        // 같은 상품 ID + 같은 옵션이 있는지 확인
        final existingIndex = _cartItems.indexWhere(
          (item) =>
              item.productId == productId &&
              item.selectedOptions == selectedOptions,
        );
        if (existingIndex != -1) {
          _cartItems[existingIndex] = result;
        } else {
          _cartItems.add(result);
        }
        notifyListeners();
      }
    } catch (e) {
      logger.e('Error adding to cart: $e');
    }
  }

  // 장바구니 아이템 수량 업데이트
  Future<void> updateCartItemQuantity(int cartItemId, int quantity) async {
    try {
      final success = await SupabaseService.updateCartItemQuantity(
        cartItemId,
        quantity,
      );
      if (success) {
        final index = _cartItems.indexWhere((item) => item.id == cartItemId);
        if (index != -1) {
          _cartItems[index] = _cartItems[index].copyWith(quantity: quantity);
          notifyListeners();
        }
      }
    } catch (e) {
      logger.e('Error updating cart item quantity: $e');
    }
  }

  // 장바구니에서 아이템 제거
  Future<void> removeFromCart(int cartItemId) async {
    try {
      final success = await SupabaseService.removeFromCart(cartItemId);
      if (success) {
        _cartItems.removeWhere((item) => item.id == cartItemId);
        notifyListeners();
      }
    } catch (e) {
      logger.e('Error removing from cart: $e');
    }
  }

  // 장바구니 전체 삭제
  Future<void> clearCart() async {
    try {
      final success = await SupabaseService.clearCart(_currentUserId);
      if (success) {
        _cartItems.clear();
        notifyListeners();
      }
    } catch (e) {
      logger.e('Error clearing cart: $e');
    }
  }

  // 장바구니 로드
  Future<void> loadCartItems() async {
    try {
      _cartItems = await SupabaseService.getCartItems(_currentUserId);
      notifyListeners();
    } catch (e) {
      logger.e('Error loading cart items: $e');
    }
  }

  // 앱 초기화
  Future<void> initialize() async {
    await _loadAllData();
    await loadCartItems();
  }

  // 모든 데이터 로드
  Future<void> _loadAllData() async {
    _setLoading(true);

    try {
      // 모든 상품 로드
      final products = await SupabaseService.getAllProducts();
      _allProducts = products;

      // 즐겨찾기 상태 초기화
      _initializeFavorites(products);

      // 리뷰 개수 초기화
      await _initializeReviewCounts(products);

      // 최근 본 상품 로드
      _recentProducts = await RecentProductsService.getRecentProducts();
    } catch (e) {
      logger.e('Error loading data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 즐겨찾기 상태 초기화 (기존 상태 유지)
  void _initializeFavorites(List<Product> products) {
    // 기존 즐겨찾기 상태를 유지하면서 새로운 상품만 추가
    for (final product in products) {
      if (product.id != null) {
        // 이미 로컬에 상태가 있으면 유지, 없으면 DB 상태로 초기화
        _favorites[product.id!] = _favorites.containsKey(product.id!)
            ? (_favorites[product.id!] ?? false)
            : product.isFavorite;
      }
    }
  }

  // 리뷰 개수 초기화 (실제 DB에서 리뷰 개수 가져오기)
  Future<void> _initializeReviewCounts(List<Product> products) async {
    try {
      // 모든 리뷰를 한 번에 가져와서 상품별로 그룹화
      final allReviews = await SupabaseService.getAllReviews();

      // 리뷰 개수 초기화
      _reviewCounts.clear();

      // 각 상품별로 리뷰 개수 계산
      for (final product in products) {
        if (product.id != null) {
          final productReviews = allReviews
              .where((review) => review.productId == product.id)
              .toList();
          _reviewCounts[product.id!] = productReviews.length;
        }
      }
    } catch (e) {
      logger.e('Error loading review counts: $e');
      // 에러 시 모든 상품의 리뷰 개수를 0으로 설정
      for (final product in products) {
        if (product.id != null) {
          _reviewCounts[product.id!] = 0;
        }
      }
    }
  }

  // 즐겨찾기 토글
  Future<void> toggleFavorite(int productId) async {
    try {
      // 현재 상태 확인
      final currentStatus = _favorites[productId] ?? false;
      final newStatus = !currentStatus;

      // 즉시 로컬 상태 업데이트 (UI 반응성 향상)
      _favorites[productId] = newStatus;

      // 로컬 상품 데이터의 좋아요 개수도 업데이트
      _updateLocalProductLikes(productId, newStatus);

      notifyListeners();

      // Supabase에서 토글
      try {
        await SupabaseService.toggleFavorite(productId);
      } catch (e) {
        logger.e('Error updating favorite in Supabase: $e');
        // 에러 시 원래 상태로 되돌리기
        _favorites[productId] = currentStatus;
        _updateLocalProductLikes(productId, currentStatus);
        notifyListeners();
      }
    } catch (e) {
      logger.e('Error toggling favorite: $e');
    }
  }

  // 로컬 상품 데이터의 좋아요 개수 업데이트
  void _updateLocalProductLikes(int productId, bool isLiked) {
    final productIndex = _allProducts.indexWhere(
      (product) => product.id == productId,
    );
    if (productIndex != -1) {
      final currentProduct = _allProducts[productIndex];
      final currentLikes = int.tryParse(currentProduct.likes) ?? 0;
      final newLikes = isLiked ? currentLikes + 1 : currentLikes - 1;
      final finalLikes = newLikes < 0 ? 0 : newLikes; // 음수 방지

      // 새로운 상품 객체 생성하여 리스트 업데이트
      _allProducts[productIndex] = Product(
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

  // 최근 본 상품 추가
  Future<void> addRecentProduct(Product product) async {
    await RecentProductsService.addRecentProduct(product);
    _recentProducts = await RecentProductsService.getRecentProducts();
    notifyListeners();
  }

  // 데이터 새로고침 (즐겨찾기 상태 유지)
  Future<void> refresh() async {
    _setLoading(true);

    try {
      // 모든 상품 로드
      final products = await SupabaseService.getAllProducts();
      _allProducts = products;

      // 즐겨찾기 상태는 유지 (새로 초기화하지 않음)
      for (final product in products) {
        if (product.id != null && !_favorites.containsKey(product.id!)) {
          _favorites[product.id!] = product.isFavorite;
        }
      }

      // 리뷰 개수 초기화
      await _initializeReviewCounts(products);

      // 최근 본 상품 로드
      _recentProducts = await RecentProductsService.getRecentProducts();

      // 장바구니 로드
      await loadCartItems();
    } catch (e) {
      logger.e('Error refreshing data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 로딩 상태 설정
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
