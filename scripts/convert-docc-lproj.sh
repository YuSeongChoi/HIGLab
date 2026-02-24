#!/bin/bash
# DocC lproj 구조 변환 스크립트
# 기존 파일을 ko.lproj로 이동

cd /Users/leeo/Documents/code/HIGLab/tutorials

for dir in */; do
  name="${dir%/}"
  
  # Documentation.docc 경로 찾기
  docc_path=$(find "$dir" -type d -name "Documentation.docc" 2>/dev/null | head -1)
  
  if [ -z "$docc_path" ]; then
    echo "⏭️  $name: Documentation.docc 없음"
    continue
  fi
  
  # 이미 변환됐으면 스킵
  if [ -d "$docc_path/ko.lproj" ]; then
    echo "✅ $name: 이미 완료"
    continue
  fi
  
  echo "🔄 $name 변환 중..."
  
  # ko.lproj, en.lproj 폴더 생성
  mkdir -p "$docc_path/ko.lproj/Tutorials"
  mkdir -p "$docc_path/en.lproj/Tutorials"
  
  # .md 파일 이동 (Resources 제외)
  for md in "$docc_path"/*.md; do
    if [ -f "$md" ]; then
      mv "$md" "$docc_path/ko.lproj/"
    fi
  done
  
  # Tutorials 폴더의 .tutorial 파일 이동
  if [ -d "$docc_path/Tutorials" ]; then
    for tut in "$docc_path/Tutorials"/*.tutorial; do
      if [ -f "$tut" ]; then
        mv "$tut" "$docc_path/ko.lproj/Tutorials/"
      fi
    done
    # 빈 Tutorials 폴더 삭제
    rmdir "$docc_path/Tutorials" 2>/dev/null
  fi
  
  echo "✅ $name 완료"
done

echo ""
echo "=== 구조 변환 완료 ==="
