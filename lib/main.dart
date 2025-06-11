import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'features/post/presentation/post_list_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibe_coding_flutter/features/auth/presentation/auth_notifier.dart';
import 'package:vibe_coding_flutter/features/auth/presentation/login_page.dart';
import 'package:vibe_coding_flutter/core/theme/theme_provider.dart';
import 'package:vibe_coding_flutter/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final user = ref.watch(authNotifierProvider);

    return MaterialApp(
      title: 'Vibe Coding Flutter',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: user == null ? const LoginPage() : const PostListPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
