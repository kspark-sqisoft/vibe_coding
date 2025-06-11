import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:vibe_coding_flutter/features/post/application/post_usecase.dart';
import 'package:vibe_coding_flutter/features/post/data/supabase_post_repository.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
import 'package:vibe_coding_flutter/features/auth/data/supabase_auth_repository.dart';

// Provider for the Logger instance with PrettyPrinter
final loggerProvider = riverpod.Provider<Logger>(
  (ref) => Logger(printer: SimplePrinter(printTime: true)),
);

final supabasePostRepositoryProvider = riverpod.Provider(
  (ref) => SupabasePostRepository(ref.watch(loggerProvider)),
);

final postUseCaseProvider = riverpod.Provider(
  (ref) => PostUseCase(ref.watch(supabasePostRepositoryProvider)),
);

final authRepositoryProvider = riverpod.Provider(
  (ref) => SupabaseAuthRepository(
    Supabase.instance.client,
    ref.watch(loggerProvider),
  ),
);
