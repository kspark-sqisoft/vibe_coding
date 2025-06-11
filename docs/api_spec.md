# 블로그 웹앱 API 명세서

## 1. 인증(Auth)

### 회원가입

- `POST /auth/signup`
- 요청: `{ "email": "string", "password": "string", "nickname": "string" }`
- 응답: `{ "user_id": "string", "email": "string" }`

### 로그인

- `POST /auth/login`
- 요청: `{ "email": "string", "password": "string" }`
- 응답: `{ "access_token": "string", "refresh_token": "string" }`

### 소셜 로그인

- `POST /auth/social-login`
- 요청: `{ "provider": "google|github" }`
- 응답: `{ "access_token": "string" }`

### 비밀번호 재설정

- `POST /auth/reset-password`
- 요청: `{ "email": "string" }`
- 응답: `{ "message": "sent" }`

---

## 2. 게시글(Post)

### 게시글 목록 조회

- `GET /posts?tag=string&category=string&search=string&page=1&limit=10`
- 응답: `[ { "id": "string", "title": "string", "user": { ... }, ... } ]`

### 게시글 상세 조회

- `GET /posts/{id}`
- 응답: `{ "id": "string", "title": "string", "content": "string", ... }`

### 게시글 작성

- `POST /posts`
- 요청: `{ "title": "string", "content": "string", "tags": ["string"], "category": "string", "image_urls": ["string"] }`
- 응답: `{ "id": "string" }`

### 게시글 수정

- `PUT /posts/{id}`
- 요청: `{ "title": "string", "content": "string", ... }`
- 응답: `{ "success": true }`

### 게시글 삭제

- `DELETE /posts/{id}`
- 응답: `{ "success": true }`

### 게시글 좋아요

- `POST /posts/{id}/like`
- 응답: `{ "like_count": 1 }`

---

## 3. 댓글(Comment)

### 댓글 목록 조회

- `GET /posts/{post_id}/comments`
- 응답: `[ { "id": "string", "content": "string", ... } ]`

### 댓글 작성

- `POST /posts/{post_id}/comments`
- 요청: `{ "content": "string", "parent_id": "string|null" }`
- 응답: `{ "id": "string" }`

### 댓글 수정

- `PUT /comments/{id}`
- 요청: `{ "content": "string" }`
- 응답: `{ "success": true }`

### 댓글 삭제

- `DELETE /comments/{id}`
- 응답: `{ "success": true }`

---

## 4. 프로필(Profile)

### 내 프로필 조회

- `GET /profile/me`
- 응답: `{ "id": "string", "nickname": "string", ... }`

### 프로필 수정

- `PUT /profile/me`
- 요청: `{ "nickname": "string", "bio": "string", "profile_image": "string" }`
- 응답: `{ "success": true }`

---

## 5. 알림(Notification)

### 내 알림 목록

- `GET /notifications`
- 응답: `[ { "id": "string", "type": "string", "message": "string", ... } ]`

### 알림 읽음 처리

- `POST /notifications/{id}/read`
- 응답: `{ "success": true }`

---

## 6. 관리자(Admin)

### 신고 목록 조회

- `GET /admin/reports`
- 응답: `[ { "id": "string", "target_type": "post|comment|user", ... } ]`

### 신고 처리

- `POST /admin/reports/{id}/resolve`
- 요청: `{ "action": "delete|block|ignore" }`
- 응답: `{ "success": true }`
