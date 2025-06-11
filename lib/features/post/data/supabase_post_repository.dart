import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import '../domain/post_entity.dart';
import '../domain/post_repository.dart';

class SupabasePostRepository implements PostRepository {
  final supabase = Supabase.instance.client;

  @override
  Future<List<PostEntity>> fetchPosts() async {
    final response = await supabase
        .from('posts')
        .select('*, profiles(username)')
        .order('created_at');

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
  }

  @override
  Future<PostEntity> fetchPost(String id) async {
    final data = await supabase
        .from('posts')
        .select('*, profiles(username)')
        .eq('id', id)
        .single();

    final profile = data['profiles'];
    final username = profile is Map ? profile['username'] : null;
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
  }

  @override
  Future<PostEntity> createPost(
    String title,
    String content, {
    String? imageUrl,
  }) async {
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
  }

  @override
  Future<void> updatePost(
    String id,
    String title,
    String content, {
    String? imageUrl,
  }) async {
    await supabase
        .from('posts')
        .update({
          'title': title,
          'content': content,
          'image_urls': imageUrl != null ? [imageUrl] : [],
        })
        .eq('id', id);
  }

  @override
  Future<void> deletePost(String id) async {
    await supabase.from('posts').delete().eq('id', id);
  }

  @override
  Future<String> uploadImage(Uint8List imageBytes, String fileName) async {
    final response = await supabase.storage
        .from('mybucket')
        .uploadBinary(fileName, imageBytes);
    if (response.isEmpty) throw Exception('Image upload failed');
    final url = supabase.storage.from('mybucket').getPublicUrl(fileName);
    return url;
  }
}
