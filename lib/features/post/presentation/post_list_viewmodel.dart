import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:vibe_coding_flutter/features/post/application/post_usecase.dart';
import 'package:vibe_coding_flutter/features/post/domain/post_entity.dart';
import 'dart:typed_data'; // Uint8List를 위해 추가

class PostListViewModel extends ChangeNotifier {
  final PostUseCase useCase;
  List<PostEntity> posts = [];
  String? error;
  String? uploadedImageUrl;

  PostListViewModel(this.useCase);

  Future<void> loadPosts() async {
    try {
      posts = await useCase.fetchPosts();
      error = null;
    } catch (e) {
      error = e.toString();
    }
    notifyListeners();
  }

  Future<void> createPost(String title, String content) async {
    try {
      await useCase.createPost(title, content, imageUrl: uploadedImageUrl);
      await loadPosts();
      uploadedImageUrl = null; // 글 작성 후 이미지 상태 초기화
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final imageBytes = await picked.readAsBytes();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${picked.name}';

    try {
      final url = await useCase.uploadImage(imageBytes, fileName);
      uploadedImageUrl = url;
      error = null;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }
}
