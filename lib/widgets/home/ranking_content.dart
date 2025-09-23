import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/optimized_app_state.dart';
import '../popular_products_section.dart';

/// 랭킹 화면의 콘텐츠를 담당하는 위젯
class RankingContent extends StatelessWidget {
  const RankingContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OptimizedAppState>(
      builder: (context, appState, child) {
        if (appState.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [_buildHeader(), _buildPopularProductsSection(appState)],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Text(
        '랭킹 상품',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPopularProductsSection(OptimizedAppState appState) {
    return PopularProductsSection(products: appState.popularProducts);
  }
}
