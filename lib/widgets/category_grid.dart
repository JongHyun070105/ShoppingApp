import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/optimized_app_state.dart';

class CategoryGrid extends StatelessWidget {
  final List<Map<String, dynamic>> categories;

  const CategoryGrid({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.8,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Consumer<OptimizedAppState>(
            builder: (context, appState, child) {
              final isSelected = appState.selectedCategory == category['name'];
              return GestureDetector(
                onTap: () {
                  appState.setCategory(category['name']);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        border: isSelected
                            ? Border.all(
                                color: const Color(0xff1957ee),
                                width: 3,
                              )
                            : Border.all(color: Colors.grey[300]!, width: 1),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(
                                    0xff1957ee,
                                  ).withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: category['imageUrl'] != null
                            ? Image.network(
                                category['imageUrl'],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xff1957ee)
                                          : category['color'],
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: Icon(
                                      category['icon'],
                                      color: isSelected
                                          ? Colors.white
                                          : (category['color'] == Colors.white
                                                ? Colors.black
                                                : Colors.white),
                                      size: 20,
                                    ),
                                  );
                                },
                              )
                            : Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xff1957ee)
                                      : category['color'],
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Icon(
                                  category['icon'],
                                  color: isSelected
                                      ? Colors.white
                                      : (category['color'] == Colors.white
                                            ? Colors.black
                                            : Colors.white),
                                  size: 20,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      category['name'],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: isSelected
                            ? const Color(0xff1957ee)
                            : Colors.black,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
