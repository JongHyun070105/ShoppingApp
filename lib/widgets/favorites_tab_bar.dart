import 'package:flutter/material.dart';

class FavoritesTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController tabController;

  const FavoritesTabBar({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: tabController,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: Colors.black, width: 3),
          insets: EdgeInsets.symmetric(horizontal: 0),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey,
        labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 16),
        tabs: const [
          Tab(text: '상품'),
          Tab(text: '스토어'),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
