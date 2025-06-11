import 'package:flutter/material.dart';
import 'package:vibe_coding_flutter/features/post/application/post_usecase.dart';
import 'package:vibe_coding_flutter/features/post/domain/post_entity.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class PostEditViewModel extends ChangeNotifier {
  final PostUseCase _postUseCase;
  String? _error;
  String? _uploadedImageUrl;
  bool _isLoading = false;

  PostEditViewModel(this._postUseCase);

  String? get error => _error;
  String? get uploadedImageUrl => _uploadedImageUrl;
  bool get isLoading => _isLoading;

  Future<void> createPost(String title, String content) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _postUseCase.createPost(
        title,
        content,
        imageUrl: _uploadedImageUrl,
      );
      _error = null;
      _uploadedImageUrl = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePost(
    String id,
    String title,
    String content, {
    String? currentImageUrl,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _postUseCase.updatePost(
        id,
        title,
        content,
        imageUrl: _uploadedImageUrl ?? currentImageUrl,
      );
      _error = null;
      _uploadedImageUrl = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> pickAndUploadImage() async {
    _isLoading = true;
    notifyListeners();
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;

      final imageBytes = await picked.readAsBytes();
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${picked.name}';

      final url = await _postUseCase.uploadImage(imageBytes, fileName);
      _uploadedImageUrl = url;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deletePost(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _postUseCase.deletePost(id);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
