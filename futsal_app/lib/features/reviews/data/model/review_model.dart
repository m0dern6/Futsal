class ReviewModel {
  final String id;
  final String userId;
  final String groundId;
  final String comment;
  final int rating;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.groundId,
    required this.comment,
    required this.rating,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'].toString(),
      userId: json['userId'].toString(),
      groundId: json['groundId'].toString(),
      comment: json['comment'],
      rating: json['rating'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
