import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../models/review.dart';
import 'supabase_service.dart';

/// 최적화된 앱 상태 관리 - 성능 개선을 위한 분리된 상태 관리
class OptimizedAppState extends ChangeNotifier {
  // 상품 관련 상태
  final List<Product> _allProducts = [];
  final Map<String, List<Product>> _cachedProducts = {};
  String _selectedCategory = '전체';
  bool _isLoading = false;

  // 즐겨찾기 관련 상태 (별도 관리)
  final Map<int, bool> _favorites = {};
  List<Product> _favoriteProducts = [];

  // 장바구니 관련 상태 (별도 관리)
  List<CartItem> _cartItems = [];

  // 리뷰 관련 상태 (캐싱)
  final Map<int, int> _reviewCounts = {};
  final Map<int, List<Review>> _reviewCache = {};

  // Getters
  List<Product> get allProducts => List.unmodifiable(_allProducts);
  List<Product> get filteredProducts => _getFilteredProducts();
  List<Product> get popularProducts => _getPopularProducts();
  List<Product> get favoriteProducts => List.unmodifiable(_favoriteProducts);
  List<CartItem> get cartItems => List.unmodifiable(_cartItems);
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  int get cartItemCount =>
      _cartItems.fold(0, (sum, item) => sum + item.quantity);

  // 즐겨찾기 관련
  bool isFavorite(int productId) => _favorites[productId] ?? false;
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

  // 리뷰 개수 가져오기 (캐시된 값 사용)
  int getReviewCount(int productId) => _reviewCounts[productId] ?? 0;

  // 최근 상품 목록 (임시로 인기 상품 반환)
  List<Product> get recentProducts => _getPopularProducts().take(10).toList();

  // 카테고리 설정 (기존 setCategory 메서드)
  Future<void> setCategory(String category) async {
    await setSelectedCategory(category);
  }

