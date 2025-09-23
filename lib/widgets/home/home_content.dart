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
  const HomeContent({super.key});

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

        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification notification) {
            // 스크롤 이벤트만 차단하고 터치 이벤트는 전달
            if (notification is ScrollStartNotification ||
                notification is ScrollUpdateNotification ||
                notification is ScrollEndNotification) {
              return true; // 스크롤 이벤트 차단
            }
            return false; // 다른 이벤트는 전달
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildPromoSection(),
                _buildCategorySection(),
                _buildPopularProductsSection(appState),
              ],
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
