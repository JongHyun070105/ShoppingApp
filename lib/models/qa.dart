class Qa {
  final int? id;
  final int productId;
  final String question;
  final String? answer;
  final String userName;
  final DateTime createdAt;
  final DateTime? answeredAt;

  Qa({
    this.id,
    required this.productId,
    required this.question,
    this.answer,
    required this.userName,
    required this.createdAt,
    this.answeredAt,
  });

  bool get isAnswered => answer != null && answer!.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'question': question,
      'answer': answer,
      'user_name': userName,
      'created_at': createdAt.toIso8601String(),
      'answered_at': answeredAt?.toIso8601String(),
    };
  }

  factory Qa.fromJson(Map<String, dynamic> json) {
    return Qa(
      id: json['id'],
      productId: json['product_id'] ?? json['productId'] ?? 0,
      question: json['question'] ?? '',
      answer: json['answer'],
      userName: json['user_name'] ?? json['userName'] ?? '',
      createdAt: DateTime.parse(
        json['created_at'] ??
            json['createdAt'] ??
            DateTime.now().toIso8601String(),
      ),
      answeredAt: json['answered_at'] != null || json['answeredAt'] != null
          ? DateTime.parse(json['answered_at'] ?? json['answeredAt'])
          : null,
    );
  }

  Qa copyWith({
    int? id,
    int? productId,
    String? question,
    String? answer,
    String? userName,
    DateTime? createdAt,
    DateTime? answeredAt,
  }) {
    return Qa(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      userName: userName ?? this.userName,
      createdAt: createdAt ?? this.createdAt,
      answeredAt: answeredAt ?? this.answeredAt,
    );
  }
}
