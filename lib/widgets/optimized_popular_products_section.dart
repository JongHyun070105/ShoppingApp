import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/optimized_app_state.dart';
import 'optimized_product_grid.dart';

/// 최적화된 인기 상품 섹션
class OptimizedPopularProductsSection extends StatelessWidget {
  final List<Product> products;

  const OptimizedPopularProductsSection({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return Selector<OptimizedAppState, String>(
      selector: (context, appState) => appState.selectedCategory,
      builder: (context, selectedCategory, child) {
        final title = selectedCategory == '전체'
            ? '인기 상품'
            : '$selectedCategory 인기상품';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            OptimizedProductGrid(
              products: products,
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.6,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            ),
          ],
        );
      },
    );
  }
}

