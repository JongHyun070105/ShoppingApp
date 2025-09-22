import 'product.dart';

class CartItem {
  final int? id;
  final int userId;
  final int productId;
  final Product product;
  int quantity;
  final String selectedOptions;
  bool isSelected;
  final DateTime createdAt;
  final DateTime updatedAt;

  CartItem({
    this.id,
    required this.userId,
    required this.productId,
    required this.product,
    required this.quantity,
    required this.selectedOptions,
    this.isSelected = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CartItem.fromJson(Map<String, dynamic> json, Product product) {
    return CartItem(
      id: json['id'],
      userId: json['user_id'] ?? json['userId'] ?? 1,
      productId: json['product_id'] ?? json['productId'] ?? 0,
      product: product,
      quantity: json['quantity'] ?? 1,
      selectedOptions:
          json['selected_options'] ?? json['selectedOptions'] ?? '',
      isSelected: json['is_selected'] == true || json['isSelected'] == true,
      createdAt: DateTime.parse(
        json['created_at'] ??
            json['createdAt'] ??
            DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ??
            json['updatedAt'] ??
            DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'quantity': quantity,
      'selected_options': selectedOptions,
      'is_selected': isSelected,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  CartItem copyWith({
    int? id,
    int? userId,
    int? productId,
    Product? product,
    int? quantity,
    String? selectedOptions,
    bool? isSelected,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedOptions: selectedOptions ?? this.selectedOptions,
      isSelected: isSelected ?? this.isSelected,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
