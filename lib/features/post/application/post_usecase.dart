import '../domain/post_repository.dart';
import '../domain/post_entity.dart';
import 'dart:typed_data';

class PostUseCase {
  final PostRepository repository;
  PostUseCase(this.repository);

  Future<List<PostEntity>> fetchPosts() => repository.fetchPosts();
  Future<PostEntity> fetchPost(String id) => repository.fetchPost(id);
  Future<PostEntity> createPost(
    String title,
    String content, {
    String? imageUrl,
  }) => repository.createPost(title, content, imageUrl: imageUrl);
  Future<void> updatePost(
    String id,
    String title,
    String content, {
    String? imageUrl,
  }) => repository.updatePost(id, title, content, imageUrl: imageUrl);
  Future<void> deletePost(String id) => repository.deletePost(id);
  Future<String> uploadImage(Uint8List imageBytes, String fileName) =>
      repository.uploadImage(imageBytes, fileName);
}
