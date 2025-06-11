import 'package:flutter/material.dart';
import 'package:vibe_coding_flutter/features/post/application/post_usecase.dart';
import 'package:vibe_coding_flutter/features/post/domain/post_entity.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibe_coding_flutter/providers.dart';

final postEditNotifierProvider = AsyncNotifierProvider<PostEditNotifier, void>(
  () {
    return PostEditNotifier();
  },
);

class PostEditNotifier extends AsyncNotifier<void> {
  late PostUseCase _postUseCase;
  String? _uploadedImageUrl;
  String? _error;

  String? get uploadedImageUrl => _uploadedImageUrl;
  String? get error => _error;

  @override
  Future<void> build() async {
    _postUseCase = ref.watch(postUseCaseProvider);
  }

  Future<void> createPost(String title, String content) async {
    state = const AsyncValue.loading();
    try {
      await _postUseCase.createPost(
        title,
        content,
        imageUrl: _uploadedImageUrl,
      );
      _error = null;
      _uploadedImageUrl = null;
      state = const AsyncValue.data(null);
    } catch (e, st) {
      _error = e.toString();
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updatePost(
    String id,
    String title,
    String content, {
    String? currentImageUrl,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _postUseCase.updatePost(
        id,
        title,
        content,
        imageUrl: _uploadedImageUrl ?? currentImageUrl,
      );
      _error = null;
      _uploadedImageUrl = null;
      state = const AsyncValue.data(null);
    } catch (e, st) {
      _error = e.toString();
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> pickAndUploadImage() async {
    state = const AsyncValue.loading();
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) {
        state = const AsyncValue.data(null);
        return;
      }

      final imageBytes = await picked.readAsBytes();
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${picked.name}';

      final url = await _postUseCase.uploadImage(imageBytes, fileName);
      _uploadedImageUrl = url;
      _error = null;
      state = const AsyncValue.data(null);
    } catch (e, st) {
      _error = e.toString();
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deletePost(String id) async {
    state = const AsyncValue.loading();
    try {
      await _postUseCase.deletePost(id);
      _error = null;
      state = const AsyncValue.data(null);
    } catch (e, st) {
      _error = e.toString();
      state = AsyncValue.error(e, st);
    }
  }
}