  // 앱 초기화
  Future<void> initialize() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _loadProducts();
      await _loadCartItems();
      await _loadFavoriteProducts();
      await _initializeReviewCounts();
      await _loadUserPreferences();
    } catch (e) {
      logger.e('Error initializing app: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 상품 로드 (캐시 활용)
  Future<void> _loadProducts() async {
    try {
      if (_cachedProducts.containsKey(_selectedCategory)) {
        _allProducts.clear();
        _allProducts.addAll(_cachedProducts[_selectedCategory]!);
        return;
      }

      final products = await SupabaseService.getAllProducts();
      _allProducts.clear();
      _allProducts.addAll(products);

      // 카테고리별 캐시 저장
      _cachedProducts[_selectedCategory] = List.from(products);

      // 즐겨찾기 상태 초기화
      _initializeFavorites();
    } catch (e) {
      logger.e('Error loading products: $e');
    }
  }

  // 즐겨찾기 상태 초기화
  void _initializeFavorites() {
    for (final product in _allProducts) {
      if (product.id != null) {
        _favorites[product.id!] = _favorites.containsKey(product.id!)
            ? (_favorites[product.id!] ?? false)
            : product.isFavorite;
      }
    }
  }

  // 장바구니 아이템 로드
  Future<void> _loadCartItems() async {
    try {
      _cartItems = await SupabaseService.getCartItems(1); // 임시 사용자 ID
    } catch (e) {
      logger.e('Error loading cart items: $e');
      _cartItems = [];
    }
  }

  // 즐겨찾기 상품 로드
  Future<void> _loadFavoriteProducts() async {
    try {
      _favoriteProducts = await SupabaseService.getFavoriteProducts();
    } catch (e) {
      logger.e('Error loading favorite products: $e');
      _favoriteProducts = [];
    }
  }

  // 리뷰 개수 초기화 (성능 최적화)
  Future<void> _initializeReviewCounts() async {
    try {
      // 모든 리뷰를 한 번에 가져와서 상품별로 그룹화
      final allReviews = await SupabaseService.getAllReviews();

      // 리뷰 개수 초기화
      _reviewCounts.clear();

      // 각 상품별로 리뷰 개수 계산
      for (final product in _allProducts) {
        if (product.id != null) {
          final productReviews = allReviews
              .where((review) => review.productId == product.id)
              .toList();
          _reviewCounts[product.id!] = productReviews.length;
          // 리뷰 캐시도 저장
          _reviewCache[product.id!] = productReviews;
        }
      }
    } catch (e) {
      logger.e('Error loading review counts: $e');
      // 에러 시 모든 상품의 리뷰 개수를 0으로 설정
      for (final product in _allProducts) {
        if (product.id != null) {
          _reviewCounts[product.id!] = 0;
        }
      }
    }
  }

  // 사용자 설정 로드
  Future<void> _loadUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _selectedCategory = prefs.getString('selected_category') ?? '전체';
    } catch (e) {
      logger.e('Error loading user preferences: $e');
    }
  }

  // 카테고리 필터링
  List<Product> _getFilteredProducts() {
    if (_selectedCategory == '전체') {
      return _allProducts;
    }
    return _allProducts
        .where((product) => product.category == _selectedCategory)
        .toList();
  }

  // 인기 상품 정렬 (캐시된 값 사용)
  List<Product> _getPopularProducts() {
    var filteredProducts = _getFilteredProducts();

    // 인기도 점수 계산하여 정렬
    filteredProducts.sort((a, b) {
      final aId = a.id;
      final bId = b.id;

      if (aId == null || bId == null) return 0;

      // 좋아요 개수와 리뷰 개수 (캐시된 값 사용)
      final aLikes = int.tryParse(a.likes) ?? 0;
      final bLikes = int.tryParse(b.likes) ?? 0;

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

  // 카테고리 변경
  Future<void> setSelectedCategory(String category) async {
    if (_selectedCategory == category) return;

    _selectedCategory = category;

    // 사용자 설정 저장
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_category', category);
    } catch (e) {
      logger.e('Error saving category preference: $e');
    }

    // 캐시된 데이터가 있으면 사용, 없으면 새로 로드
    if (_cachedProducts.containsKey(category)) {
      _allProducts.clear();
      _allProducts.addAll(_cachedProducts[category]!);
      notifyListeners();
    } else {
      await _loadProducts();
    }
  }

  // 즐겨찾기 토글 (최적화된 버전)
  Future<void> toggleFavorite(int productId) async {
    try {
      // 현재 상태 확인
      final currentStatus = _favorites[productId] ?? false;
      final newStatus = !currentStatus;

      // 즉시 로컬 상태 업데이트 (UI 반응성 향상)
      _favorites[productId] = newStatus;

      // 로컬 상품 데이터의 좋아요 개수도 업데이트
      _updateLocalProductLikes(productId, newStatus);

      // 즐겨찾기 상품 목록 업데이트
      _updateFavoriteProducts();

      notifyListeners();

      // Supabase에서 토글 (백그라운드에서)
      SupabaseService.toggleFavorite(productId).catchError((e) {
        logger.e('Error updating favorite in Supabase: $e');
        // 에러 시 원래 상태로 되돌리기
        _favorites[productId] = currentStatus;
        _updateLocalProductLikes(productId, currentStatus);
        _updateFavoriteProducts();
        notifyListeners();
        return false; // onError 핸들러가 bool 값을 반환해야 함
      });
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

  // 즐겨찾기 상품 목록 업데이트
  void _updateFavoriteProducts() {
    _favoriteProducts = _allProducts
        .where(
          (product) => product.id != null && _favorites[product.id!] == true,
        )
        .toList();
  }

  // 리뷰 개수 업데이트
  void setReviewCount(int productId, int count) {
    _reviewCounts[productId] = count;
    // 특정 상품의 리뷰 개수만 업데이트하므로 전체 notifyListeners 호출하지 않음
  }

  // 장바구니에 상품 추가
  Future<void> addToCart(
    int productId, {
    int quantity = 1,
    String selectedOptions = '',
  }) async {
    try {
      final result = await SupabaseService.addToCart(
        userId: 1, // 임시 사용자 ID
        productId: productId,
        quantity: quantity,
        selectedOptions: selectedOptions,
      );

      if (result != null) {
        // 기존 아이템이 있는지 확인하고 업데이트하거나 새로 추가
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

  // 새로고침
  Future<void> refresh() async {
    _cachedProducts.clear(); // 캐시 클리어
    await initialize();
  }

  // 최근 상품 추가
  void addRecentProduct(Product product) {
    // 최근 상품 기능은 추후 구현
    // 현재는 인기 상품으로 대체
  }

  // 장바구니 전체 삭제
  Future<void> clearCart() async {
    try {
      final success = await SupabaseService.clearCart(1); // 임시 사용자 ID
      if (success) {
        _cartItems.clear();
        notifyListeners();
      }
    } catch (e) {
      logger.e('Error clearing cart: $e');
    }
  }

  // 메모리 정리
  @override
  void dispose() {
    _allProducts.clear();
    _cachedProducts.clear();
    _favorites.clear();
    _favoriteProducts.clear();
    _cartItems.clear();
    _reviewCounts.clear();
    _reviewCache.clear();
    super.dispose();
  }
}
