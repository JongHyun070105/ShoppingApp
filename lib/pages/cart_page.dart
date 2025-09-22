import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/cart_item.dart';
import '../utils/price_formatter.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _selectAll = false;

  void _toggleSelectAll() {
    final appState = context.read<AppState>();
    setState(() {
      _selectAll = !_selectAll;
      for (var item in appState.cartItems) {
        item.isSelected = _selectAll;
      }
    });
  }

  void _toggleItemSelection(int itemId) {
    final appState = context.read<AppState>();
    setState(() {
      final item = appState.cartItems.firstWhere((item) => item.id == itemId);
      item.isSelected = !item.isSelected;

      // 전체 선택 상태 업데이트
      _selectAll = appState.cartItems.every((item) => item.isSelected);
    });
  }

  void _updateQuantity(int itemId, int newQuantity) {
    final appState = context.read<AppState>();
    if (newQuantity > 0) {
      appState.updateCartItemQuantity(itemId, newQuantity);
    } else {
      appState.removeFromCart(itemId);
    }
  }

  void _deleteAllItems() {
    final appState = context.read<AppState>();
    appState.clearCart();
    setState(() {
      _selectAll = false;
    });
  }

  void _deleteItem(int itemId) {
    final appState = context.read<AppState>();
    appState.removeFromCart(itemId);
  }

  int _calculateTotalPrice(List<CartItem> cartItems) {
    return cartItems
        .where((item) => item.isSelected)
        .fold(
          0,
          (sum, item) => sum + (int.parse(item.product.price) * item.quantity),
        );
  }

  int _getSelectedItemCount(List<CartItem> cartItems) {
    return cartItems.where((item) => item.isSelected).length;
  }

  void _proceedToPayment(List<CartItem> cartItems) {
    final selectedItems = cartItems.where((item) => item.isSelected).toList();

    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('선택된 상품이 없습니다')));
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('결제 확인'),
        content: Text(
          '총 ${selectedItems.length}개 상품을 구매하시겠습니까?\n총 금액: ₩${PriceFormatter.formatPrice(_calculateTotalPrice(selectedItems))}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _completePayment(cartItems);
            },
            child: const Text('결제하기'),
          ),
        ],
      ),
    );
  }

  void _completePayment(List<CartItem> cartItems) {
    // 결제 완료 처리
    final selectedItems = cartItems.where((item) => item.isSelected).toList();
    final appState = context.read<AppState>();

    // 선택된 아이템들을 장바구니에서 제거
    for (final item in selectedItems) {
      if (item.id != null) {
        appState.removeFromCart(item.id!);
      }
    }

    setState(() {
      _selectAll = false;
    });

    // 결제 완료 다이얼로그
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 8),
            const Text('결제 완료'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('총 ${selectedItems.length}개 상품의 결제가 완료되었습니다.'),
            const SizedBox(height: 8),
            Text(
              '결제 금액: ₩${PriceFormatter.formatPrice(_calculateTotalPrice(selectedItems))}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // 장바구니 페이지도 닫기
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '장바구니',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          if (appState.cartItems.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    '장바구니가 비어있습니다',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // 전체 선택/삭제 헤더
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: _selectAll,
                      onChanged: (value) => _toggleSelectAll(),
                      activeColor: const Color(0xff1957ee),
                    ),
                    const Text(
                      '전체 선택',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _deleteAllItems,
                      child: const Text(
                        '전체 삭제',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 상품 목록
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: appState.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = appState.cartItems[index];
                    return _buildCartItem(item);
                  },
                ),
              ),

              // 결제 정보
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '결제 예상 금액',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '₩${PriceFormatter.formatPrice(_calculateTotalPrice(appState.cartItems))}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '배송비',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Text(
                          '₩0',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _proceedToPayment(appState.cartItems),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff1957ee),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          '구매하기 (${_getSelectedItemCount(appState.cartItems)})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 상단: 체크박스와 삭제 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Checkbox(
                value: item.isSelected,
                onChanged: (value) => _toggleItemSelection(item.id!),
                activeColor: const Color(0xff1957ee),
              ),
              IconButton(
                onPressed: () => _deleteItem(item.id!),
                icon: const Icon(Icons.delete_outline, color: Colors.grey),
                iconSize: 20,
              ),
            ],
          ),

          // 상품 정보
          Row(
            children: [
              // 상품 이미지
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(item.product.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // 상품 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 브랜드명
                    Text(
                      item.product.brandName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // 상품명
                    Text(
                      item.product.productName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // 가격
                    Text(
                      '₩${PriceFormatter.formatPriceString(item.product.price)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 옵션 정보
                    if (item.selectedOptions.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.selectedOptions,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 하단: 수량 조절
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '수량',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () =>
                          _updateQuantity(item.id!, item.quantity - 1),
                      icon: const Icon(Icons.remove, size: 18),
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          _updateQuantity(item.id!, item.quantity + 1),
                      icon: const Icon(Icons.add, size: 18),
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
