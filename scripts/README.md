# 브랜치 관리 스크립트

이 폴더에는 Git 브랜치를 관리하기 위한 유틸리티 스크립트가 포함되어 있습니다.

## 스크립트 목록

### 1. `cleanup_branches.sh` - 병합된 브랜치 정리

main 브랜치에 병합된 브랜치를 안전하게 삭제하는 스크립트입니다.

**사용법:**
```bash
./scripts/cleanup_branches.sh
```

**기능:**
- main에 병합된 브랜치 목록 표시
- 병합되지 않은 활성 브랜치 목록 표시
- 로컬 브랜치 삭제 (선택)
- 원격 브랜치 삭제 (선택)

### 2. `merge_branches.sh` - 기능별 브랜치 병합

관련 기능들을 하나의 브랜치로 통합하는 스크립트입니다.

**사용법:**
```bash
./scripts/merge_branches.sh
```

**병합 계획:**
- `feature/todo-popup` + `feature/todo-ui` → `feature/todo`
- `feature/login` + `feature/user-provider` → `feature/auth`
- `feature/homepage` + `feature/calendar-ui` → `feature/home`

**주의사항:**
- 병합 전에 현재 작업 중인 변경사항을 커밋하거나 stash하세요
- 충돌이 발생할 수 있으니 주의하세요
- 병합 후 기존 브랜치 삭제 여부를 선택할 수 있습니다

## 사용 예시

### 브랜치 정리하기
```bash
# 1. main 브랜치로 전환
git checkout main
git pull upstream main

# 2. 병합된 브랜치 정리
./scripts/cleanup_branches.sh
```

### 브랜치 병합하기
```bash
# 1. 현재 작업 커밋
git add .
git commit -m "작업 중인 내용 커밋"

# 2. 브랜치 병합 실행
./scripts/merge_branches.sh

# 3. 병합된 브랜치 확인
git branch | grep feature/
```

