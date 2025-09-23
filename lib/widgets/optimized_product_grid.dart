import 'package:flutter/material.dart';
import '../models/product.dart';
import 'product_card.dart';

/// 최적화된 상품 그리드 위젯
class OptimizedProductGrid extends StatelessWidget {
  final List<Product> products;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;
  final EdgeInsetsGeometry? padding;

  const OptimizedProductGrid({
    super.key,
    required this.products,
    this.crossAxisCount = 2,
    this.crossAxisSpacing = 12,
    this.mainAxisSpacing = 12,
    this.childAspectRatio = 0.6,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const _EmptyState();
    }

    return Padding(
      padding: padding ?? const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        // 그리드 설정
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
          childAspectRatio: childAspectRatio,
        ),

        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          // const 생성자 사용으로 불필요한 리빌드 방지
          return ProductCard(product: product);
        },
      ),
    );
  }
}

/// 빈 상태 표시 위젯
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '상품이 없습니다',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
