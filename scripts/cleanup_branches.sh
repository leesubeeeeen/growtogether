#!/bin/bash

# 브랜치 정리 스크립트
# 병합된 브랜치를 안전하게 삭제합니다

echo "=== 브랜치 정리 스크립트 ==="
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
echo "=== 병합된 브랜치 목록 (삭제 가능) ==="
MERGED_BRANCHES=$(git branch --merged main | grep feature/ | grep -v "\*" | sed 's/^[[:space:]]*//')
if [ -z "$MERGED_BRANCHES" ]; then
    echo "병합된 브랜치가 없습니다."
else
    echo "$MERGED_BRANCHES"
fi

echo ""
echo "=== 병합되지 않은 브랜치 목록 (활성) ==="
UNMERGED_BRANCHES=$(git branch --no-merged main | grep feature/ | grep -v "\*" | sed 's/^[[:space:]]*//')
if [ -z "$UNMERGED_BRANCHES" ]; then
    echo "병합되지 않은 브랜치가 없습니다."
else
    echo "$UNMERGED_BRANCHES"
fi

echo ""
read -p "병합된 로컬 브랜치를 삭제하시겠습니까? (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "로컬 브랜치 삭제 중..."
    for branch in $MERGED_BRANCHES; do
        echo "  - $branch 삭제"
        git branch -d "$branch"
    done
    echo "로컬 브랜치 삭제 완료!"
else
    echo "로컬 브랜치 삭제를 취소했습니다."
fi

echo ""
read -p "원격(origin)의 병합된 브랜치도 삭제하시겠습니까? (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "원격 브랜치 삭제 중..."
    for branch in $MERGED_BRANCHES; do
        echo "  - origin/$branch 삭제"
        git push origin --delete "$branch" 2>/dev/null || echo "    (origin/$branch가 없거나 이미 삭제됨)"
    done
    echo "원격 브랜치 삭제 완료!"
else
    echo "원격 브랜치 삭제를 취소했습니다."
fi

echo ""
echo "=== 정리 완료 ==="
echo ""
echo "남은 브랜치 목록:"
git branch -a | grep feature/

