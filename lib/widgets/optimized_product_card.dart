import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/optimized_app_state.dart';
import '../pages/product_detail.dart';
import '../utils/price_formatter.dart';
import '../widgets/product_option_dialog.dart';
import 'optimized_image.dart';

/// 최적화된 상품 카드 위젯
class OptimizedProductCard extends StatelessWidget {
  final Product product;

  const OptimizedProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            spreadRadius: 0,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildProductImage(context), _buildProductInfo(context)],
      ),
    );
  }

  Widget _buildProductImage(BuildContext context) {
    return Expanded(
      flex: 3,
      child: GestureDetector(
        onTap: () => _navigateToDetail(context),
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              ),
              child: OptimizedImage(
                imageUrl: product.imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
              ),
            ),
            _buildFavoriteButton(context),
            _buildCartButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteButton(BuildContext context) {
    return Selector<OptimizedAppState, bool>(
      selector: (context, appState) => appState.isFavorite(product.id ?? 0),
      builder: (context, isFavorite, child) {
        return Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () {
              if (product.id != null) {
                context.read<OptimizedAppState>().toggleFavorite(product.id!);
              }
            },
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.grey[600],
                size: 16,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCartButton(BuildContext context) {
    return Positioned(
      bottom: 8,
      right: 8,
      child: GestureDetector(
        onTap: () {
          if (product.id != null) {
            _showOptionDialog(context);
          }
        },
        child: Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Icon(
            Icons.shopping_cart_outlined,
            color: Colors.grey[600],
            size: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildProductInfo(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBrandName(),
            _buildProductName(),
            _buildPrice(),
            _buildStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandName() {
    return Text(
      product.brandName,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildProductName() {
    return Text(
      product.productName,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildPrice() {
    final originalPrice = int.tryParse(product.price) ?? 0;
    final discountPercent = int.tryParse(product.discount) ?? 0;
    final discountedPrice = (originalPrice * (100 - discountPercent) / 100)
        .round();

    return Row(
      children: [
        Text(
          '${PriceFormatter.formatPrice(discountedPrice)}원',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        if (discountPercent > 0) ...[
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$discountPercent%',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStats() {
    return Selector<OptimizedAppState, String>(
      selector: (context, appState) =>
          appState.getFavoriteCount(product.id ?? 0),
      builder: (context, favoriteCount, child) {
        return Selector<OptimizedAppState, int>(
          selector: (context, appState) =>
              appState.getReviewCount(product.id ?? 0),
          builder: (context, reviewCount, child) {
            return Row(
              children: [
                Text(
                  '관심 $favoriteCount',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                const SizedBox(width: 8),
                Text(
                  '리뷰 $reviewCount',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProductDetail(product: product)),
    );
  }

  void _showOptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ProductOptionDialog(
        product: product,
        onAddToCart: (size, color, quantity) {
          // 장바구니에 추가 로직
          final selectedOptions = '사이즈: $size, 색상: $color';
          if (product.id != null) {
            context.read<OptimizedAppState>().addToCart(
              product.id!,
              quantity: quantity,
              selectedOptions: selectedOptions,
            );
          }
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
