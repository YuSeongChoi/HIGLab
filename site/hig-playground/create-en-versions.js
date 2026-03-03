#!/usr/bin/env node
const fs = require('fs');
const path = require('path');

// ─── Translation map ───
const ko2en = {
  // Page titles and descriptions
  'iOS 버튼의 4가지 스타일과 3가지 크기를 직접 체험해보세요. 컨트롤 패널에서 속성을 변경하면 iPhone 화면에 즉시 반영됩니다.': 'Experience 4 button styles and 3 sizes interactively. Change properties in the control panel and see them reflected on the iPhone screen instantly.',
  'Apple Human Interface Guidelines의 UI 컴포넌트를 iPhone 목업 안에서 직접 체험해보세요. 스타일, 크기, 색상을 바꿔보며 HIG 원칙을 익힐 수 있습니다.': 'Experience Apple HIG UI components inside an iPhone mockup. Adjust styles, sizes, and colors to learn HIG principles.',
  
  // Common UI
  'HIG Guidelines — 직접 체험하기': 'HIG Guidelines — Try It Yourself',
  '✓ Do — 올바른 예시': '✓ Do — Good Example',
  '✗ Don\'t — 나쁜 예시': '✗ Don\'t — Bad Example',
  '이렇게 하세요': 'Do This',
  '이렇게 하지 마세요': 'Don\'t Do This',
  '👆 iPhone 미리보기에서 나쁜 패턴을 직접 확인해보세요': '👆 See the bad pattern in the iPhone preview above',
  
  // Warning messages
  '⚠️ HIG 위반: 이 패턴은 권장되지 않습니다': '⚠️ HIG Violation: This pattern is not recommended',
  '⚠️ HIG 위반: 차트가 읽기 어렵습니다': '⚠️ HIG Violation: Chart is hard to read',
  '⚠️ HIG 위반: 이미지가 올바르게 표시되지 않습니다': '⚠️ HIG Violation: Image is not displayed correctly',
  '⚠️ HIG 위반: 텍스트가 가독성이 떨어집니다': '⚠️ HIG Violation: Text has poor readability',
  '⚠️ HIG 위반: 웹뷰 사용이 부적절합니다': '⚠️ HIG Violation: Improper use of web view',
  '⚠️ HIG 위반: 그리드 레이아웃이 부적절합니다': '⚠️ HIG Violation: Improper grid layout',
  '⚠️ HIG 위반: 깊은 중첩이 혼란을 줍니다': '⚠️ HIG Violation: Deep nesting causes confusion',
  '⚠️ HIG 위반: 라벨이 혼란을 줍니다': '⚠️ HIG Violation: Labels cause confusion',
  '⚠️ HIG 위반: 계층 구조가 불명확합니다': '⚠️ HIG Violation: Unclear hierarchy',
  '⚠️ HIG 위반: 분할 뷰가 부적절합니다': '⚠️ HIG Violation: Improper split view usage',
  '⚠️ HIG 위반: 테이블이 가독성이 떨어집니다': '⚠️ HIG Violation: Table has poor readability',
  '⚠️ HIG 위반: 색상 선택기가 사용하기 어렵습니다': '⚠️ HIG Violation: Color picker is hard to use',
  '⚠️ HIG 위반: 피커 사용이 부적절합니다': '⚠️ HIG Violation: Improper picker usage',
  '⚠️ HIG 위반: 스테퍼가 사용하기 어렵습니다': '⚠️ HIG Violation: Stepper is hard to use',
  '⚠️ HIG 위반: 링이 읽기 어렵습니다': '⚠️ HIG Violation: Rings are hard to read',
  '⚠️ HIG 위반: 게이지가 오해를 줍니다': '⚠️ HIG Violation: Gauge is misleading',
  '⚠️ HIG 위반: 공유 시트가 혼란스럽습니다': '⚠️ HIG Violation: Share sheet is confusing',
  '⚠️ HIG 위반: 편집 메뉴가 부적절합니다': '⚠️ HIG Violation: Improper edit menu',
  '⚠️ HIG 위반: 메뉴 구성이 부적절합니다': '⚠️ HIG Violation: Improper menu structure',
  '⚠️ HIG 위반: 팝업 버튼이 혼란스럽습니다': '⚠️ HIG Violation: Pop-up button is confusing',
  '⚠️ HIG 위반: 풀다운 버튼이 부적절합니다': '⚠️ HIG Violation: Improper pull-down button',
  '⚠️ HIG 위반: 툴바가 복잡합니다': '⚠️ HIG Violation: Toolbar is too complex',
  '⚠️ HIG 위반: 검색 UI가 부적절합니다': '⚠️ HIG Violation: Improper search UI',
  '⚠️ HIG 위반: 사이드바 구성이 부적절합니다': '⚠️ HIG Violation: Improper sidebar structure',
  '⚠️ HIG 위반: 페이지 컨트롤이 부적절합니다': '⚠️ HIG Violation: Improper page control',
  '⚠️ HIG 위반: 팝오버가 부적절합니다': '⚠️ HIG Violation: Improper popover usage',
  '⚠️ HIG 위반: 액션 시트 구성이 부적절합니다': '⚠️ HIG Violation: Improper action sheet structure',
  '⚠️ HIG 위반: Alert 사용이 부적절합니다': '⚠️ HIG Violation: Improper alert usage',
  '⚠️ HIG 위반: Sheet 사용이 부적절합니다': '⚠️ HIG Violation: Improper sheet usage',
  '⚠️ HIG 위반: 컨텍스트 메뉴가 부적절합니다': '⚠️ HIG Violation: Improper context menu',
  '⚠️ HIG 위반: 네비게이션 바가 부적절합니다': '⚠️ HIG Violation: Improper navigation bar',
  '⚠️ HIG 위반: 탭 바가 부적절합니다': '⚠️ HIG Violation: Improper tab bar',
  '⚠️ HIG 위반: 리스트 구성이 부적절합니다': '⚠️ HIG Violation: Improper list structure',
  '⚠️ HIG 위반: 텍스트 필드가 부적절합니다': '⚠️ HIG Violation: Improper text field',
  '⚠️ HIG 위반: 날짜 선택기가 부적절합니다': '⚠️ HIG Violation: Improper date picker',
  '⚠️ HIG 위반: 스크롤 뷰가 부적절합니다': '⚠️ HIG Violation: Improper scroll view',
  '⚠️ HIG 위반: 세그먼트 컨트롤이 부적절합니다': '⚠️ HIG Violation: Improper segmented control',
  '⚠️ HIG 위반: 진행 표시가 부적절합니다': '⚠️ HIG Violation: Improper progress indicator',
  '⚠️ HIG 위반: 슬라이더가 부적절합니다': '⚠️ HIG Violation: Improper slider usage',
  '⚠️ HIG 위반: 토글 사용이 부적절합니다': '⚠️ HIG Violation: Improper toggle usage',
  
  // Don't example descriptions (Korean inline text)
  '3D 원근감이 데이터를 왜곡합니다': 'The 3D perspective distorts the data',
  '10개 항목의 색을 구분할 수 없습니다': 'Cannot distinguish colors of 10 items',
  'aspectRatio를 무시하면 이미지가 왜곡됩니다': 'Ignoring aspectRatio distorts the image',
  'Retina 디스플레이에 저해상도 이미지': 'Low resolution image on Retina display',
  '빈 화면... 로딩 중인지 알 수 없음': 'Blank screen... cannot tell if loading',
  '기술적 에러 메시지를 그대로 노출': 'Exposing raw technical error message',
  '텍스트 없이 비슷한 아이콘만 나열': 'Only similar icons listed without text',
  '경로가 길어서 읽기 어렵습니다': 'Long paths are hard to read',
  '사용자가 길을 잃습니다': 'Users get lost',
  '탭하기 어려운 16px 색상 선택기': 'Hard to tap 16px color picker',
  '현재 값이 안 보여서 알 수 없음': 'Cannot see current value',
  '왜 17씩 증가하나요?': 'Why increment by 17?',
  '7개 링은 구분이 불가능합니다': 'Cannot distinguish 7 rings',
  '60%? 0.6? 6/10? 기준을 알 수 없음': '60%? 0.6? 6/10? No way to know the scale',
  '현재 선택된 값이 보이지 않음': 'Current selected value is not visible',
  '경고 없이 파괴 액션이 일반 메뉴에': 'Destructive action in regular menu without warning',
  '10개 아이콘은 구분이 어렵습니다': 'Hard to distinguish 10 icons',
  '무엇을 검색하는 필드인지 알 수 없음': 'Cannot tell what this search field is for',
  '아이콘과 섹션 구분 없이 나열': 'Listed without icons or section dividers',
  '20개 페이지 — 현재 위치 파악 불가': '20 pages — cannot find current position',
  'Cancel이 없어서 닫을 수 없음': 'Cannot dismiss — no Cancel button',
  '닫을 수 있는지 알 수 없음 — drag indicator가 없음': 'Cannot tell if dismissable — no drag indicator',
  '항목 경계가 불명확합니다': 'Item boundaries are unclear',
  '어떤 정보를 입력하는 필드인지 알 수 없음': 'Cannot tell what information to enter',
  '45%? 뭐의 45%? 얼마나 남았나?': '45%? 45% of what? How much is left?',
  '최소/최대 라벨도 없고 현재 값도 안 보임': 'No min/max labels and current value not visible',
  '무엇을 켜고 끄는지 알 수 없는 라벨': 'Labels that don\'t tell what they toggle',
  '7개 세그먼트 — 라벨이 잘립니다': '7 segments — labels get truncated',
  
  // Nav
  'HIG Playground': 'HIG Playground',
  'Home': 'Home',
  'Roadmap': 'Roadmap',

  // Index page categories & descriptions
  '4 components': '4 components',
  '7 components': '7 components',
  '8 components': '8 components',
  '5 components': '5 components',
  '3 components': '3 components',
  'Content': 'Content',
  'Layout': 'Layout',
  'Menus and Actions': 'Menus and Actions',
  'Navigation and Search': 'Navigation and Search',
  'Presentation': 'Presentation',
  'Selection and Input': 'Selection and Input',
  'Status': 'Status',

  // Card descriptions
  'Bar, Line, Area, Pie 차트 타입과 색상 스킴 체험': 'Experience Bar, Line, Area, Pie chart types and color schemes',
  'contentMode, aspectRatio, clipShape 조절': 'Adjust contentMode, aspectRatio, clipShape',
  'Font 스타일, line limit, truncation, Dynamic Type': 'Font styles, line limit, truncation, Dynamic Type',
  'WKWebView 컨테이너와 nav bar, progress 표시': 'WKWebView container with nav bar and progress',
  'LazyVGrid/LazyHGrid 레이아웃과 컬럼 수 조절': 'LazyVGrid/LazyHGrid layout with adjustable columns',
  'Expandable/Collapsible 섹션과 중첩 레벨': 'Expandable/Collapsible sections and nesting levels',
  'SF Symbol + 텍스트 조합과 label 스타일': 'SF Symbol + text combinations and label styles',
  'Plain/Inset Grouped 스타일과 swipe actions': 'Plain/Inset Grouped styles with swipe actions',
  '계층형 트리 리스트와 expand/collapse': 'Hierarchical tree list with expand/collapse',
  'NavigationSplitView의 sidebar + detail 레이아웃': 'NavigationSplitView sidebar + detail layout',
  '다중 컬럼 정렬 가능한 테이블 뷰': 'Multi-column sortable table view',
  'ShareLink/UIActivityViewController 공유 시트': 'ShareLink/UIActivityViewController share sheet',
  'Filled, Tinted, Bordered, Plain 스타일 + 3가지 크기': 'Filled, Tinted, Bordered, Plain styles + 3 sizes',
  'Long press 메뉴와 아이콘, divider 구성': 'Long press menu with icons and dividers',
  'Cut/Copy/Paste 편집 메뉴와 커스텀 액션': 'Cut/Copy/Paste edit menu with custom actions',
  'Pull-down 메뉴와 아이콘, divider, destructive 항목': 'Pull-down menu with icons, dividers, destructive items',
  '팝업 버튼의 선택 인디케이터와 스타일': 'Pop-up button selection indicator and styles',
  'Pull-down 버튼의 항목과 아이콘 구성': 'Pull-down button items and icon configuration',
  '아이콘/텍스트/혼합 스타일 툴바와 배치': 'Icon/text/mixed style toolbar and placement',
  'Large/Inline 타이틀과 back/trailing 버튼 배치': 'Large/Inline title with back/trailing buttons',
  '검색 바, scope bar, 검색 제안 UI': 'Search bar, scope bar, suggestions UI',
  'NavigationSplitView 사이드바와 섹션, 배지': 'NavigationSplitView sidebar with sections and badges',
  '3~5개 탭 구성과 badge, 선택 애니메이션': '3-5 tab configuration with badges and selection animation',
  'Vertical/Horizontal 스크롤과 paging, indicators': 'Vertical/Horizontal scrolling with paging and indicators',
  'Bottom sheet 스타일의 액션 목록과 cancel 버튼': 'Bottom sheet style action list with cancel button',
  '1~3 버튼 Alert과 destructive 액션 패턴': '1-3 button Alert with destructive action patterns',
  '페이지 인디케이터 dots와 스와이프 네비게이션': 'Page indicator dots with swipe navigation',
  'Popover의 방향, 크기, dismiss 동작': 'Popover direction, size, and dismiss behavior',
  'Modal sheet의 detent 크기와 drag indicator': 'Modal sheet detent sizes and drag indicator',
  'ColorPicker의 wheel/grid/spectrum 스타일': 'ColorPicker wheel/grid/spectrum styles',
  'Compact/Wheel/Graphical 스타일 비교': 'Compact/Wheel/Graphical style comparison',
  'Wheel, Menu, Segmented, Inline 피커 스타일': 'Wheel, Menu, Segmented, Inline picker styles',
  '2~5개 세그먼트의 선택 UI와 슬라이딩 애니메이션': '2-5 segment selection UI with sliding animation',
  '연속/단계 슬라이더와 최소/최대 아이콘 커스터마이징': 'Continuous/stepped slider with min/max icon customization',
  '+/- 증감 컨트롤과 값 표시, 범위 설정': '+/- increment control with value display and range',
  'Plain/Rounded 스타일과 keyboard type, secure field': 'Plain/Rounded styles with keyboard type and secure field',
  'iOS Switch 컨트롤의 on/off 애니메이션과 색상 커스터마이징': 'iOS Switch on/off animation with color customization',
  '동심원 진행 링과 애니메이션, 색상 커스터마이징': 'Concentric progress rings with animation and color customization',
  'Circular/Linear 게이지 인디케이터와 그라디언트': 'Circular/Linear gauge indicators with gradient',
  'ProgressView의 linear/circular 스타일과 진행률 조절': 'ProgressView linear/circular styles with progress control',

  // Do card items (Korean translations in do-card)
  'Filled</strong> 스타일을 주요 액션에 사용': 'Filled</strong> style for the primary action',
  '짧은 동사로 라벨 작성 ("Save", "Continue")': 'Use short verb phrases as labels ("Save", "Continue")',
  '버튼 텍스트는 1~2 단어로 제한': 'Limit button text to one or two words',
  '계층 구조에 맞는 스타일 사용 (Filled → Tinted → Plain)': 'Use styles matching hierarchy (Filled → Tinted → Plain)',
  '시스템 제공 버튼 스타일 사용': 'Use system-provided button styles',

  // Don't card items
  'Filled 버튼을 나란히 여러 개 배치하지 마세요': 'Don\'t place multiple Filled buttons side by side',
  '지나치게 긴 버튼 라벨은 피하세요': 'Avoid overly long button labels',
  '비파괴 액션에 destructive 스타일을 쓰지 마세요': 'Don\'t use destructive style for non-destructive actions',
  '모든 버튼을 같은 강조도로 만들지 마세요': 'Don\'t give all buttons the same emphasis level',
};

