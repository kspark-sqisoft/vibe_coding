// import 'package:flutter/material.dart'; // This import is unused
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:vibe_coding_flutter/features/post/domain/post_entity.dart'; // This import is unused
// import 'dart:typed_data'; // This import is unused
// import 'package:vibe_coding_flutter/features/auth/presentation/auth_notifier.dart'; // This import is unused
// import 'package:vibe_coding_flutter/features/post/application/post_usecase.dart'; // This import is unused
import 'package:vibe_coding_flutter/features/post/domain/post_entity.dart'; // Keep this one as PostEntity is used for currentPost
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:vibe_coding_flutter/providers.dart'; // Import providers for postUseCaseProvider

final postEditNotifierProvider =
    AsyncNotifierProvider<PostEditNotifier, PostEntity?>(PostEditNotifier.new);

class PostEditNotifier extends AsyncNotifier<PostEntity?> {
  String? uploadedImageUrl;

  @override
  Future<PostEntity?> build() async {
    // Initial build can be null or fetch a specific post if needed for initial state
    return null;
  }

  Future<void> pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      state = const AsyncLoading();
      try {
        final imageBytes = await image.readAsBytes();
        final fileName = '${const Uuid().v4()}.jpg';
        uploadedImageUrl = await ref
            .read(postUseCaseProvider)
            .uploadImage(imageBytes, fileName);
        state = AsyncData(
          state.value,
        ); // Keep current post state, only update image URL separately
      } catch (e) {
        state = AsyncError(e, StackTrace.current);
      }
    }
  }

  Future<void> createPost(String title, String content) async {
    state = const AsyncLoading();
    try {
      final newPost = await ref
          .read(postUseCaseProvider)
          .createPost(title, content, imageUrl: uploadedImageUrl);
      state = AsyncData(newPost);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> updatePost(
    String id,
    String title,
    String content, {
    String? currentImageUrl,
  }) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(postUseCaseProvider)
          .updatePost(
            id,
            title,
            content,
            imageUrl: uploadedImageUrl ?? currentImageUrl,
          );
      // After update, refresh the post data if it exists or just update the current state if it's the same post
      final updatedPost = await ref
          .read(postUseCaseProvider)
          .fetchPost(id); // Fetch the latest post data
      state = AsyncData(updatedPost);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> deletePost(String id) async {
    state = const AsyncLoading();
    try {
      await ref.read(postUseCaseProvider).deletePost(id);
      state = const AsyncData(null); // Post deleted, so state is null
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}
