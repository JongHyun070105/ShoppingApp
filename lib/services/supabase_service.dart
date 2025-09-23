import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';
import '../models/review.dart';
import '../models/qa.dart';
import '../models/cart_item.dart';
import '../config/supabase_config.dart';

class SupabaseService {
  static SupabaseClient get _client => SupabaseConfig.client;

  // 모든 상품 조회
  static Future<List<Product>> getAllProducts() async {
    try {
      final response = await _client
          .from('products')
          .select()
          .order('created_at', ascending: false);

      return response.map<Product>((json) => Product.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching products: $e');
      return _getMockProducts();
    }
  }

  // 즐겨찾기 상품 조회
  static Future<List<Product>> getFavoriteProducts() async {
    try {
      final response = await _client
          .from('products')
          .select()
          .eq('is_favorite', true)
          .order('created_at', ascending: false);

      return response.map<Product>((json) => Product.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching favorite products: $e');
      return _getMockFavoriteProducts();
    }
  }

  // 상품 즐겨찾기 토글
  static Future<bool> toggleFavorite(int productId) async {
    try {
      // 현재 즐겨찾기 상태와 좋아요 개수 조회
      final currentProduct = await _client
          .from('products')
          .select('is_favorite, likes')
          .eq('id', productId)
          .single();

      final currentFavoriteStatus = currentProduct['is_favorite'];
      final currentLikes =
          int.tryParse(currentProduct['likes']?.toString() ?? '0') ?? 0;
      final newFavoriteStatus = !currentFavoriteStatus;

      // 좋아요 개수 계산 (좋아요 추가 시 +1, 취소 시 -1)
      final newLikes = newFavoriteStatus ? currentLikes + 1 : currentLikes - 1;
      final finalLikes = newLikes < 0 ? 0 : newLikes; // 음수 방지

      // 즐겨찾기 상태와 좋아요 개수 업데이트
      await _client
          .from('products')
          .update({
            'is_favorite': newFavoriteStatus,
            'likes': finalLikes.toString(),
          })
          .eq('id', productId);

      return newFavoriteStatus;
    } catch (e) {
      print('Error toggling favorite: $e');
      // 에러 발생 시 모의 데이터에서는 항상 true 반환
      return true;
    }
  }

  // 상품 검색
  static Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await _client
          .from('products')
          .select()
          .or('product_name.ilike.%$query%,brand_name.ilike.%$query%')
          .order('created_at', ascending: false);

      return response.map<Product>((json) => Product.fromJson(json)).toList();
    } catch (e) {
      print('Error searching products: $e');
      return [];
    }
  }

  // 상품 추가 (관리자용)
  static Future<Product?> addProduct(Product product) async {
    try {
      final response = await _client
          .from('products')
          .insert(product.toJson())
          .select()
          .single();

      return Product.fromJson(response);
    } catch (e) {
      print('Error adding product: $e');
      return null;
    }
  }

  // 상품 업데이트 (관리자용)
  static Future<Product?> updateProduct(int id, Product product) async {
    try {
      final response = await _client
          .from('products')
          .update(product.toJson())
          .eq('id', id)
          .select()
          .single();

      return Product.fromJson(response);
    } catch (e) {
      print('Error updating product: $e');
      return null;
    }
  }

  // 상품 삭제 (관리자용)
  static Future<bool> deleteProduct(int id) async {
    try {
      await _client.from('products').delete().eq('id', id);
      return true;
    } catch (e) {
      print('Error deleting product: $e');
      return false;
    }
  }

