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
import 'package:logger/logger.dart'; // Import Logger

final postEditNotifierProvider =
    AsyncNotifierProvider<PostEditNotifier, PostEntity?>(PostEditNotifier.new);

class PostEditNotifier extends AsyncNotifier<PostEntity?> {
  String? uploadedImageUrl;

  void clearUploadedImageUrl() {
    uploadedImageUrl = null;
    state = AsyncData(
      state.value,
    ); // Notify listeners that state has potentially changed
    ref.read(loggerProvider).d('Uploaded image URL cleared.');
  }

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
      ref
          .read(loggerProvider)
          .d('Image picking started, state set to loading.');
      try {
        final imageBytes = await image.readAsBytes();
        final fileName = '${const Uuid().v4()}.jpg';
        uploadedImageUrl = await ref
            .read(postUseCaseProvider)
            .uploadImage(imageBytes, fileName);
        ref.read(loggerProvider).d('Image uploaded. URL: $uploadedImageUrl');
        state = AsyncData(
          state.value,
        ); // Keep current post state, only update image URL separately
        ref
            .read(loggerProvider)
            .d('State set to AsyncData after image upload.');
      } catch (e) {
        state = AsyncError(e, StackTrace.current);
        ref.read(loggerProvider).e('Image upload failed: $e');
      }
    }
  }

  Future<void> createPost(String title, String content) async {
    state = const AsyncLoading();
    ref
        .read(loggerProvider)
        .d(
          'Creating post with title: $title, content: $content, imageUrl: $uploadedImageUrl',
        );
    try {
      final newPost = await ref
          .read(postUseCaseProvider)
          .createPost(title, content, imageUrl: uploadedImageUrl);
      state = AsyncData(newPost);
      ref.read(loggerProvider).d('Post created successfully: ${newPost.id}');
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      ref.read(loggerProvider).e('Post creation failed: $e');
    }
  }

  Future<void> updatePost(
    String id,
    String title,
    String content, {
    String? currentImageUrl,
  }) async {
    state = const AsyncLoading();
    ref
        .read(loggerProvider)
        .d(
          'Updating post id: $id, title: $title, content: $content, uploadedImageUrl: $uploadedImageUrl, currentImageUrl: $currentImageUrl',
        );
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
      ref
          .read(loggerProvider)
          .d('Post updated successfully: ${updatedPost.id}');
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      ref.read(loggerProvider).e('Post update failed: $e');
    }
  }

  Future<void> deletePost(String id) async {
    state = const AsyncLoading();
    ref.read(loggerProvider).d('Deleting post id: $id');
    try {
      await ref.read(postUseCaseProvider).deletePost(id);
      state = const AsyncData(null); // Post deleted, so state is null
      ref.read(loggerProvider).d('Post deleted successfully.');
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      ref.read(loggerProvider).e('Post deletion failed: $e');
    }
  }
}
