class PostEntity {
  final String id;
  final String title;
  final String content;
  final String? userId;
  final DateTime createdAt;
  final List<String>? imageUrls;

  PostEntity({
    required this.id,
    required this.title,
    required this.content,
    this.userId,
    required this.createdAt,
    this.imageUrls,
  });
}
