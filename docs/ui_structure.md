# 블로그 웹앱 UI 구조

## 1. 주요 화면

- **로그인/회원가입 화면**: 인증, 소셜 로그인
- **메인(피드) 화면**: 게시글 목록, 검색, 필터, 인기글
- **게시글 상세 화면**: 본문, 이미지, 댓글, 좋아요, 공유
- **글쓰기/수정 화면**: 마크다운 에디터, 이미지 첨부
- **프로필/마이페이지**: 내 정보, 내가 쓴 글/댓글/좋아요
- **알림 화면**: 실시간 알림 목록
- **관리자 화면**: 신고 내역, 사용자/게시글/댓글 관리

## 2. 네비게이션 구조

- 하단 탭바(메인, 글쓰기, 알림, 마이페이지)
- 각 화면별 Stack/Route 관리
- 관리자 기능은 별도 진입(권한 체크)

## 3. 각 화면의 역할 및 상태관리

- **로그인/회원가입**: AuthViewModel, 인증 상태 관리
- **메인/피드**: PostListViewModel, 게시글 목록/검색/필터 상태
- **게시글 상세**: PostDetailViewModel, 댓글/좋아요/조회수 상태
- **글쓰기/수정**: PostEditViewModel, 입력값/업로드 상태
- **프로필/마이페이지**: ProfileViewModel, 내 정보/내 활동 상태
- **알림**: NotificationViewModel, 실시간 알림 상태
- **관리자**: AdminViewModel, 신고/차단/삭제 상태

## 4. 상태관리 포인트

- 인증(로그인/로그아웃/토큰)
- 게시글/댓글(목록, 상세, 작성, 수정, 삭제)
- 실시간 알림(구독, 읽음 처리)
- 사용자 정보(프로필, 활동 내역)
- 관리자(신고 처리, 차단 등)

## 5. 반응형/적응형 UI

- 모바일/웹/태블릿 대응 레이아웃
- 공통 AppBar, Drawer, BottomNavigationBar 등 활용
