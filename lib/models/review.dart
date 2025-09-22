class Review {
  final int? id;
  final int productId;
  final String userName;
  final int rating;
  final String content;
  final DateTime createdAt;

  Review({
    this.id,
    required this.productId,
    required this.userName,
    required this.rating,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'user_name': userName,
      'rating': rating,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      productId: json['product_id'] ?? json['productId'] ?? 0,
      userName: json['user_name'] ?? json['userName'] ?? '',
      rating: json['rating'] ?? 0,
      content: json['content'] ?? '',
      createdAt: DateTime.parse(
        json['created_at'] ??
            json['createdAt'] ??
            DateTime.now().toIso8601String(),
      ),
    );
  }

  Review copyWith({
    int? id,
    int? productId,
    String? userName,
    int? rating,
    String? content,
    DateTime? createdAt,
  }) {
    return Review(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      userName: userName ?? this.userName,
      rating: rating ?? this.rating,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
