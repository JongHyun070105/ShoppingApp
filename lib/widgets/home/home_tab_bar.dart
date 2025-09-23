import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

/// 홈 화면의 탭바를 담당하는 위젯
class HomeTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController tabController;

  const HomeTabBar({super.key, required this.tabController});

  @override
  Size get preferredSize => const Size.fromHeight(40);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: TabBar(
        controller: tabController,
        labelColor: const Color(AppConstants.primaryColorValue),
        unselectedLabelColor: Colors.grey,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(
            color: Color(AppConstants.primaryColorValue),
            width: 3,
          ),
          insets: EdgeInsets.symmetric(horizontal: 0),
        ),
        tabs: const [
          Tab(text: '홈'),
          Tab(text: '랭킹'),
        ],
      ),
    );
  }
}
