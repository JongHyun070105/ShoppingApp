import 'package:flutter/material.dart';

class RecentSearchWidget extends StatelessWidget {
  final List<String> recentSearches;
  final Function(String) onSearchTap;
  final VoidCallback onDeleteAll;

  const RecentSearchWidget({
    super.key,
    required this.recentSearches,
    required this.onSearchTap,
    required this.onDeleteAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "최근 검색어",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff1957ee),
                ),
              ),
              GestureDetector(
                onTap: onDeleteAll,
                child: const Text(
                  "전체 삭제",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (recentSearches.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: recentSearches.map((search) {
                return GestureDetector(
                  onTap: () => onSearchTap(search),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                    ),
                    child: Text(
                      search,
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class PopularSearchWidget extends StatelessWidget {
  final List<String> popularSearches;
  final Function(String) onSearchTap;

  const PopularSearchWidget({
    super.key,
    required this.popularSearches,
    required this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "인기 검색어",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xff1957ee),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 왼쪽 컬럼
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: popularSearches
                      .asMap()
                      .entries
                      .where((entry) => entry.key < 5) // 1-5번
                      .map((entry) {
                        final index = entry.key + 1;
                        final search = entry.value;
                        return GestureDetector(
                          onTap: () => onSearchTap(search),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                  child: Text(
                                    '$index',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xff1957ee),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    search,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      })
                      .toList(),
                ),
              ),
              const SizedBox(width: 24),
              // 오른쪽 컬럼
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: popularSearches
                      .asMap()
                      .entries
                      .where((entry) => entry.key >= 5) // 6-10번
                      .map((entry) {
                        final index = entry.key + 1;
                        final search = entry.value;
                        return GestureDetector(
                          onTap: () => onSearchTap(search),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                  child: Text(
                                    '$index',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xff1957ee),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    search,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      })
                      .toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
