import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import 'supabase_service.dart';

/// 장바구니 관련 데이터와 로직을 관리하는 서비스
class CartService extends ChangeNotifier {
  List<CartItem> _cartItems = [];
  final int _currentUserId = 1; // 현재 사용자 ID (임시)

  // Getters
  List<CartItem> get cartItems => _cartItems;
  int get cartItemCount =>
      _cartItems.fold(0, (sum, item) => sum + item.quantity);

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

  // 특정 상품이 장바구니에 있는지 확인
  bool isInCart(int productId, {String selectedOptions = ''}) {
    return _cartItems.any(
      (item) =>
          item.productId == productId &&
          item.selectedOptions == selectedOptions,
    );
  }

  // 특정 상품의 장바구니 수량 가져오기
  int getCartQuantity(int productId, {String selectedOptions = ''}) {
    final item = _cartItems.firstWhere(
      (item) =>
          item.productId == productId &&
          item.selectedOptions == selectedOptions,
      orElse: () => CartItem(
        id: 0,
        userId: 0,
        productId: 0,
        product: Product(
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
        quantity: 0,
        selectedOptions: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return item.id != 0 ? item.quantity : 0;
  }
}