// Generic Korean patterns to translate
const patterns = [
  [/iOS (.*?)의 (.*?)를 직접 체험해보세요\./g, 'Experience iOS $1 $2 interactively.'],
  [/컨트롤 패널에서 속성을 변경하면 iPhone 화면에 즉시 반영됩니다/g, 'Change properties in the control panel to see them reflected on the iPhone screen instantly'],
  [/를 브라우저에서 직접 체험해보세요/g, ' interactively in the browser'],
  [/스타일을 직접 체험해보세요/g, 'styles interactively'],
];

function translateText(html) {
  // Apply exact replacements first (longest first to avoid partial matches)
  const sorted = Object.entries(ko2en).sort((a, b) => b[0].length - a[0].length);
  for (const [ko, en] of sorted) {
    html = html.split(ko).join(en);
  }
  // Apply regex patterns
  for (const [regex, replacement] of patterns) {
    html = html.replace(regex, replacement);
  }
  return html;
}

function createEnVersion(srcPath, destPath, isIndex = false) {
  let html = fs.readFileSync(srcPath, 'utf-8');
  
  // Change lang
  html = html.replace('<html lang="ko">', '<html lang="en">');
  
  // Translate content
  html = translateText(html);
  
  // Add language toggle button in header nav
  const koFile = path.basename(srcPath);
  if (isIndex) {
    html = html.replace(
      '<a href="https://github.com/M1zz/HIGLab">GitHub</a>\n    </div>',
      '<a href="https://github.com/M1zz/HIGLab">GitHub</a>\n      <a href="index.html" class="lang-toggle" style="font-size:12px;font-weight:600;color:#0071e3;text-decoration:none;padding:4px 10px;border:1.5px solid #0071e3;border-radius:12px;">🇰🇷 KO</a>\n    </div>'
    );
  } else {
    html = html.replace(
      '<a href="https://github.com/M1zz/HIGLab">GitHub</a>\n    </div>',
      '<a href="https://github.com/M1zz/HIGLab">GitHub</a>\n      <a href="' + koFile + '" class="lang-toggle" style="font-size:12px;font-weight:600;color:#0071e3;text-decoration:none;padding:4px 10px;border:1.5px solid #0071e3;border-radius:12px;">🇰🇷 KO</a>\n    </div>'
    );
  }
  
  // Fix .en.html links for component pages
  if (!isIndex) {
    // Breadcrumb links: ../index.html -> ../index.en.html
    html = html.replace(/href="\.\.\/index\.html"/g, 'href="../index.en.html"');
  }
  
  fs.writeFileSync(destPath, html);
}

