import 'package:flutter/material.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '설정',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('도움말'),
          _buildMenuItem(
            icon: Icons.chat_bubble_outline,
            title: '1:1 문의 내역',
            onTap: () {
              // 1:1 문의 내역 페이지로 이동
            },
          ),
          _buildMenuItem(
            icon: Icons.headset_mic_outlined,
            title: '고객센터',
            onTap: () {
              // 고객센터 페이지로 이동
            },
          ),
          _buildMenuItem(
            icon: Icons.notifications_outlined,
            title: '공지사항',
            onTap: () {
              // 공지사항 페이지로 이동
            },
          ),

          const SizedBox(height: 24),

          _buildSectionTitle('약관 및 정책'),
          _buildMenuItem(
            icon: Icons.privacy_tip_outlined,
            title: '개인정보 처리방침',
            onTap: () {
              // 개인정보 처리방침 페이지로 이동
            },
          ),
          _buildMenuItem(
            icon: Icons.description_outlined,
            title: '서비스 이용 약관',
            onTap: () {
              // 서비스 이용 약관 페이지로 이동
            },
          ),

          const SizedBox(height: 24),

          _buildSectionTitle('계정'),
          _buildMenuItem(
            icon: Icons.logout,
            title: '로그아웃',
            titleColor: Colors.red,
            onTap: () {
              _showLogoutDialog(context);
            },
          ),

          const SizedBox(height: 32),

          // 앱 정보
          Center(
            child: Column(
              children: [
                Text(
                  'My Best Fit',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '버전 1.0.0',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8, top: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.grey[600]),
        title: Text(
          title,
          style: TextStyle(fontSize: 16, color: titleColor ?? Colors.black87),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
        onTap: onTap,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('로그아웃'),
          content: const Text('정말로 로그아웃하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // 로그아웃 로직 구현
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('로그아웃되었습니다')));
              },
              child: const Text('로그아웃', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
