import 'package:supabase_flutter/supabase_flutter.dart';

class UserWithProfile {
  final User user;
  final String? username;

  UserWithProfile({required this.user, this.username});

  UserWithProfile copyWith({User? user, String? username}) {
    return UserWithProfile(
      user: user ?? this.user,
      username: username ?? this.username,
    );
  }
}
