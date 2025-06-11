import 'post_entity.dart';
import 'dart:typed_data'; // Uint8List를 위해 추가

abstract class PostRepository {
  Future<List<PostEntity>> fetchPosts();
  Future<PostEntity> fetchPost(String id);
  Future<PostEntity> createPost(
    String title,
    String content, {
    String? imageUrl,
  });
  Future<void> updatePost(
    String id,
    String title,
    String content, {
    String? imageUrl,
  });
  Future<void> deletePost(String id);
  Future<String> uploadImage(Uint8List imageBytes, String fileName);
}
