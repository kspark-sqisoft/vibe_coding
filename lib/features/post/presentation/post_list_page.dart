import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibe_coding_flutter/providers.dart';
import 'package:vibe_coding_flutter/features/auth/presentation/auth_notifier.dart';
import 'package:vibe_coding_flutter/features/auth/presentation/login_page.dart';
import 'package:vibe_coding_flutter/features/auth/domain/user_with_profile.dart';
import 'package:vibe_coding_flutter/core/theme/theme_provider.dart';
import 'post_list_viewmodel.dart';
import 'post_edit_page.dart';
import 'package:intl/intl.dart';

class PostListPage extends ConsumerStatefulWidget {
  const PostListPage({super.key});

  @override
  ConsumerState<PostListPage> createState() => _PostListPageState();
}

class _PostListPageState extends ConsumerState<PostListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(postListNotifierProvider.notifier).build());
  }

  void _showCreatePostDialog(BuildContext context) {
    final user = ref.read(authNotifierProvider);
    if (user == null) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const LoginPage()));
    } else {
      Navigator.of(context)
          .push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const PostEditPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    const begin = Offset(0.0, 1.0); // Start from bottom
                    const end = Offset.zero;
                    const curve = Curves.easeOut;

                    var tween = Tween(
                      begin: begin,
                      end: end,
                    ).chain(CurveTween(curve: curve));

                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
            ),
          )
          .then((_) {
            ref.invalidate(postListNotifierProvider);
          });
    }
  }

  void _signOut() async {
    final authNotifier = ref.read(authNotifierProvider.notifier);
    await authNotifier.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final postsAsyncValue = ref.watch(postListNotifierProvider);
    final userWithProfile = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          userWithProfile != null && userWithProfile.username != null
              ? '${userWithProfile.username}님 블로그'
              : '블로그',
        ),
        actions: [
          if (userWithProfile != null && userWithProfile.username != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  '${userWithProfile.username}님',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          IconButton(
            icon: Icon(
              ref.watch(themeProvider) == ThemeMode.light
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
          if (userWithProfile != null)
            IconButton(icon: const Icon(Icons.logout), onPressed: _signOut),
        ],
      ),
      body: postsAsyncValue.when(
        data: (posts) {
          if (posts.isEmpty) {
            return const Center(child: Text('아직 게시물이 없습니다.'));
          }
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(postListNotifierProvider.notifier).build(),
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, i) {
                final post = posts[i];
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
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      PostEditPage(post: post),
                              transitionsBuilder:
                                  (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) {
                                    const begin = Offset(
                                      1.0,
                                      0.0,
                                    ); // Start from right
                                    const end = Offset.zero;
                                    const curve = Curves.easeOut;

                                    var tween = Tween(
                                      begin: begin,
                                      end: end,
                                    ).chain(CurveTween(curve: curve));

                                    return SlideTransition(
                                      position: animation.drive(tween),
                                      child: child,
                                    );
                                  },
                            ),
                          )
                          .then((shouldRefresh) {
                            if (shouldRefresh == true) {
                              ref.invalidate(postListNotifierProvider);
                            }
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
                                  style: TextStyle(fontSize: 14),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '작성자: ${post.username ?? 'Unknown'}',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    Text(
                                      DateFormat(
                                        'yyyy.MM.dd HH:mm',
                                      ).format(post.createdAt),
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
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
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: userWithProfile != null
          ? FloatingActionButton.extended(
              onPressed: () => _showCreatePostDialog(context),
              label: const Text('새 글'),
              icon: const Icon(Icons.add),
            )
          : null,
    );
  }
}
