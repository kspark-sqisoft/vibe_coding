import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibe_coding_flutter/features/auth/data/supabase_auth_repository.dart';

@GenerateMocks([
  SupabaseAuthRepository,
  SupabaseClient,
  PostgrestQueryBuilder,
  PostgrestFilterBuilder,
])
void main() {}
