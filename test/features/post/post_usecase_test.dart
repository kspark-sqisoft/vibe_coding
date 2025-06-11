import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
// import 'package:flutter/material.dart'; // This import is unused
import 'package:vibe_coding_flutter/features/post/application/post_usecase.dart';
import 'package:vibe_coding_flutter/features/post/data/supabase_post_repository.dart';
import 'package:vibe_coding_flutter/features/post/domain/post_entity.dart';
import 'mock_post_repository.mocks.dart';
import 'dart:typed_data'; // Uint8List를 위해 추가

void main() {
  group('PostUseCase', () {
    late PostUseCase postUseCase;
    late MockPostRepository mockPostRepository;

    setUp(() {
      mockPostRepository = MockPostRepository();
      postUseCase = PostUseCase(mockPostRepository);
    });

    test('fetchPosts가 포스트 목록을 반환해야 한다', () async {
      final mockPosts = [
        PostEntity(
          id: '1',
          title: 'Test Post 1',
          content: 'Content 1',
          createdAt: DateTime.now(),
          username: null,
        ),
        PostEntity(
          id: '2',
          title: 'Test Post 2',
          content: 'Content 2',
          createdAt: DateTime.now(),
          username: null,
        ),
      ];

      when(mockPostRepository.fetchPosts()).thenAnswer((_) async => mockPosts);

      final posts = await postUseCase.fetchPosts();

      expect(posts, mockPosts);
      verify(mockPostRepository.fetchPosts()).called(1);
    });

    test('createPost가 새 포스트를 생성해야 한다', () async {
      final newPost = PostEntity(
        id: '3',
        title: 'New Post',
        content: 'New Content',
        createdAt: DateTime.now(),
        username: null,
      );

      when(
        mockPostRepository.createPost(
          'New Post',
          'New Content',
          imageUrl: null,
        ),
      ).thenAnswer((_) async => newPost);

      final createdPost = await postUseCase.createPost(
        'New Post',
        'New Content',
      );

      expect(createdPost, newPost);
      verify(
        mockPostRepository.createPost(
          'New Post',
          'New Content',
          imageUrl: null,
        ),
      ).called(1);
    });

    test('updatePost가 기존 포스트를 업데이트해야 한다', () async {
      when(
        mockPostRepository.updatePost(
          '1',
          'Updated Title',
          'Updated Content',
          imageUrl: null,
        ),
      ).thenAnswer((_) async => Future.value());

      await postUseCase.updatePost('1', 'Updated Title', 'Updated Content');

      verify(
        mockPostRepository.updatePost(
          '1',
          'Updated Title',
          'Updated Content',
          imageUrl: null,
        ),
      ).called(1);
    });

    test('deletePost가 포스트를 삭제해야 한다', () async {
      when(
        mockPostRepository.deletePost('1'),
      ).thenAnswer((_) async => Future.value());

      await postUseCase.deletePost('1');

      verify(mockPostRepository.deletePost('1')).called(1);
    });

    test('uploadImage가 이미지 URL을 반환해야 한다', () async {
      final mockImageBytes = Uint8List(10);
      const fileName = 'test.jpg';
      const imageUrl = 'http://example.com/test.jpg';

      when(
        mockPostRepository.uploadImage(mockImageBytes, fileName),
      ).thenAnswer((_) async => imageUrl);

      final uploadedUrl = await postUseCase.uploadImage(
        mockImageBytes,
        fileName,
      );

      expect(uploadedUrl, imageUrl);
      verify(
        mockPostRepository.uploadImage(mockImageBytes, fileName),
      ).called(1);
    });
  });
}
