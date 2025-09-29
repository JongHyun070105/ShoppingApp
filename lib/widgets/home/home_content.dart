import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../services/optimized_app_state.dart';
import '../../constants/app_constants.dart';
import '../category_grid.dart';
import '../popular_products_section.dart';
import '../promo_carousel.dart';

/// 홈 화면의 메인 콘텐츠를 담당하는 위젯
class HomeContent extends StatelessWidget {
  final ScrollController? scrollController;

  const HomeContent({super.key, this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Consumer<OptimizedAppState>(
      builder: (context, appState, child) {
        // 초기 로딩 시 카테고리 그리드만 먼저 표시
        if (appState.isLoading && appState.allProducts.isEmpty) {
          return NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              if (notification is ScrollStartNotification ||
                  notification is ScrollUpdateNotification ||
                  notification is ScrollEndNotification) {
                return true;
              }
              return false;
            },
            child: SingleChildScrollView(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildPromoSection(),
                  _buildCategorySection(), // 카테고리는 먼저 표시
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            // Pull to Refresh - 데이터 새로고침
            await appState.refresh();
            // 새로고침 후 스크롤을 맨 위로 이동
            if (scrollController?.hasClients == true) {
              scrollController?.animateTo(
                0.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          },
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              // 무한 스크롤 감지
              if (notification is ScrollUpdateNotification) {
                final position = notification.metrics;
                if (position.pixels >= position.maxScrollExtent - 200) {
                  // 스크롤이 끝에서 200px 전에 도달하면 더 많은 데이터 로드
                  if (appState.hasMoreData && !appState.isLoadingMore) {
                    appState.loadMoreProducts();
                  }
                }
              }
              return false; // 이벤트를 계속 전달
            },
            child: SingleChildScrollView(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildPromoSection(),
                  _buildCategorySection(),
                  _buildPopularProductsSection(appState),
                  // 하단 로딩 인디케이터
                  _buildBottomLoadingIndicator(appState),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPromoSection() {
    return PromoCarousel(
      images: const [
        "https://img.freepik.com/free-psd/fashion-clothes-banner-template_23-2148578502.jpg",
        "https://images.jkn.co.kr/data/images/full/904120/g-_-600-jpg.jpg?w=600",
        "https://cdn.news2day.co.kr/data2/content/image/2019/09/23/20190923306831.jpg",
      ],
      carouselController: CarouselSliderController(),
      onPageChanged: (index, reason) {
        // TODO: 페이지 변경 시 로직 구현
      },
    );
  }

  Widget _buildCategorySection() {
    return CategoryGrid(categories: _getCategoryData());
  }

  Widget _buildPopularProductsSection(OptimizedAppState appState) {
    return PopularProductsSection(products: appState.popularProducts);
  }

  Widget _buildBottomLoadingIndicator(OptimizedAppState appState) {
    return Column(
      children: [
        // 무한 스크롤 로딩 인디케이터
        if (appState.isLoadingMore)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text(
                    '더 많은 상품을 불러오는 중...',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        // 더 이상 데이터가 없을 때 표시
        if (!appState.hasMoreData && appState.allProducts.isNotEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                '모든 상품을 불러왔습니다',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
          ),
      ],
    );
  }

  List<Map<String, dynamic>> _getCategoryData() {
    return [
      {
        'name': '전체',
        'icon': Icons.apps,
        'color': Colors.grey[300]!,
        'imageUrl': null,
      },
      ...CategoryConstants.categories.skip(1).map((category) {
        return {
          'name': category,
          'icon': _getCategoryIcon(category),
          'color': _getCategoryColor(category),
          'imageUrl': _getCategoryImageUrl(category),
        };
      }),
    ];
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '티셔츠':
        return Icons.checkroom;
      case '셔츠':
        return Icons.business;
      case '후드':
        return Icons.star;
      case '아우터':
        return Icons.ac_unit;
      case '바람막이':
        return Icons.wind_power;
      case '청바지':
        return Icons.directions_walk;
      case '반바지':
        return Icons.short_text;
      case '바지':
        return Icons.straighten;
      case '신발':
        return Icons.directions_run;
      case '액세서리':
        return Icons.diamond;
      default:
        return Icons.category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '티셔츠':
        return Colors.blue;
      case '셔츠':
        return Colors.green;
      case '후드':
        return Colors.orange;
      case '아우터':
        return Colors.purple;
      case '바람막이':
        return Colors.pink;
      case '청바지':
        return Colors.indigo;
      case '반바지':
        return Colors.teal;
      case '바지':
        return Colors.brown;
      case '신발':
        return Colors.red;
      case '액세서리':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  String? _getCategoryImageUrl(String category) {
    switch (category) {
      case '티셔츠':
        return 'https://img.pikbest.com/photo/20250722/black-plain-t-shirt-on-white-background_11801689.jpg!w700wp';
      case '셔츠':
        return 'https://gdimg.gmarket.co.kr/3547131014/still/280?ver=1720253379';
      case '후드':
        return 'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=200&h=200&fit=crop&crop=center';
      case '아우터':
        return 'https://images.unsplash.com/photo-1544022613-e87ca75a784a?w=200&h=200&fit=crop&crop=center';
      case '바람막이':
        return 'https://common.image.cf.marpple.co/files/u_3928552/2024/4/original/044ad8664c9b94b7a4aa099c94efbe7581e018271.png?w=200&h=200&fit=crop&crop=center';
      case '청바지':
        return 'https://images.unsplash.com/photo-1542272604-787c3835535d?w=200&h=200&fit=crop&crop=center';
      case '반바지':
        return 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQp7GGg_MgotkuMGdIhRD0PFgg2czdfRwjPBQ&s';
      case '바지':
        return 'https://us.123rf.com/450wm/vitalily73/vitalily732003/vitalily73200300794/143245173-black-pants-isolated-on-white-background-fashion-men-s-trousers-top-view.jpg?ver=6';
      case '신발':
        return 'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=200&h=200&fit=crop&crop=center';
      case '액세서리':
        return 'https://images.unsplash.com/photo-1511499767150-a48a237f0083?w=200&h=200&fit=crop&crop=center';
      default:
        return null;
    }
  }
}
