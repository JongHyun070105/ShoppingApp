import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/optimized_app_state.dart';
import '../widgets/product_card.dart';
import '../models/product.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // 검색 상태를 페이지 내에서 관리
  String _searchQuery = '';
  List<Product> _searchResults = [];

  List<String> recentSearches = ["티셔츠", "후드티", "나이키", "가디건", "자켓", "청바지"];

  List<String> popularSearches = [
    "후드티",
    "바람막이",
    "바지",
    "롱슬리브",
    "니트",
    "자켓",
    "셔츠",
    "티셔츠",
    "후드집업",
    "반팔",
  ];

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    // 포커스가 벗어나도 검색하지 않음 - 사용자가 직접 검색할 때만 실행
  }

  void _performSearch() {
    final query = _searchController.text.trim();

    setState(() {
      _searchQuery = query;

      if (query.isNotEmpty) {
        // OptimizedAppState에서 모든 상품을 가져와서 검색
        final allProducts = context.read<OptimizedAppState>().allProducts;
        _searchResults = allProducts.where((product) {
          return product.productName.toLowerCase().contains(
                query.toLowerCase(),
              ) ||
              product.brandName.toLowerCase().contains(query.toLowerCase()) ||
              (product.category?.toLowerCase().contains(query.toLowerCase()) ??
                  false);
        }).toList();

        // 최근 검색어에 추가 (중복 제거)
        if (!recentSearches.contains(query)) {
          recentSearches.insert(0, query);
          if (recentSearches.length > 10) {
            recentSearches.removeLast();
          }
        }
      } else {
        _searchResults = [];
      }
    });
  }

  void handleSearchTap(String searchTerm) {
    _searchController.text = searchTerm;
    _performSearch(); // 검색 실행
  }

  void handleDeleteAll() {
    setState(() {
      recentSearches.clear();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _searchResults = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            textAlignVertical: TextAlignVertical.center,
            onSubmitted: (value) => _performSearch(),
            onChanged: (value) {
              setState(() {}); // UI 업데이트만 (검색하지 않음)
            },
            decoration: InputDecoration(
              hintText: '상품을 검색해보세요',
              hintStyle: const TextStyle(color: Colors.grey),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: _clearSearch,
                    )
                  : null,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // 검색어가 있으면 검색 결과 표시
          if (_searchQuery.isNotEmpty) ...[
            // 검색 결과 헤더
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    "'$_searchQuery' 검색 결과 ${_searchResults.length}개",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  TextButton(onPressed: _clearSearch, child: const Text('초기화')),
                ],
              ),
            ),
            // 검색 결과 상품 목록
            Expanded(
              child: _searchResults.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            '검색 결과가 없습니다',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '다른 검색어로 시도해보세요',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.6,
                          ),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final product = _searchResults[index];
                        return ProductCard(product: product);
                      },
                    ),
            ),
          ]
          // 검색어가 없으면 최근/인기 검색어 표시
          else ...[
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // 최근 검색어 섹션 (항상 표시)
                    _buildRecentSearchSection(),
                    // 인기 검색어 섹션
                    _buildPopularSearchSection(),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecentSearchSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '최근 검색어',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: handleDeleteAll,
                child: const Text(
                  '전체 삭제',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recentSearches.map((search) {
              return GestureDetector(
                onTap: () => handleSearchTap(search),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(search, style: const TextStyle(fontSize: 14)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularSearchSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '인기 검색어',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 48), // 최근 검색어와 레이아웃 맞추기
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: popularSearches.map((search) {
              return GestureDetector(
                onTap: () => handleSearchTap(search),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(search, style: const TextStyle(fontSize: 14)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
