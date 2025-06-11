import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> testSupabaseConnection() async {
  final supabase = Supabase.instance.client;
  try {
    final result = await supabase.from('posts').select().limit(1);
    print('Supabase 연결 성공! posts 테이블 결과:');
    print(result);
  } catch (e) {
    print('Supabase 연결 실패: $e');
  }
}
