import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'features/post/presentation/post_list_page.dart';
import 'features/post/presentation/post_list_viewmodel.dart';
import 'features/post/presentation/post_edit_viewmodel.dart';
import 'features/post/application/post_usecase.dart';
import 'features/post/data/supabase_post_repository.dart';
import 'features/post/data/supabase_connect_test.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  await testSupabaseConnection();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              PostListViewModel(PostUseCase(SupabasePostRepository())),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              PostEditViewModel(PostUseCase(SupabasePostRepository())),
        ),
      ],
      child: MaterialApp(
        title: 'Vibe Coding Flutter',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: PostListPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