// Add language toggle to Korean versions too
function addLangToggleToKo(filePath, enFile, isIndex = false) {
  let html = fs.readFileSync(filePath, 'utf-8');
  
  // Skip if already has lang toggle
  if (html.includes('lang-toggle')) return;
  
  if (isIndex) {
    html = html.replace(
      '<a href="https://github.com/M1zz/HIGLab">GitHub</a>\n    </div>',
      '<a href="https://github.com/M1zz/HIGLab">GitHub</a>\n      <a href="index.en.html" class="lang-toggle" style="font-size:12px;font-weight:600;color:#0071e3;text-decoration:none;padding:4px 10px;border:1.5px solid #0071e3;border-radius:12px;">🇺🇸 EN</a>\n    </div>'
    );
  } else {
    html = html.replace(
      '<a href="https://github.com/M1zz/HIGLab">GitHub</a>\n    </div>',
      '<a href="https://github.com/M1zz/HIGLab">GitHub</a>\n      <a href="' + enFile + '" class="lang-toggle" style="font-size:12px;font-weight:600;color:#0071e3;text-decoration:none;padding:4px 10px;border:1.5px solid #0071e3;border-radius:12px;">🇺🇸 EN</a>\n    </div>'
    );
  }
  
  fs.writeFileSync(filePath, html);
}

