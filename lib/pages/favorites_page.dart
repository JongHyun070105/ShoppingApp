import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/optimized_app_state.dart';
import '../widgets/favorites_tab_bar.dart';
import '../widgets/product_card.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '즐겨찾기',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: FavoritesTabBar(tabController: _tabController),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildProductTab(), _buildStoreTab()],
      ),
    );
  }

  Widget _buildProductTab() {
    return Consumer<OptimizedAppState>(
      builder: (context, appState, child) {
        final favoriteProducts = appState.favoriteProducts;

        if (appState.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (favoriteProducts.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  '즐겨찾기한 상품이 없습니다',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  '하트를 눌러 상품을 즐겨찾기에 추가해보세요',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => appState.refresh(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.6,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: favoriteProducts.length,
              itemBuilder: (context, index) {
                final product = favoriteProducts[index];
                return ProductCard(product: product);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildStoreTab() {
    return const Center(
      child: Text(
        '스토어 즐겨찾기',
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }
}
