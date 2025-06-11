# 블로그 웹앱 설계 문서

## 1. 아키텍처 개요

- **Clean Architecture** 기반의 계층 구조 적용
- **SOLID 원칙**을 준수하여 각 계층의 책임 분리
- 프론트엔드(Flutter)와 백엔드(Supabase) 간 명확한 인터페이스 정의

## 2. 계층 구조

```
Presentation (UI)
  ↓
Application (ViewModel, UseCase)
  ↓
Domain (Entity, Repository Interface)
  ↓
Data (Repository Implementation, Supabase API)
```

### 2.1. Presentation Layer

- Flutter 위젯(UI), 상태관리(ViewModel/Provider/Bloc 등)
- 사용자 입력 처리, 화면 전환, 알림 등

### 2.2. Application Layer

- UseCase: 비즈니스 로직의 실행 단위
- ViewModel: UI와 UseCase 연결, 상태 관리

### 2.3. Domain Layer

- Entity: 핵심 비즈니스 객체(게시글, 사용자, 댓글 등)
- Repository Interface: 데이터 접근 추상화

### 2.4. Data Layer

- Supabase API 연동(인증, DB, 스토리지)
- Repository 구현체: API 호출 및 데이터 변환

## 3. 주요 컴포넌트 및 책임

- **AuthService**: 인증(로그인, 회원가입, 소셜 로그인 등)
- **PostService**: 게시글 CRUD, 검색, 필터링
- **CommentService**: 댓글/대댓글 관리
- **ProfileService**: 프로필, 마이페이지
- **NotificationService**: 실시간 알림
- **AdminService**: 관리자 기능(신고, 차단 등)

## 4. 데이터베이스 설계 (Supabase)

- **users**: id, email, nickname, bio, profile_image, created_at
- **posts**: id, user_id, title, content, tags, category, image_urls, like_count, view_count, created_at, updated_at
- **comments**: id, post_id, user_id, parent_id, content, created_at, updated_at
- **notifications**: id, user_id, type, ref_id, message, is_read, created_at
- **reports**: id, target_type, target_id, user_id, reason, created_at

## 5. 주요 흐름 예시

### 5.1. 게시글 작성

1. Presentation: 사용자가 글쓰기 화면에서 입력
2. Application: ViewModel이 UseCase 호출
3. Domain: UseCase가 Repository Interface 호출
4. Data: Repository가 Supabase API로 게시글 저장

### 5.2. 댓글 작성

1. UI 입력 → ViewModel → AddCommentUseCase → CommentRepository → Supabase

### 5.3. 실시간 알림

- Supabase Realtime 기능 활용, NotificationService에서 구독 및 UI 반영

## 6. 기술적 고려사항

- 상태관리: Provider, Riverpod, Bloc 등 중 선택
- 인증: Supabase Auth, 소셜 로그인 연동
- 보안: 인증 토큰 관리, DB 권한 설정
- 반응형 UI: 다양한 해상도 대응
- 테스트: 각 계층별 단위/통합 테스트 작성

## 7. 확장성 및 유지보수

- 계층별 책임 분리로 기능 추가/변경 용이
- Repository 패턴으로 데이터 소스 교체 가능
- 코드 일관성 및 재사용성 강화

---

> 본 설계 문서는 요구사항(requirements.md)을 기반으로 작성되었으며, 실제 구현 시 세부 구조 및 기술 스택은 프로젝트 상황에 따라 조정될 수 있습니다.
