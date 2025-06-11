import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibe_coding_flutter/features/post/application/post_usecase.dart';
import 'package:vibe_coding_flutter/features/post/data/supabase_post_repository.dart';

final supabasePostRepositoryProvider = Provider(
  (ref) => SupabasePostRepository(),
);

final postUseCaseProvider = Provider(
  (ref) => PostUseCase(ref.watch(supabasePostRepositoryProvider)),
);