const playgroundDir = __dirname;
const componentsDir = path.join(playgroundDir, 'components');

// 1. Index page
const indexKo = path.join(playgroundDir, 'index.html');
const indexEn = path.join(playgroundDir, 'index.en.html');
createEnVersion(indexKo, indexEn, true);
addLangToggleToKo(indexKo, 'index.en.html', true);
console.log('index.html → index.en.html');

// Fix English index links to point to .en.html component files
let indexEnHtml = fs.readFileSync(indexEn, 'utf-8');
indexEnHtml = indexEnHtml.replace(/href="components\/([^"]+)\.html"/g, 'href="components/$1.en.html"');
fs.writeFileSync(indexEn, indexEnHtml);

// 2. Component pages
const componentFiles = fs.readdirSync(componentsDir).filter(f => f.endsWith('.html') && !f.endsWith('.en.html'));

for (const file of componentFiles) {
  const koPath = path.join(componentsDir, file);
  const enFile = file.replace('.html', '.en.html');
  const enPath = path.join(componentsDir, enFile);
  
  createEnVersion(koPath, enPath);
  addLangToggleToKo(koPath, enFile);
  console.log(`${file} → ${enFile}`);
}

// Fix English component page links
const enFiles = fs.readdirSync(componentsDir).filter(f => f.endsWith('.en.html'));
for (const file of enFiles) {
  const filePath = path.join(componentsDir, file);
  let html = fs.readFileSync(filePath, 'utf-8');
  // Fix index link in en pages
  html = html.replace(/href="\.\.\/index\.html"/g, 'href="../index.en.html"');
  // Fix playground index link  
  html = html.replace('href="index.html"', 'href="index.en.html"');
  html = html.replace('href="../index.html">HIG Playground', 'href="../index.en.html">HIG Playground');
  // Lang toggle should point to Korean version
  const koFile = file.replace('.en.html', '.html');
  // Already set correctly in createEnVersion
  fs.writeFileSync(filePath, html);
}

console.log(`\nDone: ${componentFiles.length + 1} English versions created`);
