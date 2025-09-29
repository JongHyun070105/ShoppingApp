import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/optimized_app_state.dart';
import '../constants/app_constants.dart';
import '../widgets/home/home_header.dart';
import '../widgets/home/home_tab_bar.dart';
import '../widgets/home/home_content.dart';
import '../widgets/home/ranking_content.dart';
import 'search_page.dart';
import 'favorites_page.dart';
import 'profile_page.dart';

/// 메인 페이지 - 앱의 메인 네비게이션을 담당
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  int _currentIndex = 0;
  late TabController _tabController;
  bool isMore = false;
  late ScrollController _homeScrollController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _homeScrollController = ScrollController();
    WidgetsBinding.instance.addObserver(this);

    // 앱 상태 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OptimizedAppState>().initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _homeScrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 앱이 다시 활성화될 때 최근 상품 새로고침
      context.read<OptimizedAppState>().refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeTab(scrollController: _homeScrollController),
          const SearchPage(),
          const FavoritesPage(),
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _currentIndex == 0 ? _buildScrollToTopFAB() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
    );
  }

  Widget _buildScrollToTopFAB() {
    return FloatingActionButton(
      onPressed: () {
        // HomeTab의 스크롤 컨트롤러를 통해 맨 위로 스크롤
        _scrollToTop();
      },
      backgroundColor: const Color(AppConstants.primaryColorValue),
      foregroundColor: Colors.white,
      mini: true,
      elevation: 4,
      child: const Icon(Icons.keyboard_arrow_up, size: 24),
    );
  }

  void _scrollToTop() {
    // 직접 스크롤 컨트롤러를 사용하여 맨 위로 스크롤
    if (_homeScrollController.hasClients) {
      _homeScrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }

  Widget _buildBottomNavigationBar() {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: const Color(AppConstants.primaryColorValue),
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

/// 홈 탭 - 메인 페이지의 홈 섹션
class HomeTab extends StatefulWidget {
  final ScrollController scrollController;

  const HomeTab({super.key, required this.scrollController});

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

  void scrollToTop() {
    widget.scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const HomeHeader(),
      body: Column(
        children: [
          HomeTabBar(tabController: _tabController),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                HomeContent(scrollController: widget.scrollController),
                RankingContent(scrollController: widget.scrollController),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
