import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../services/app_state.dart';
import '../widgets/custom_tab_bar.dart';
import '../widgets/promo_carousel.dart';
import '../widgets/category_grid.dart';
import '../widgets/popular_products_section.dart';
import '../widgets/recent_view.dart';
import 'search_page.dart';
import 'favorites_page.dart';
import 'profile_page.dart';
import 'cart_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  int _currentIndex = 0;
  late TabController _tabController;

  List<String> carouselImages = [
    "https://img.freepik.com/free-psd/fashion-clothes-banner-template_23-2148578502.jpg",
    "https://img.freepik.com/free-psd/sale-banner-template_23-2147516499.jpg",
    "https://img.freepik.com/free-psd/fashion-sale-banner-template_23-2148582268.jpg",
  ];

  final List<Map<String, dynamic>> categories = [
    {'name': '티셔츠', 'icon': Icons.checkroom, 'color': Colors.blue},
    {'name': '셔츠', 'icon': Icons.directions_walk, 'color': Colors.green},
    {'name': '후드', 'icon': Icons.watch, 'color': Colors.orange},
    {'name': '아우터', 'icon': Icons.shopping_bag, 'color': Colors.purple},
    {'name': '바람막이', 'icon': Icons.face, 'color': Colors.pink},
    {'name': '청바지', 'icon': Icons.sports, 'color': Colors.red},
    {'name': '반바지', 'icon': Icons.checkroom, 'color': Colors.blue},
    {'name': '바지', 'icon': Icons.directions_walk, 'color': Colors.green},
    {'name': '신발', 'icon': Icons.watch, 'color': Colors.orange},
    {'name': '액세서리', 'icon': Icons.shopping_bag, 'color': Colors.purple},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addObserver(this);

    // 앱 상태 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 앱이 다시 활성화될 때 최근 상품 새로고침
      context.read<AppState>().refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [HomeTab(), SearchPage(), FavoritesPage(), ProfilePage()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: const Color(0xff1957ee),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: '검색'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: '즐겨찾기'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '프로필'),
        ],
      ),
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with TickerProviderStateMixin {
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
          'My Best Fit',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {},
          ),
          Consumer<AppState>(
            builder: (context, appState, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CartPage(),
                        ),
                      );
                    },
                  ),
                  if (appState.cartItemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${appState.cartItemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: CustomTabBar(tabController: _tabController),
        ),
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          if (appState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // 홈 탭
              RefreshIndicator(
                onRefresh: () => appState.refresh(),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // 프로모션 캐러셀
                      PromoCarousel(
                        images: [
                          "https://img.freepik.com/free-psd/fashion-clothes-banner-template_23-2148578502.jpg",
                          "https://images.jkn.co.kr/data/images/full/904120/g-_-600-jpg.jpg?w=600",
                          "https://cdn.news2day.co.kr/data2/content/image/2019/09/23/20190923306831.jpg",
                        ],
                        carouselController: CarouselSliderController(),
                        onPageChanged: (index, reason) {},
                      ),

                      // 카테고리 그리드
                      CategoryGrid(
                        categories: [
                          {
                            'name': '전체',
                            'icon': Icons.apps,
                            'color': Colors.grey[300]!,
                            'imageUrl': null,
                          },
                          {
                            'name': '티셔츠',
                            'icon': Icons.checkroom,
                            'color': Colors.blue,
                            'imageUrl':
                                'https://img.pikbest.com/photo/20250722/black-plain-t-shirt-on-white-background_11801689.jpg!w700wp',
                          },
                          {
                            'name': '셔츠',
                            'icon': Icons.business,
                            'color': Colors.green,
                            'imageUrl':
                                'https://gdimg.gmarket.co.kr/3547131014/still/280?ver=1720253379',
                          },
                          {
                            'name': '후드',
                            'icon': Icons.star,
                            'color': Colors.orange,
                            'imageUrl':
                                'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=200&h=200&fit=crop&crop=center',
                          },
                          {
                            'name': '아우터',
                            'icon': Icons.ac_unit,
                            'color': Colors.purple,
                            'imageUrl':
                                'https://images.unsplash.com/photo-1544022613-e87ca75a784a?w=200&h=200&fit=crop&crop=center',
                          },
                          {
                            'name': '바람막이',
                            'icon': Icons.wind_power,
                            'color': Colors.pink,
                            'imageUrl':
                                'https://images.unsplash.com/photo-1544966503-7cc5ac882d5f?w=200&h=200&fit=crop&crop=center',
                          },
                          {
                            'name': '청바지',
                            'icon': Icons.directions_walk,
                            'color': Colors.indigo,
                            'imageUrl':
                                'https://images.unsplash.com/photo-1542272604-787c3835535d?w=200&h=200&fit=crop&crop=center',
                          },
                          {
                            'name': '반바지',
                            'icon': Icons.short_text,
                            'color': Colors.teal,
                            'imageUrl':
                                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQp7GGg_MgotkuMGdIhRD0PFgg2czdfRwjPBQ&s',
                          },
                          {
                            'name': '바지',
                            'icon': Icons.straighten,
                            'color': Colors.brown,
                            'imageUrl':
                                'https://us.123rf.com/450wm/vitalily73/vitalily732003/vitalily73200300794/143245173-black-pants-isolated-on-white-background-fashion-men-s-trousers-top-view.jpg?ver=6',
                          },
                          {
                            'name': '신발',
                            'icon': Icons.directions_run,
                            'color': Colors.red,
                            'imageUrl':
                                'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=200&h=200&fit=crop&crop=center',
                          },
                          {
                            'name': '액세서리',
                            'icon': Icons.diamond,
                            'color': Colors.amber,
                            'imageUrl':
                                'https://images.unsplash.com/photo-1511499767150-a48a237f0083?w=200&h=200&fit=crop&crop=center',
                          },
                        ],
                      ),

                      // 인기 상품
                      PopularProductsSection(products: appState.allProducts),
                    ],
                  ),
                ),
              ),
              // 랭킹 탭
              RefreshIndicator(
                onRefresh: () => appState.refresh(),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          '랭킹 상품',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      PopularProductsSection(products: appState.allProducts),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
