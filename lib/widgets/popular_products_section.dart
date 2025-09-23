import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'product_card.dart';
import '../models/product.dart';
import '../services/optimized_app_state.dart';

class PopularProductsSection extends StatelessWidget {
  final List<Product> products;

  const PopularProductsSection({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return Consumer<OptimizedAppState>(
      builder: (context, appState, child) {
        final selectedCategory = appState.selectedCategory;
        final title = selectedCategory == '전체'
            ? '인기 상품'
            : '$selectedCategory 인기상품';

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.6,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ProductCard(product: product);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