  // 리뷰 조회
  static Future<List<Review>> getReviews(int productId) async {
    try {
      final response = await _client
          .from('reviews')
          .select()
          .eq('product_id', productId)
          .order('created_at', ascending: false);

      return response.map<Review>((json) => Review.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching reviews: $e');
      return [];
    }
  }

  // 모든 리뷰 조회 (상품별 리뷰 개수 계산용)
  static Future<List<Review>> getAllReviews() async {
    try {
      final response = await _client
          .from('reviews')
          .select()
          .order('created_at', ascending: false);

      return response.map<Review>((json) => Review.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching all reviews: $e');
      return [];
    }
  }

  // 리뷰 추가
  static Future<Review?> addReview(Review review) async {
    try {
      final response = await _client
          .from('reviews')
          .insert(review.toJson())
          .select()
          .single();

      return Review.fromJson(response);
    } catch (e) {
      print('Error adding review: $e');
      return null;
    }
  }

  // Q&A 조회
  static Future<List<Qa>> getQAs(int productId) async {
    try {
      final response = await _client
          .from('qas')
          .select()
          .eq('product_id', productId)
          .order('created_at', ascending: false);

      return response.map<Qa>((json) => Qa.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching QAs: $e');
      return [];
    }
  }

  // Q&A 추가
  static Future<Qa?> addQA(Qa qa) async {
    try {
      final response = await _client
          .from('qas')
          .insert(qa.toJson())
          .select()
          .single();

      return Qa.fromJson(response);
    } catch (e) {
      print('Error adding QA: $e');
      return null;
    }
  }

  // Q&A 답변 추가
  static Future<bool> answerQA(int qaId, String answer) async {
    try {
      await _client
          .from('qas')
          .update({
            'answer': answer,
            'answered_at': DateTime.now().toIso8601String(),
          })
          .eq('id', qaId);

      return true;
    } catch (e) {
      print('Error answering QA: $e');
      return false;
    }
  }

  // 모의 데이터 (개발용)
  static List<Product> _getMockProducts() {
    return [
      Product(
        id: 1,
        brandName: '투데이무드',
        productName: '콜린 니트 맨투맨',
        discount: '39',
        price: '59,000',
        imageUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300',
        likes: '999+',
        reviews: '120',
        isFavorite: false,
      ),
      Product(
        id: 2,
        brandName: '스타일리시',
        productName: '베이직 후드티',
        discount: '25',
        price: '39,000',
        imageUrl:
            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=300',
        likes: '756',
        reviews: '89',
        isFavorite: false,
      ),
      Product(
        id: 3,
        brandName: '트렌디웨어',
        productName: '데님 셔츠',
        discount: '30',
        price: '49,000',
        imageUrl:
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300',
        likes: '432',
        reviews: '67',
        isFavorite: false,
      ),
      Product(
        id: 4,
        brandName: '모던스타일',
        productName: '오버핏 스웨터',
        discount: '20',
        price: '69,000',
        imageUrl:
            'https://images.unsplash.com/photo-1519345182560-3f2917c472ef?w=300',
        likes: '321',
        reviews: '45',
        isFavorite: false,
      ),
    ];
  }

  static List<Product> _getMockFavoriteProducts() {
    return [
      Product(
        id: 1,
        brandName: '투데이무드',
        productName: '콜린 니트 맨투맨',
        discount: '39',
        price: '59,000',
        imageUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300',
        likes: '999+',
        reviews: '120',
        isFavorite: true,
      ),
      Product(
        id: 2,
        brandName: '스타일리시',
        productName: '베이직 후드티',
        discount: '25',
        price: '39,000',
        imageUrl:
            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=300',
        likes: '756',
        reviews: '89',
        isFavorite: true,
      ),
      Product(
        id: 3,
        brandName: '트렌디웨어',
        productName: '데님 셔츠',
        discount: '30',
        price: '49,000',
        imageUrl:
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300',
        likes: '432',
        reviews: '67',
        isFavorite: true,
      ),
      Product(
        id: 4,
        brandName: '모던스타일',
        productName: '오버핏 스웨터',
        discount: '20',
        price: '69,000',
        imageUrl:
            'https://images.unsplash.com/photo-1519345182560-3f2917c472ef?w=300',
        likes: '321',
        reviews: '45',
        isFavorite: true,
      ),
    ];
  }

  // 장바구니 아이템 조회
  static Future<List<CartItem>> getCartItems(int userId) async {
    try {
      final response = await _client
          .from('cart_items')
          .select('''
            *,
            products:product_id (*)
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response.map<CartItem>((json) {
        final product = Product.fromJson(json['products']);
        return CartItem.fromJson(json, product);
      }).toList();
    } catch (e) {
      print('Error fetching cart items: $e');
      return [];
    }
  }

  // 장바구니에 상품 추가
  static Future<CartItem?> addToCart({
    required int userId,
    required int productId,
    int quantity = 1,
    String selectedOptions = '',
  }) async {
    try {
      // 이미 장바구니에 있는 상품인지 확인 (상품 ID + 선택된 옵션으로 구분)
      final existingItem = await _client
          .from('cart_items')
          .select()
          .eq('user_id', userId)
          .eq('product_id', productId)
          .eq('selected_options', selectedOptions)
          .maybeSingle();

      if (existingItem != null) {
        // 같은 상품 + 같은 옵션이 있으면 수량만 증가
        final updatedResponse = await _client
            .from('cart_items')
            .update({
              'quantity': existingItem['quantity'] + quantity,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', existingItem['id'])
            .select('''
              *,
              products:product_id (*)
            ''')
            .single();

        final product = Product.fromJson(updatedResponse['products']);
        return CartItem.fromJson(updatedResponse, product);
      } else {
        // 새로 추가 (다른 상품이거나 같은 상품이지만 다른 옵션)
        final response = await _client
            .from('cart_items')
            .insert({
              'user_id': userId,
              'product_id': productId,
              'quantity': quantity,
              'selected_options': selectedOptions,
            })
            .select('''
              *,
              products:product_id (*)
            ''')
            .single();

        final product = Product.fromJson(response['products']);
        return CartItem.fromJson(response, product);
      }
    } catch (e) {
      print('Error adding to cart: $e');
      return null;
    }
  }

  // 장바구니 아이템 수량 업데이트
  static Future<bool> updateCartItemQuantity(
    int cartItemId,
    int quantity,
  ) async {
    try {
      await _client
          .from('cart_items')
          .update({
            'quantity': quantity,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', cartItemId);

      return true;
    } catch (e) {
      print('Error updating cart item quantity: $e');
      return false;
    }
  }

  // 장바구니 아이템 삭제
  static Future<bool> removeFromCart(int cartItemId) async {
    try {
      await _client.from('cart_items').delete().eq('id', cartItemId);
      return true;
    } catch (e) {
      print('Error removing from cart: $e');
      return false;
    }
  }

  // 장바구니 전체 삭제
  static Future<bool> clearCart(int userId) async {
    try {
      await _client.from('cart_items').delete().eq('user_id', userId);
      return true;
    } catch (e) {
      print('Error clearing cart: $e');
      return false;
    }
  }
}
