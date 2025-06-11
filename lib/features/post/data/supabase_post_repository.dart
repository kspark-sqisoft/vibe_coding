import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';
import 'dart:typed_data';
import '../domain/post_entity.dart';
import '../domain/post_repository.dart';

class SupabasePostRepository implements PostRepository {
  final supabase = Supabase.instance.client;
  final Logger _logger;

  SupabasePostRepository(this._logger);

  @override
  Future<List<PostEntity>> fetchPosts() async {
    _logger.i('Fetching all posts');
    try {
      final response = await supabase
          .from('posts')
          .select('*, profiles(username)')
          .order('created_at');

      _logger.i('Successfully fetched ${response.length} posts.');

      return (response as List).map((e) {
        final profile = e['profiles'];
        final username = profile is Map ? profile['username'] : null;
        return PostEntity(
          id: e['id'],
          title: e['title'],
          content: e['content'],
          userId: e['user_id'],
          username: username,
          createdAt: DateTime.parse(e['created_at']),
          imageUrls: (e['image_urls'] as List?)
              ?.map((url) => url.toString())
              .toList(),
        );
      }).toList();
    } catch (e) {
      _logger.e('Error fetching posts: $e');
      rethrow;
    }
  }

  @override
  Future<PostEntity> fetchPost(String id) async {
    _logger.i('Fetching post with ID: $id');
    try {
      final data = await supabase
          .from('posts')
          .select('*, profiles(username)')
          .eq('id', id)
          .single();

      final profile = data['profiles'];
      final username = profile is Map ? profile['username'] : null;
      _logger.i('Successfully fetched post with ID: $id');
      return PostEntity(
        id: data['id'],
        title: data['title'],
        content: data['content'],
        userId: data['user_id'],
        username: username,
        createdAt: DateTime.parse(data['created_at']),
        imageUrls: (data['image_urls'] as List?)
            ?.map((url) => url.toString())
            .toList(),
      );
    } catch (e) {
      _logger.e('Error fetching post with ID $id: $e');
      rethrow;
    }
  }

  @override
  Future<PostEntity> createPost(
    String title,
    String content, {
    String? imageUrl,
  }) async {
    _logger.i('Creating new post with title: $title');
    try {
      final user = supabase.auth.currentUser;
      final data = await supabase
          .from('posts')
          .insert({
            'title': title,
            'content': content,
            'user_id': user?.id,
            'image_urls': imageUrl != null ? [imageUrl] : [],
          })
          .select('*, profiles(username)')
          .single();

      final profile = data['profiles'];
      final username = profile is Map ? profile['username'] : null;

      _logger.i('Successfully created post with ID: ${data['id']}');
      return PostEntity(
        id: data['id'],
        title: data['title'],
        content: data['content'],
        userId: data['user_id'],
        username: username,
        createdAt: DateTime.parse(data['created_at']),
        imageUrls: (data['image_urls'] as List?)
            ?.map((url) => url.toString())
            .toList(),
      );
    } catch (e) {
      _logger.e('Error creating post: $e');
      rethrow;
    }
  }

  @override
  Future<void> updatePost(
    String id,
    String title,
    String content, {
    String? imageUrl,
  }) async {
    _logger.i('Updating post with ID: $id');
    try {
      await supabase
          .from('posts')
          .update({
            'title': title,
            'content': content,
            'image_urls': imageUrl != null ? [imageUrl] : [],
          })
          .eq('id', id);
      _logger.i('Successfully updated post with ID: $id');
    } catch (e) {
      _logger.e('Error updating post with ID $id: $e');
      rethrow;
    }
  }

  @override
  Future<void> deletePost(String id) async {
    _logger.i('Deleting post with ID: $id');
    try {
      await supabase.from('posts').delete().eq('id', id);
      _logger.i('Successfully deleted post with ID: $id');
    } catch (e) {
      _logger.e('Error deleting post with ID $id: $e');
      rethrow;
    }
  }

  @override
  Future<String> uploadImage(Uint8List imageBytes, String fileName) async {
    _logger.i('Uploading image: $fileName');
    try {
      final response = await supabase.storage
          .from('mybucket')
          .uploadBinary(fileName, imageBytes);
      if (response.isEmpty) {
        _logger.e('Image upload failed: Empty response');
        throw Exception('Image upload failed');
      }
      final url = supabase.storage.from('mybucket').getPublicUrl(fileName);
      _logger.i('Successfully uploaded image: $fileName, URL: $url');
      return url;
    } catch (e) {
      _logger.e('Error uploading image $fileName: $e');
      rethrow;
    }
  }
}
