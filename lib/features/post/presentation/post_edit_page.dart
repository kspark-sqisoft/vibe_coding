import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:vibe_coding_flutter/features/post/application/post_usecase.dart'; // This import is unused
import 'package:vibe_coding_flutter/features/post/domain/post_entity.dart';
import 'package:vibe_coding_flutter/features/auth/presentation/auth_notifier.dart';
import 'post_edit_viewmodel.dart';

class PostEditPage extends ConsumerStatefulWidget {
  final PostEntity? post;

  const PostEditPage({super.key, this.post});

  @override
  ConsumerState<PostEditPage> createState() => _PostEditPageState();
}

class _PostEditPageState extends ConsumerState<PostEditPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.post != null) {
      _titleController.text = widget.post!.title;
      _contentController.text = widget.post!.content;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editNotifier = ref.watch(postEditNotifierProvider.notifier);
    final editState = ref.watch(postEditNotifierProvider);
    final user = ref.watch(authNotifierProvider);

    final bool isAuthor = user != null && user.user.id == widget.post?.userId;
    final bool isNewPost = widget.post == null;

    // Determine the image URL to display at the top of the page
    String? imageToDisplayUrl;
    if (editNotifier.uploadedImageUrl != null) {
      imageToDisplayUrl = editNotifier.uploadedImageUrl;
    } else if (widget.post != null &&
        widget.post!.imageUrls != null &&
        widget.post!.imageUrls!.isNotEmpty) {
      imageToDisplayUrl = widget.post!.imageUrls!.first;
    }

    ref.listen<AsyncValue<PostEntity?>>(postEditNotifierProvider, (
      previous,
      next,
    ) {
      next.whenOrNull(
        error: (e, st) {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('작업 실패: ${e.toString()}')));
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(isNewPost ? '새 글 작성' : '게시글 수정'),
        actions: [
          if (!isNewPost && isAuthor)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: editState.isLoading
                  ? null
                  : () async {
                      final confirmDelete = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('게시글 삭제'),
                          content: const Text('정말로 이 게시글을 삭제하시겠습니까?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('취소'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('삭제'),
                            ),
                          ],
                        ),
                      );

                      if (confirmDelete == true) {
                        await editNotifier.deletePost(widget.post!.id);
                        if (!mounted) return;
                        if (!editState.hasError) {
                          Navigator.of(context).pop(true); // 삭제 성공 시 true 반환
                        }
                      }
                    },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (imageToDisplayUrl != null) // Conditionally display the image
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Image.network(
                  imageToDisplayUrl,
                  height: 400,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: '제목'),
              readOnly: !isNewPost && !isAuthor,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: '내용'),
                maxLines: null,
                expands: true,
                readOnly: !isNewPost && !isAuthor,
              ),
            ),
            const SizedBox(height: 16),
            if (isNewPost || isAuthor)
              ElevatedButton.icon(
                onPressed: editState.isLoading
                    ? null
                    : () async {
                        await editNotifier.pickAndUploadImage();
                      },
                icon: editState.isLoading
                    ? const CircularProgressIndicator()
                    : const Icon(Icons.image),
                label: const Text('이미지 업로드'),
              ),
            if (isNewPost || isAuthor) const SizedBox(height: 16),
            if (isNewPost || isAuthor)
              ElevatedButton(
                onPressed: editState.isLoading
                    ? null
                    : () async {
                        final title = _titleController.text.trim();
                        final content = _contentController.text.trim();

                        if (title.isNotEmpty && content.isNotEmpty) {
                          if (isNewPost) {
                            // Creating a new post
                            await editNotifier.createPost(title, content);
                          } else {
                            // Updating an existing post
                            // Determine the imageUrl to pass to updatePost safely
                            String? finalImageUrlForUpdate;
                            if (editNotifier.uploadedImageUrl != null) {
                              finalImageUrlForUpdate = editNotifier
                                  .uploadedImageUrl; // Newly uploaded image takes precedence
                            } else if (widget.post != null &&
                                widget.post!.imageUrls != null &&
                                widget.post!.imageUrls!.isNotEmpty) {
                              finalImageUrlForUpdate = widget
                                  .post!
                                  .imageUrls!
                                  .first; // Use existing image if no new one
                            }

                            await editNotifier.updatePost(
                              widget.post!.id,
                              title,
                              content,
                              currentImageUrl: finalImageUrlForUpdate,
                            );
                            if (!mounted) return;
                            if (!editState.hasError) {
                              Navigator.of(context).pop();
                            }
                          }
                        } else {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('제목과 내용을 입력해주세요.')),
                          );
                        }
                      },
                child: Text(isNewPost ? '게시글 작성' : '게시글 수정'),
              ),
            if (editState.hasError && editState.error != null)
              Text(
                'Error: ${editState.error!.toString()}',
                style: const TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
