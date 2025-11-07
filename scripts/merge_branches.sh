#!/bin/bash

# 기능별 브랜치 병합 스크립트
# 관련 기능들을 하나의 브랜치로 통합합니다

set -e  # 에러 발생 시 스크립트 중단

echo "=== 기능별 브랜치 병합 스크립트 ==="
echo ""

# 현재 브랜치 확인
CURRENT_BRANCH=$(git branch --show-current)
echo "현재 브랜치: $CURRENT_BRANCH"
echo ""

# main 브랜치로 전환
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo "main 브랜치로 전환 중..."
    git checkout main
    git pull upstream main 2>/dev/null || git pull origin main
fi

echo ""
echo "=== 브랜치 병합 계획 ==="
echo ""
echo "1. TODO 관련: feature/todo-popup + feature/todo-ui → feature/todo"
echo "2. 인증/사용자: feature/login + feature/user-provider → feature/auth"
echo "3. 홈/캘린더: feature/homepage + feature/calendar-ui → feature/home"
echo "4. AI/일정: feature/ai-chat (유지, 이미 dynamic-schedule 병합됨)"
echo "5. 연결: feature/connect-partner (유지)"
echo ""

read -p "병합을 시작하시겠습니까? (y/n): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "병합을 취소했습니다."
    exit 0
fi

# 1. TODO 브랜치 병합
echo ""
echo "=== 1. TODO 브랜치 병합 ==="
if git show-ref --verify --quiet refs/heads/feature/todo; then
    echo "feature/todo 브랜치가 이미 존재합니다. 삭제 후 재생성합니다."
    git branch -D feature/todo 2>/dev/null || true
fi

echo "feature/todo-ui를 기반으로 feature/todo 생성..."
git checkout -b feature/todo upstream/feature/todo-ui 2>/dev/null || git checkout -b feature/todo feature/todo-ui

echo "feature/todo-popup 병합 중..."
if git show-ref --verify --quiet refs/remotes/upstream/feature/todo-popup; then
    git merge --no-edit upstream/feature/todo-popup 2>/dev/null || {
        echo "충돌 발생! 수동으로 해결해주세요."
        echo "충돌 해결 후: git add . && git commit"
        exit 1
    }
    echo "✓ feature/todo-popup 병합 완료"
else
    echo "  (feature/todo-popup 브랜치를 찾을 수 없습니다)"
fi

# 2. 인증 브랜치 병합
echo ""
echo "=== 2. 인증/사용자 브랜치 병합 ==="
if git show-ref --verify --quiet refs/heads/feature/auth; then
    echo "feature/auth 브랜치가 이미 존재합니다. 삭제 후 재생성합니다."
    git branch -D feature/auth 2>/dev/null || true
fi

echo "feature/user-provider를 기반으로 feature/auth 생성..."
git checkout -b feature/auth upstream/feature/user-provider 2>/dev/null || git checkout -b feature/auth feature/user-provider

echo "feature/login 병합 중..."
if git show-ref --verify --quiet refs/remotes/upstream/feature/login; then
    git merge --no-edit upstream/feature/login 2>/dev/null || {
        echo "충돌 발생! 수동으로 해결해주세요."
        echo "충돌 해결 후: git add . && git commit"
        exit 1
    }
    echo "✓ feature/login 병합 완료"
else
    echo "  (feature/login 브랜치를 찾을 수 없습니다)"
fi

# 3. 홈/캘린더 브랜치 병합
echo ""
echo "=== 3. 홈/캘린더 브랜치 병합 ==="
if git show-ref --verify --quiet refs/heads/feature/home; then
    echo "feature/home 브랜치가 이미 존재합니다. 삭제 후 재생성합니다."
    git branch -D feature/home 2>/dev/null || true
fi

echo "feature/homepage를 기반으로 feature/home 생성..."
git checkout -b feature/home upstream/feature/homepage 2>/dev/null || git checkout -b feature/home feature/homepage

echo "feature/calendar-ui 병합 중..."
if git show-ref --verify --quiet refs/remotes/upstream/feature/calendar-ui; then
    git merge --no-edit upstream/feature/calendar-ui 2>/dev/null || {
        echo "충돌 발생! 수동으로 해결해주세요."
        echo "충돌 해결 후: git add . && git commit"
        exit 1
    }
    echo "✓ feature/calendar-ui 병합 완료"
else
    echo "  (feature/calendar-ui 브랜치를 찾을 수 없습니다)"
fi

# 원래 브랜치로 복귀
if [ "$CURRENT_BRANCH" != "main" ] && git show-ref --verify --quiet refs/heads/"$CURRENT_BRANCH"; then
    git checkout "$CURRENT_BRANCH"
else
    git checkout main
fi

echo ""
echo "=== 병합 완료 ==="
echo ""
echo "새로 생성된 브랜치:"
echo "  - feature/todo (todo-popup + todo-ui)"
echo "  - feature/auth (login + user-provider)"
echo "  - feature/home (homepage + calendar-ui)"
echo ""
echo "기존 브랜치 삭제 여부를 확인하시겠습니까?"
read -p "병합된 기존 브랜치들을 삭제하시겠습니까? (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "로컬 브랜치 삭제 중..."
    git branch -d feature/todo-popup feature/todo-ui feature/login feature/user-provider feature/homepage feature/calendar-ui 2>/dev/null || echo "  (일부 브랜치는 삭제되지 않았습니다 - 강제 삭제 필요할 수 있음)"
    echo ""
    echo "원격 브랜치도 삭제하시겠습니까?"
    read -p "원격 브랜치 삭제 (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        for branch in todo-popup todo-ui login user-provider homepage calendar-ui; do
            git push origin --delete "feature/$branch" 2>/dev/null || echo "  (origin/feature/$branch 삭제 실패 또는 이미 삭제됨)"
        done
    fi
fi

echo ""
echo "=== 정리 완료 ==="
echo ""
echo "현재 브랜치 목록:"
git branch | grep feature/

