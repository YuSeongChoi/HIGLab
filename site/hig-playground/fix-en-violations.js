#!/usr/bin/env node
const fs = require('fs');
const path = require('path');

const componentsDir = path.join(__dirname, 'components');

// All KO→EN violation message translations
const translations = {
  // Violation messages
  "Destructive 액션은 Filled 스타일로 명확하게 표시하세요": "Use Filled style to clearly indicate destructive actions",
  "비활성화된 destructive 버튼은 사용자를 혼란스럽게 합니다": "Disabled destructive buttons confuse users",
  "Small Filled 버튼은 탭하기 어렵습니다. Regular 이상을 권장합니다": "Small Filled buttons are hard to tap. Use Regular or larger",
  "Fill 모드에서 clipShape 없이 사용하면 이미지가 잘릴 수 있습니다": "Using Fill mode without clipShape may crop the image unexpectedly",
  "오버레이와 그림자를 동시에 쓰면 시각적으로 복잡해집니다": "Using overlay and shadow together creates visual noise",
  "Body 텍스트를 1줄로 제한하면 내용이 잘립니다": "Limiting body text to 1 line truncates content",
  "Body 텍스트에 Black 웨이트는 가독성을 떨어뜨립니다": "Black weight on body text reduces readability",
  "텍스트 색상의 대비가 너무 낮습니다 (WCAG 미달)": "Text color contrast is too low (fails WCAG)",
  "로딩 인디케이터 없이 웹뷰를 표시하면 사용자가 상태를 알 수 없습니다": "Showing web view without loading indicator leaves users guessing",
  "네비게이션 바 없이 웹뷰를 표시하면 뒤로 갈 수 없습니다": "Web view without nav bar prevents navigation back",
  "4열 이상이면 항목이 너무 작아 탭하기 어렵습니다 (44pt 미만)": "4+ columns make items too small to tap (below 44pt minimum)",
  "간격이 너무 좁으면 잘못된 항목을 탭할 수 있습니다": "Spacing too narrow increases accidental taps",
  "라벨 없이 3열 이상이면 항목 구분이 어렵습니다": "3+ columns without labels makes items hard to distinguish",
  "작은 크기의 아이콘만 표시하면 의미를 파악하기 어렵습니다": "Small icon-only labels are hard to understand",
  "아이콘만 사용하면 의미가 모호할 수 있습니다. 텍스트를 함께 표시하세요": "Icon-only labels can be ambiguous. Include text for clarity",
  "Wide 사이드바는 detail 영역을 좁게 만듭니다. iPad에서만 권장합니다": "Wide sidebar narrows the detail area. Recommended for iPad only",
  "섹션 헤더와 아이콘 없이 리스트를 표시하면 항목 구분이 어렵습니다": "List without section headers and icons makes items hard to distinguish",
  "Inset Grouped 스타일에서 chevron 없으면 탭 가능한지 알 수 없습니다": "Without chevrons in Inset Grouped style, users can't tell items are tappable",
  "trailing 버튼이 너무 많으면 네비게이션 바가 복잡해집니다 (최대 2개 권장)": "Too many trailing buttons clutter the navigation bar (max 2 recommended)",
  "Large 타이틀 + 검색 바는 스크린 공간을 많이 차지합니다": "Large title + search bar takes up significant screen space",
  "4개 이상의 액션은 사용자를 압도합니다. 중요한 것만 남기세요": "4+ actions overwhelm users. Keep only the essential ones",
  "Destructive 액션이 있을 때는 타이틀로 맥락을 설명하세요": "Include a title for context when destructive actions are present",
  "3개 이상의 버튼은 사용자를 혼란스럽게 합니다. Action Sheet를 고려하세요": "3+ buttons confuse users. Consider using an Action Sheet instead",
  "Destructive 단독 버튼은 위험합니다. Cancel 버튼을 추가하세요": "Destructive-only button is dangerous. Add a Cancel button",
  "Drag indicator 없이 sheet를 표시하면 닫는 방법을 알 수 없습니다": "Sheet without drag indicator doesn't show how to dismiss",
  "닫기 버튼도 drag indicator도 없으면 sheet를 닫을 수 없습니다": "Without dismiss button or drag indicator, sheet cannot be closed",
  "6개 이상의 메뉴 항목은 과합니다. 그룹핑하거나 줄이세요": "6+ menu items is excessive. Group or reduce them",
  "4개 이상의 항목에는 divider로 그룹을 나누세요": "Use dividers to group 4+ items",
  "Secure 필드에 clear 버튼은 보안상 위험할 수 있습니다": "Clear button on secure field can be a security concern",
  "날짜만 선택할 때 Wheel은 과합니다. Compact를 권장합니다": "Wheel is overkill for date-only selection. Use Compact instead",
  "8개 이상 항목의 Wheel 피커는 스크롤이 많아집니다": "Wheel picker with 8+ items requires excessive scrolling",
  "3개 이하 항목에는 Segmented Control이 더 적합합니다": "For 3 or fewer items, Segmented Control is more appropriate",
  "Step이 너무 크면 세밀한 조절이 불가능합니다": "Step too large prevents fine-grained control",
  "넓은 범위에는 Slider가 더 적합합니다": "For wide ranges, Slider is more appropriate",
  "투명도가 너무 낮으면 선택한 색상을 확인하기 어렵습니다": "Very low opacity makes the selected color hard to see",
  "5개 이상의 링은 구분하기 어렵습니다 (Apple은 최대 3개)": "5+ rings are hard to distinguish (Apple uses max 3)",
  "라벨 없는 게이지는 값의 의미를 알 수 없습니다": "Gauge without label doesn't convey what the value means",
  "앱 아이콘과 액션 모두 숨기면 공유 시트가 비어 보입니다": "Hiding both app icons and actions makes the share sheet appear empty",
  "기본 편집 액션(Cut/Copy/Paste) 없이 커스텀만 표시하면 혼란스럽습니다": "Showing only custom actions without Cut/Copy/Paste is confusing",
  "5개 이상의 메뉴 항목에는 divider로 그룹을 나누세요": "Use dividers to group 5+ menu items",
  "4개 이상의 항목에는 아이콘으로 빠른 인지를 돕습니다": "Icons help quick recognition for 4+ items",
  "선택 인디케이터 없으면 현재 선택된 값을 알 수 없습니다": "Without selection indicator, current value is not visible",
  "6개 이상의 항목은 Pop-Up보다 Picker를 권장합니다": "For 6+ items, Picker is recommended over Pop-Up Button",
  "5개 이상의 항목에는 divider로 그룹을 나누세요": "Use dividers to group 5+ items",
  "6개 이상의 툴바 아이템은 과합니다. 핵심만 남기세요": "6+ toolbar items is excessive. Keep only essential ones",
  "텍스트 전용 4개 이상이면 공간이 부족합니다. 아이콘을 사용하세요": "4+ text-only items run out of space. Use icons instead",
  "Scope Bar를 쓰면 검색 제안도 함께 제공하는 것이 좋습니다": "When using Scope Bar, providing search suggestions is recommended",
  "아이콘 없는 사이드바는 항목을 빠르게 구분하기 어렵습니다": "Sidebar without icons makes items hard to quickly distinguish",
  "4개 이상의 섹션에서는 배지로 알림 상태를 표시하세요": "With 4+ sections, use badges to indicate notification status",
  "8개 이상의 페이지는 dots로 표현하기 어렵습니다. 다른 네비게이션을 고려하세요": "8+ pages are hard to represent with dots. Consider alternative navigation",
  "외부 탭으로 닫히지 않으면 사용자가 갇힌 느낌을 받습니다": "Not dismissing on outside tap makes users feel trapped",
  "Large 팝오버는 화면을 너무 많이 가립니다. Sheet를 고려하세요": "Large popovers cover too much screen. Consider using a Sheet",
  // OK message
  "HIG 가이드라인을 준수하고 있습니다": "Following HIG guidelines correctly",
};

const enFiles = fs.readdirSync(componentsDir).filter(f => f.endsWith('.en.html'));
let count = 0;

for (const file of enFiles) {
  const filePath = path.join(componentsDir, file);
  let html = fs.readFileSync(filePath, 'utf-8');
  
  if (!html.includes('hig-violations')) continue;
  
  // Replace all Korean violation messages with English
  const sorted = Object.entries(translations).sort((a, b) => b[0].length - a[0].length);
  for (const [ko, en] of sorted) {
    html = html.split(ko).join(en);
  }
  
  // Also fix the v.ko references to display English
  // The JS uses violations[0].ko — this is fine since we replaced the ko values
  
  fs.writeFileSync(filePath, html);
  count++;
  console.log(`EN fixed: ${file}`);
}

console.log(`\nDone: ${count} EN files with translated violations`);
