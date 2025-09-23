import 'package:flutter/material.dart';
import '../models/product.dart';

/// 검색 관련 데이터와 로직을 관리하는 서비스
class SearchService extends ChangeNotifier {
  String _searchQuery = '';
  List<Product> _searchResults = [];
  final List<String> _recentSearches = [
    "티셔츠",
    "후드티",
    "나이키",
    "가디건",
    "자켓",
    "청바지",
  ];

  static const List<String> _popularSearches = [
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

  // Getters
  String get searchQuery => _searchQuery;
  List<Product> get searchResults => _searchResults;
  List<String> get recentSearches => _recentSearches;
  List<String> get popularSearches => _popularSearches;
  bool get hasSearchQuery => _searchQuery.isNotEmpty;

  // 검색 실행
  void performSearch(String query, List<Product> allProducts) {
    _searchQuery = query.trim();

    if (_searchQuery.isNotEmpty) {
      // 모든 상품에서 검색
      _searchResults = allProducts.where((product) {
        final searchTerm = _searchQuery.toLowerCase();
        return product.productName.toLowerCase().contains(searchTerm) ||
            product.brandName.toLowerCase().contains(searchTerm) ||
            (product.category?.toLowerCase().contains(searchTerm) ?? false);
      }).toList();

      // 최근 검색어에 추가 (중복 제거)
      _addToRecentSearches(_searchQuery);
    } else {
      _searchResults = [];
    }

    notifyListeners();
  }

  // 검색어 초기화
  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    notifyListeners();
  }

  // 검색어로 바로 검색 (최근/인기 검색어 클릭 시)
  void searchWithTerm(String searchTerm, List<Product> allProducts) {
    performSearch(searchTerm, allProducts);
  }

  // 최근 검색어에 추가
  void _addToRecentSearches(String query) {
    if (!_recentSearches.contains(query)) {
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 10) {
        _recentSearches.removeLast();
      }
      notifyListeners();
    }
  }

  // 최근 검색어 전체 삭제
  void clearRecentSearches() {
    _recentSearches.clear();
    notifyListeners();
  }

  // 최근 검색어에서 특정 항목 삭제
  void removeRecentSearch(String searchTerm) {
    _recentSearches.remove(searchTerm);
    notifyListeners();
  }

  // 검색 결과가 비어있는지 확인
  bool get isSearchEmpty => _searchResults.isEmpty && _searchQuery.isNotEmpty;

  // 검색 결과 개수
  int get searchResultCount => _searchResults.length;

  // 검색 통계 정보
  Map<String, dynamic> getSearchStats() {
    return {
      'query': _searchQuery,
      'resultCount': _searchResults.length,
      'hasResults': !isSearchEmpty,
      'recentSearchCount': _recentSearches.length,
    };
  }
}
