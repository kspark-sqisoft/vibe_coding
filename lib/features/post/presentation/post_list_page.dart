import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'post_list_viewmodel.dart';
import 'post_edit_page.dart';

class PostListPage extends StatefulWidget {
  const PostListPage({super.key});

  @override
  State<PostListPage> createState() => _PostListPageState();
}

class _PostListPageState extends State<PostListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<PostListViewModel>(context, listen: false).loadPosts(),
    );
  }

  void _showCreatePostDialog(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const PostEditPage())).then((_) {
      Provider.of<PostListViewModel>(context, listen: false).loadPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<PostListViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: Text('블로그')),
      body: vm.error != null
          ? Center(child: Text('Error: ${vm.error}'))
          : RefreshIndicator(
              onRefresh: vm.loadPosts,
              child: ListView.builder(
                itemCount: vm.posts.length,
                itemBuilder: (context, i) {
                  final post = vm.posts[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context)
                            .push(
                              MaterialPageRoute(
                                builder: (_) => PostEditPage(post: post),
                              ),
                            )
                            .then((_) {
                              Provider.of<PostListViewModel>(
                                context,
                                listen: false,
                              ).loadPosts();
                            });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (post.imageUrls != null &&
                                post.imageUrls!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(
                                    post.imageUrls![0],
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post.title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    post.content,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePostDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }
}
