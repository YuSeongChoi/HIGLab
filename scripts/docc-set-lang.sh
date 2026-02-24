#!/bin/bash
# DocC 언어 전환 스크립트
# 사용법: ./docc-set-lang.sh <lang> [tutorial_name]
# 예시: ./docc-set-lang.sh ko storekit
#       ./docc-set-lang.sh en       (전체)

set -e

LANG=${1:-ko}
TUTORIAL=${2:-all}
BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TUTORIALS_DIR="$BASE_DIR/tutorials"

if [[ "$LANG" != "ko" && "$LANG" != "en" ]]; then
  echo "Error: Language must be 'ko' or 'en'"
  exit 1
fi

switch_lang() {
  local name=$1
  local docc_path=$(find "$TUTORIALS_DIR/$name" -type d -name "Documentation.docc" -not -path "*/.build/*" 2>/dev/null | head -1)
  
  if [[ -z "$docc_path" ]]; then
    echo "⏭️  $name: Documentation.docc not found"
    return
  fi
  
  local lproj_path="$docc_path/$LANG.lproj"
  
  if [[ ! -d "$lproj_path" ]]; then
    echo "⏭️  $name: $LANG.lproj not found"
    return
  fi
  
  # 기존 루트의 .md, Tutorials/ 백업 (있으면)
  # lproj 폴더에서 루트로 복사
  
  # 1. 루트의 기존 .md 파일들 삭제 (lproj 폴더 제외)
  find "$docc_path" -maxdepth 1 -name "*.md" -type f -delete 2>/dev/null || true
  
  # 2. 루트의 기존 Tutorials 폴더 삭제
  if [[ -d "$docc_path/Tutorials" ]]; then
    rm -rf "$docc_path/Tutorials"
  fi
  
  # 3. lproj에서 루트로 복사
  cp "$lproj_path"/*.md "$docc_path/" 2>/dev/null || true
  
  if [[ -d "$lproj_path/Tutorials" ]]; then
    cp -r "$lproj_path/Tutorials" "$docc_path/"
  fi
  
  echo "✅ $name: switched to $LANG"
}

if [[ "$TUTORIAL" == "all" ]]; then
  echo "🔄 Switching all tutorials to $LANG..."
  for dir in "$TUTORIALS_DIR"/*/; do
    name=$(basename "$dir")
    switch_lang "$name"
  done
  echo ""
  echo "✅ All tutorials switched to $LANG"
else
  switch_lang "$TUTORIAL"
fi
