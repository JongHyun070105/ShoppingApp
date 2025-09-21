import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'widgets/custom_tab_bar.dart';
import 'widgets/promo_carousel.dart';
import 'widgets/category_grid.dart';
import 'widgets/popular_products_section.dart';
import 'pages/search_page.dart';
import 'pages/favorites_page.dart';
import 'pages/profile_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Best Fit',
      theme: ThemeData(primarySwatch: Colors.green, fontFamily: 'Roboto'),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  int _currentIndex = 0;
  int _currentCarousel = 0;
  final int _selectedTab = 0; // 홈(0) 또는 랭킹(1)
  late TabController _tabController;

  final CarouselSliderController _carouselController =
      CarouselSliderController();

  List<String> carouselImages = [
    "https://img.freepik.com/free-psd/fashion-clothes-banner-template_23-2148578502.jpg",
    "https://cdn.news2day.co.kr/data2/content/image/2019/09/23/20190923306831.jpg",
    "https://images.jkn.co.kr/data/images/full/904120/g-_-600-jpg.jpg?w=600",
  ];

  List<Map<String, dynamic>> categories = [
    {'name': '티셔츠', 'icon': Icons.checkroom, 'color': Colors.black},
    {'name': '셔츠', 'icon': Icons.checkroom, 'color': Colors.blue},
    {'name': '후드', 'icon': Icons.checkroom, 'color': Colors.grey},
    {'name': '아우터', 'icon': Icons.checkroom, 'color': Colors.brown},
    {'name': '바람막이', 'icon': Icons.checkroom, 'color': Colors.black},
    {'name': '청바지', 'icon': Icons.checkroom, 'color': Colors.blue},
    {'name': '반바지', 'icon': Icons.checkroom, 'color': Colors.black},
    {'name': '바지', 'icon': Icons.checkroom, 'color': Colors.grey},
    {'name': '신발', 'icon': Icons.sports_soccer, 'color': Colors.white},
    {'name': '액세서리', 'icon': Icons.diamond, 'color': Colors.pink},
  ];

  List<Map<String, dynamic>> popularProducts = [
    {
      'brandName': '투데이무드',
      'productName': '콜린 니트 맨투맨',
      'discount': '39',
      'price': '59,000',
      'imageUrl':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300',
      'likes': '999+',
      'reviews': '120',
    },
    {
      'brandName': '스타일리시',
      'productName': '베이직 후드티',
      'discount': '25',
      'price': '39,000',
      'imageUrl':
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=300',
      'likes': '756',
      'reviews': '89',
    },
    {
      'brandName': '트렌디웨어',
      'productName': '데님 셔츠',
      'discount': '30',
      'price': '49,000',
      'imageUrl':
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300',
      'likes': '432',
      'reviews': '67',
    },
    {
      'brandName': '모던스타일',
      'productName': '오버핏 스웨터',
      'discount': '20',
      'price': '69,000',
      'imageUrl':
          'https://images.unsplash.com/photo-1519345182560-3f2917c472ef?w=300',
      'likes': '321',
      'reviews': '45',
    },
  ];

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
      body: SafeArea(child: _buildCurrentPage()),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return const SearchPage();
      case 2:
        return const FavoritesPage();
      case 3:
        return const ProfilePage();
      default:
        return _buildHomePage();
    }
  }

  Widget _buildHomePage() {
    return Column(
      children: [
        _buildHeader(),
        CustomTabBar(tabController: _tabController),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildHomeContent(), _buildRankingContent()],
          ),
        ),
      ],
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          PromoCarousel(
            carouselController: _carouselController,
            images: carouselImages,
            onPageChanged: (index, reason) {
              setState(() {
                _currentCarousel = index;
              });
            },
          ),
          CategoryGrid(categories: categories),
          PopularProductsSection(products: popularProducts),
        ],
      ),
    );
  }

  Widget _buildRankingContent() {
    return const Center(
      child: Text(
        '랭킹',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Stack(
        children: [
          // 중앙 정렬된 타이틀
          Center(
            child: Text(
              'My Best Fit',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          // 오른쪽 장바구니 아이콘
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: Icon(Icons.shopping_cart, color: Colors.black, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: '검색'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: '즐겨찾기'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: '프로필'),
      ],
    );
  }
}
