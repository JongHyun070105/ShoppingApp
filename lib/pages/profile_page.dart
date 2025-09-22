import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/recent_view.dart';
import '../services/app_state.dart';
import 'setting.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '프로필',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 프로필 섹션
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // 프로필 이미지 (이미지와 동일한 산 이미지)
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: const NetworkImage(
                      'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=300',
                    ),
                  ),
                  const SizedBox(width: 16),
                  // 사용자 정보
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '홍길동',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Honggildong@gmail.com',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 빠른 액션 버튼들
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.account_balance_wallet_outlined,
                      label: '포인트',
                      value: '0',
                      color: const Color(0xff1957ee),
                    ),
                  ),
                  Container(width: 1, height: 50, color: Colors.grey[300]),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.local_offer_outlined,
                      label: '쿠폰',
                      value: '3',
                      color: const Color(0xff1957ee),
                    ),
                  ),
                  Container(width: 1, height: 50, color: Colors.grey[300]),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.local_shipping_outlined,
                      label: '주문/배송 조회',
                      value: '',
                      color: const Color(0xff1957ee),
                    ),
                  ),
                ],
              ),
            ),

            // 최근 본 상품 섹션
            Consumer<AppState>(
              builder: (context, appState, child) {
                if (appState.recentProducts.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Container(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '최근 본 상품',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      RecentView(products: appState.recentProducts),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    double? iconSize,
  }) {
    return SizedBox(
      height: 80, // 고정 높이 설정
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.black,
            size: iconSize ?? (value.isEmpty ? 32 : 28), // 값이 없으면 더 큰 아이콘
          ),
          const SizedBox(height: 8),
          if (value.isNotEmpty)
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            )
          else
            const SizedBox(height: 22), // 값이 없을 때 아이콘 크기에 맞춰 공간 확보
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
