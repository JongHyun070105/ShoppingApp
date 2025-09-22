class Product {
  final int? id;
  final String brandName;
  final String productName;
  final String discount;
  final String price;
  final String imageUrl;
  final String likes;
  final String reviews;
  final bool isFavorite;
  final String? category;

  Product({
    this.id,
    required this.brandName,
    required this.productName,
    required this.discount,
    required this.price,
    required this.imageUrl,
    required this.likes,
    required this.reviews,
    this.isFavorite = false,
    this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand_name': brandName,
      'product_name': productName,
      'discount': discount,
      'price': price,
      'image_url': imageUrl,
      'likes': likes,
      'reviews': reviews,
      'is_favorite': isFavorite,
      'category': category,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      brandName: json['brand_name'] ?? json['brandName'] ?? '',
      productName: json['product_name'] ?? json['productName'] ?? '',
      discount: json['discount']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      imageUrl: json['image_url'] ?? json['imageUrl'] ?? '',
      likes: json['likes']?.toString() ?? '',
      reviews: json['reviews']?.toString() ?? '',
      isFavorite: json['is_favorite'] == true || json['isFavorite'] == true,
      category: json['category'],
    );
  }

  Product copyWith({
    int? id,
    String? brandName,
    String? productName,
    String? discount,
    String? price,
    String? imageUrl,
    String? likes,
    String? reviews,
    bool? isFavorite,
    String? category,
  }) {
    return Product(
      id: id ?? this.id,
      brandName: brandName ?? this.brandName,
      productName: productName ?? this.productName,
      discount: discount ?? this.discount,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      likes: likes ?? this.likes,
      reviews: reviews ?? this.reviews,
      isFavorite: isFavorite ?? this.isFavorite,
      category: category ?? this.category,
    );
  }
}
