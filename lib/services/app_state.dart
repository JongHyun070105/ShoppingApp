import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import 'supabase_service.dart';
import 'recent_products_service.dart';

class AppState extends ChangeNotifier {
  // 싱글톤 인스턴스
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  // 데이터 상태
  List<Product> _allProducts = [];
  List<Product> _recentProducts = [];
  bool _isLoading = false;
  final Map<int, bool> _favorites = {};
  final Map<int, int> _reviewCounts = {}; // 상품별 리뷰 개수
  String _selectedCategory = '전체'; // 선택된 카테고리
  String _searchQuery = ''; // 검색어
  List<CartItem> _cartItems = []; // 장바구니 아이템들
  final int _currentUserId = 1; // 현재 사용자 ID (임시)

  // Getters
  List<Product> get allProducts => _getFilteredProducts();
  List<Product> get recentProducts => _recentProducts;
  List<Product> get favoriteProducts => _allProducts
      .where((product) => product.id != null && _favorites[product.id!] == true)
      .toList();
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  List<CartItem> get cartItems => _cartItems;
  int get cartItemCount =>
      _cartItems.fold(0, (sum, item) => sum + item.quantity);
  bool isFavorite(int productId) => _favorites[productId] ?? false;

  // 특정 상품의 좋아요 개수 가져오기 (실제로는 DB에서 가져와야 하지만 임시로 즐겨찾기 상태 기반)
  String getFavoriteCount(int productId) {
    final isFav = isFavorite(productId);
    return isFav ? '1+' : '0';
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

  // 카테고리 및 검색어별 필터링된 상품 목록 반환
  List<Product> _getFilteredProducts() {
    var filteredProducts = _allProducts;

    // 1. 카테고리 필터링
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

    // 2. 검색어 필터링
    if (_searchQuery.isNotEmpty) {
      filteredProducts = filteredProducts.where((product) {
        final query = _searchQuery.toLowerCase();
        return product.productName.toLowerCase().contains(query) ||
            product.brandName.toLowerCase().contains(query) ||
            (product.category?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    return filteredProducts;
  }

  // 카테고리 설정
  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // 검색어 설정
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // 검색어 초기화
  void clearSearch() {
    _searchQuery = '';
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
      print('Error adding to cart: $e');
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
      print('Error updating cart item quantity: $e');
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
      print('Error removing from cart: $e');
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
      print('Error clearing cart: $e');
    }
  }

  // 장바구니 로드
  Future<void> loadCartItems() async {
    try {
      _cartItems = await SupabaseService.getCartItems(_currentUserId);
      notifyListeners();
    } catch (e) {
      print('Error loading cart items: $e');
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
      _initializeReviewCounts(products);

      // 최근 본 상품 로드
      _recentProducts = await RecentProductsService.getRecentProducts();
    } catch (e) {
      print('Error loading data: $e');
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

  // 리뷰 개수 초기화
  void _initializeReviewCounts(List<Product> products) {
    for (final product in products) {
      if (product.id != null) {
        // 상품 모델의 리뷰 개수를 기본값으로 설정
        _reviewCounts[product.id!] = int.tryParse(product.reviews) ?? 0;
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
      notifyListeners();

      // Supabase에서 토글
      try {
        await SupabaseService.toggleFavorite(productId);
      } catch (e) {
        print('Error updating favorite in Supabase: $e');
        // 에러 시 원래 상태로 되돌리기
        _favorites[productId] = currentStatus;
        notifyListeners();
      }
    } catch (e) {
      print('Error toggling favorite: $e');
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
      _initializeReviewCounts(products);

      // 최근 본 상품 로드
      _recentProducts = await RecentProductsService.getRecentProducts();

      // 장바구니 로드
      await loadCartItems();
    } catch (e) {
      print('Error refreshing data: $e');
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
