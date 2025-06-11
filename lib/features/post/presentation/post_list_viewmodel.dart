import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:vibe_coding_flutter/features/post/application/post_usecase.dart';
import 'package:vibe_coding_flutter/features/post/domain/post_entity.dart';
import 'dart:typed_data'; // Uint8List를 위해 추가
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibe_coding_flutter/providers.dart';

final postListNotifierProvider =
    AsyncNotifierProvider<PostListNotifier, List<PostEntity>>(() {
      return PostListNotifier();
    });

class PostListNotifier extends AsyncNotifier<List<PostEntity>> {
  late PostUseCase _useCase;
  String? _uploadedImageUrl;

  @override
  Future<List<PostEntity>> build() async {
    _useCase = ref.watch(postUseCaseProvider);
    return _fetchPosts();
  }

  Future<List<PostEntity>> _fetchPosts() async {
    try {
      final posts = await _useCase.fetchPosts();
      return posts;
    } catch (e, st) {
      print('Error loading posts: $e\n$st');
      // Consider handling the error state more gracefully in the UI
      return [];
    }
  }

  Future<void> createPost(String title, String content) async {
    state = const AsyncValue.loading();
    try {
      await _useCase.createPost(title, content, imageUrl: _uploadedImageUrl);
      _uploadedImageUrl = null; // 글 작성 후 이미지 상태 초기화
      state = AsyncValue.data(await _fetchPosts());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final imageBytes = await picked.readAsBytes();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${picked.name}';

    try {
      final url = await _useCase.uploadImage(imageBytes, fileName);
      _uploadedImageUrl = url;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
