import 'package:flutter/material.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

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
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: const Center(
        child: Text('즐겨찾기 페이지', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
