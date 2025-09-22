import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductOptionDialog extends StatefulWidget {
  final Product product;
  final Function(String size, String color, int quantity) onAddToCart;

  const ProductOptionDialog({
    super.key,
    required this.product,
    required this.onAddToCart,
  });

  @override
  State<ProductOptionDialog> createState() => _ProductOptionDialogState();
}

class _ProductOptionDialogState extends State<ProductOptionDialog> {
  String? _selectedSize;
  String? _selectedColor;
  int _quantity = 1;

  final List<String> _sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
  final List<String> _colors = ['블랙', '화이트', '네이비', '그레이', '베이지', '레드', '블루'];

  @override
  void initState() {
    super.initState();
    // 기본값 설정
    _selectedSize = _sizes[2]; // M 사이즈
    _selectedColor = _colors[0]; // 블랙
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        color: Colors.white,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  // 상품 이미지
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(widget.product.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 상품 정보
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.brandName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.product.productName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₩${widget.product.price}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // 옵션 선택
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 사이즈 선택
                    _buildOptionSection(
                      title: '사이즈',
                      options: _sizes,
                      selectedValue: _selectedSize,
                      onChanged: (value) {
                        setState(() {
                          _selectedSize = value;
                        });
                      },
                    ),

                    const SizedBox(height: 24),

                    // 색상 선택
                    _buildOptionSection(
                      title: '색상',
                      options: _colors,
                      selectedValue: _selectedColor,
                      onChanged: (value) {
                        setState(() {
                          _selectedColor = value;
                        });
                      },
                    ),

                    const SizedBox(height: 24),

                    // 수량 선택
                    _buildQuantitySection(),
                  ],
                ),
              ),
            ),

            // 하단 버튼들
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                children: [
                  // 수량 표시
                  Expanded(
                    child: Text(
                      '총 $_quantity개',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 장바구니 담기 버튼
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _selectedSize != null && _selectedColor != null
                          ? () {
                              final selectedOptions =
                                  '$_selectedColor $_selectedSize';
                              widget.onAddToCart(
                                _selectedSize!,
                                _selectedColor!,
                                _quantity,
                              );
                              Navigator.pop(context);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff1957ee),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        '장바구니 담기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionSection({
    required String title,
    required List<String> options,
    required String? selectedValue,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selectedValue == option;
            return GestureDetector(
              onTap: () => onChanged(option),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xff1957ee)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xff1957ee)
                        : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuantitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '수량',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // 수량 감소 버튼
            GestureDetector(
              onTap: _quantity > 1
                  ? () {
                      setState(() {
                        _quantity--;
                      });
                    }
                  : null,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _quantity > 1 ? Colors.grey[100] : Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Icon(
                  Icons.remove,
                  color: _quantity > 1 ? Colors.black87 : Colors.grey,
                ),
              ),
            ),
            // 수량 표시
            Container(
              width: 80,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Center(
                child: Text(
                  '$_quantity',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            // 수량 증가 버튼
            GestureDetector(
              onTap: () {
                setState(() {
                  _quantity++;
                });
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: const Icon(Icons.add, color: Colors.black87),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
