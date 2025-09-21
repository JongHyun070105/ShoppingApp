import 'package:flutter/material.dart';
import 'product_card.dart';

class PopularProductsSection extends StatelessWidget {
  final List<Map<String, dynamic>> products;

  const PopularProductsSection({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '인기 상품',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.65,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(
                brandName: product['brandName'],
                productName: product['productName'],
                discount: product['discount'],
                price: product['price'],
                imageUrl: product['imageUrl'],
                likes: product['likes'],
                reviews: product['reviews'],
              );
            },
          ),
        ],
      ),
    );
  }
}
