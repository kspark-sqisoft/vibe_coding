import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibe_coding_flutter/features/post/domain/post_entity.dart';
import 'post_edit_viewmodel.dart';

class PostEditPage extends StatefulWidget {
  final PostEntity? post;

  const PostEditPage({super.key, this.post});

  @override
  State<PostEditPage> createState() => _PostEditPageState();
}

class _PostEditPageState extends State<PostEditPage> {
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
    final vm = Provider.of<PostEditViewModel>(context);

    // Determine the image URL to display at the top of the page
    String? imageToDisplayUrl;
    if (vm.uploadedImageUrl != null) {
      imageToDisplayUrl = vm.uploadedImageUrl;
    } else if (widget.post != null &&
        widget.post!.imageUrls != null &&
        widget.post!.imageUrls!.isNotEmpty) {
      imageToDisplayUrl = widget.post!.imageUrls!.first;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post == null ? '새 글 작성' : '게시글 수정'),
        actions: [
          if (widget.post != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: vm.isLoading
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
                        await vm.deletePost(widget.post!.id);
                        if (vm.error == null) {
                          Navigator.of(context).pop(); // Close PostEditPage
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('삭제 실패: ${vm.error!}')),
                          );
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
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: '제목'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: '내용'),
                maxLines: null,
                expands: true,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: vm.isLoading
                  ? null
                  : () async {
                      await vm.pickAndUploadImage();
                    },
              icon: vm.isLoading
                  ? const CircularProgressIndicator()
                  : const Icon(Icons.image),
              label: const Text('이미지 업로드'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: vm.isLoading
                  ? null
                  : () async {
                      final title = _titleController.text.trim();
                      final content = _contentController.text.trim();

                      if (title.isNotEmpty && content.isNotEmpty) {
                        if (widget.post == null) {
                          // Creating a new post
                          await vm.createPost(title, content);
                        } else {
                          // Updating an existing post
                          // Determine the imageUrl to pass to updatePost safely
                          String? finalImageUrlForUpdate;
                          if (vm.uploadedImageUrl != null) {
                            finalImageUrlForUpdate = vm
                                .uploadedImageUrl; // Newly uploaded image takes precedence
                          } else if (widget.post != null &&
                              widget.post!.imageUrls != null &&
                              widget.post!.imageUrls!.isNotEmpty) {
                            finalImageUrlForUpdate = widget
                                .post!
                                .imageUrls!
                                .first; // Use existing image if no new one
                          }

                          await vm.updatePost(
                            widget.post!.id,
                            title,
                            content,
                            currentImageUrl: finalImageUrlForUpdate,
                          );
                        }
                        Navigator.of(context).pop();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('제목과 내용을 입력해주세요.')),
                        );
                      }
                    },
              child: Text(widget.post == null ? '게시글 작성' : '게시글 수정'),
            ),
            if (vm.error != null)
              Text(
                'Error: ${vm.error!}',
                style: const TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
