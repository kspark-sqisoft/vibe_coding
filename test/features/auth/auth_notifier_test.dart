import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:riverpod_test/riverpod_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    as riverpod; // ProviderContainer를 위해 별칭 추가
import 'package:supabase_flutter/supabase_flutter.dart'
    hide Provider; // Provider 충돌 방지
import 'package:vibe_coding_flutter/features/auth/data/supabase_auth_repository.dart';
import 'package:vibe_coding_flutter/features/auth/presentation/auth_notifier.dart';
import 'package:vibe_coding_flutter/features/auth/domain/user_with_profile.dart';
import 'package:vibe_coding_flutter/providers.dart'; // authRepositoryProvider를 사용하기 위함

import 'mock_auth_repository.mocks.dart';
import 'dart:async'; // StreamController를 위해 추가

void main() {
  group('AuthNotifier', () {
    late MockSupabaseAuthRepository mockAuthRepository;
    late StreamController<AuthState> authStateController;
    late riverpod.ProviderContainer container;

    setUp(() {
      mockAuthRepository = MockSupabaseAuthRepository();
      authStateController = StreamController<AuthState>();

      when(
        mockAuthRepository.authStateChanges,
      ).thenAnswer((_) => authStateController.stream);

      // AuthNotifier 초기화 시 getCurrentUser 호출에 대한 기본 모의
      when(mockAuthRepository.getCurrentUser()).thenReturn(null);

      // getUserWithProfile 메서드를 모의하여 테스트 진행
      when(
        mockAuthRepository.getUserWithProfile(argThat(isA<User>())),
      ).thenAnswer(
        (realInvocation) async => UserWithProfile(
          user: realInvocation.positionalArguments[0] as User,
          username: 'testuser',
        ),
      );

      // authNotifierProvider를 오버라이드하여 모의 객체 주입
      container = riverpod.ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
          authNotifierProvider.overrideWith(
            (ref) => AuthNotifier(ref.watch(authRepositoryProvider)),
          ),
        ],
      );
    });

    tearDown(() {
      authStateController.close();
      container.dispose();
    });

    test('초기화 시 현재 사용자 상태를 가져와야 한다', () async {
      final mockUser = User(
        id: '123',
        email: 'test@example.com',
        appMetadata: {},
        userMetadata: {},
        createdAt: DateTime.now().toIso8601String(),
        aud: 'authenticated',
      );
      when(mockAuthRepository.getCurrentUser()).thenReturn(mockUser);

      final authNotifier = container.read(authNotifierProvider.notifier);

      await Future.delayed(Duration.zero); // 비동기 로직 완료 대기

      expect(authNotifier.state?.user.id, mockUser.id);
      expect(authNotifier.state?.username, 'testuser'); // 모의된 username 확인
    });

    test('signIn 시 AuthNotifier 상태가 업데이트되어야 한다', () async {
      final mockUser = User(
        id: '123',
        email: 'test@example.com',
        appMetadata: {},
        userMetadata: {},
        createdAt: DateTime.now().toIso8601String(),
        aud: 'authenticated',
      );

      when(
        mockAuthRepository.signIn('test@example.com', 'password123'),
      ).thenAnswer((_) async {
        authStateController.add(
          AuthState(
            AuthChangeEvent.signedIn,
            Session(
              accessToken: 'token',
              tokenType: 'Bearer',
              user: mockUser,
              expiresIn: 3600,
              refreshToken: 'refresh_token',
            ),
          ),
        );
      });

      final authNotifier = container.read(authNotifierProvider.notifier);

      await authNotifier.signIn('test@example.com', 'password123');

      await Future.delayed(Duration.zero);

      expect(authNotifier.state?.user.id, mockUser.id);
      expect(authNotifier.state?.username, 'testuser'); // 모의된 username 확인
      verify(
        mockAuthRepository.signIn('test@example.com', 'password123'),
      ).called(1);
    });

    test('signOut 시 AuthNotifier 상태가 null로 업데이트되어야 한다', () async {
      final mockUser = User(
        id: '123',
        email: 'test@example.com',
        appMetadata: {},
        userMetadata: {},
        createdAt: DateTime.now().toIso8601String(),
        aud: 'authenticated',
      );
      when(mockAuthRepository.getCurrentUser()).thenReturn(mockUser);

      final authNotifier = container.read(authNotifierProvider.notifier);
      await Future.delayed(Duration.zero);

      expect(authNotifier.state, isNotNull); // 초기 상태 확인

      when(mockAuthRepository.signOut()).thenAnswer((_) async {
        authStateController.add(AuthState(AuthChangeEvent.signedOut, null));
      });

      await authNotifier.signOut();

      await Future.delayed(Duration.zero);

      expect(authNotifier.state, isNull);
      verify(mockAuthRepository.signOut()).called(1);
    });

    test('signUp 시 AuthNotifier 상태가 업데이트되어야 한다', () async {
      final mockUser = User(
        id: '456',
        email: 'newuser@example.com',
        appMetadata: {},
        userMetadata: {},
        createdAt: DateTime.now().toIso8601String(),
        aud: 'authenticated',
      );

      when(
        mockAuthRepository.signUp(
          'newuser@example.com',
          'newpassword',
          'newusername',
        ),
      ).thenAnswer((_) async {
        authStateController.add(
          AuthState(
            AuthChangeEvent.signedIn,
            Session(
              accessToken: 'token2',
              tokenType: 'Bearer',
              user: mockUser,
              expiresIn: 3600,
              refreshToken: 'refresh_token2',
            ),
          ),
        );
      });

      final authNotifier = container.read(authNotifierProvider.notifier);

      await authNotifier.signUp(
        'newuser@example.com',
        'newpassword',
        'newusername',
      );

      await Future.delayed(Duration.zero);

      expect(authNotifier.state?.user.id, mockUser.id);
      expect(authNotifier.state?.username, 'testuser'); // 모의된 username 확인
      verify(
        mockAuthRepository.signUp(
          'newuser@example.com',
          'newpassword',
          'newusername',
        ),
      ).called(1);
    });
  });
}
