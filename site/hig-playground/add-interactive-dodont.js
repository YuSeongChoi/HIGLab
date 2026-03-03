#!/usr/bin/env node
// Add interactive Do/Don't to all HIG Playground component pages
const fs = require('fs');
const path = require('path');

const componentsDir = path.join(__dirname, 'components');
const files = fs.readdirSync(componentsDir).filter(f => f.endsWith('.html') && f !== 'buttons.html');

// CSS to inject (after last existing CSS rule before </style>)
const extraCSS = `
/* ─── Interactive Do/Don't ─── */
.do-dont-tabs{
  display:flex;gap:0;margin-bottom:16px;border-radius:12px;overflow:hidden;
  border:1px solid var(--border);
}
.do-dont-tab{
  flex:1;padding:10px 16px;cursor:pointer;
  font-size:13px;font-weight:700;text-align:center;
  transition:all .2s;position:relative;
  background:var(--bg, #f2f2f7);color:var(--text-2, #6e6e73);
}
.do-dont-tab.active-do{
  background:rgba(52,199,89,0.12);color:#34C759;
  box-shadow:inset 0 -3px 0 #34C759;
}
.do-dont-tab.active-dont{
  background:rgba(255,59,48,0.12);color:#FF3B30;
  box-shadow:inset 0 -3px 0 #FF3B30;
}
.do-dont-tab:hover:not(.active-do):not(.active-dont){
  background:rgba(0,0,0,0.04);
}
.do-dont-detail{display:none}
.do-dont-detail.active{display:block}
.hig-warning{
  display:none;
  position:absolute;bottom:60px;left:16px;right:16px;
  background:rgba(255,59,48,0.95);color:#fff;
  padding:10px 14px;border-radius:12px;
  font-size:12px;font-weight:600;
  font-family:-apple-system,BlinkMacSystemFont,sans-serif;
  text-align:center;z-index:20;
  animation:warningSlide .3s ease;
  box-shadow:0 4px 20px rgba(255,59,48,0.3);
}
.hig-warning.show{display:block}
@keyframes warningSlide{
  from{transform:translateY(20px);opacity:0}
  to{transform:translateY(0);opacity:1}
}`;

// Component-specific Don't screen content
const dontExamples = {
  'charts.html': {
    warning: '⚠️ HIG 위반: 차트가 읽기 어렵습니다',
    items: [
      { title: '❌ 3D Effects', desc: '3D 효과로 데이터 왜곡', html: '<div style="background:#F2F2F7;padding:20px;border-radius:14px;text-align:center"><div style="transform:perspective(200px) rotateX(30deg);margin:0 auto"><div style="display:flex;gap:4px;align-items:flex-end;justify-content:center;height:120px"><div style="width:30px;background:linear-gradient(#007AFF,#5856D6);height:80px;border-radius:4px"></div><div style="width:30px;background:linear-gradient(#34C759,#30D158);height:50px;border-radius:4px"></div><div style="width:30px;background:linear-gradient(#FF9500,#FF6B00);height:100px;border-radius:4px"></div><div style="width:30px;background:linear-gradient(#FF3B30,#FF6482);height:30px;border-radius:4px"></div></div></div><p style="font-size:10px;color:#8E8E93;margin-top:8px">3D 원근감이 데이터를 왜곡합니다</p></div>' },
      { title: '❌ Too Many Colors', desc: '과도한 색상 사용', html: '<div style="background:#F2F2F7;padding:20px;border-radius:14px;text-align:center"><div style="display:flex;gap:2px;align-items:flex-end;justify-content:center;height:100px"><div style="width:16px;background:#FF0000;height:40px"></div><div style="width:16px;background:#FF8800;height:60px"></div><div style="width:16px;background:#FFFF00;height:35px"></div><div style="width:16px;background:#00FF00;height:80px"></div><div style="width:16px;background:#0088FF;height:45px"></div><div style="width:16px;background:#8800FF;height:70px"></div><div style="width:16px;background:#FF00FF;height:55px"></div><div style="width:16px;background:#00FFFF;height:90px"></div><div style="width:16px;background:#888888;height:25px"></div><div style="width:16px;background:#FF4488;height:65px"></div></div><p style="font-size:8px;color:#8E8E93;margin-top:4px">10개 항목의 색을 구분할 수 없습니다</p></div>' },
    ]
  },
  'image-views.html': {
    warning: '⚠️ HIG 위반: 이미지가 올바르게 표시되지 않습니다',
    items: [
      { title: '❌ Stretched Image', desc: '비율 무시 늘리기', html: '<div style="background:#F2F2F7;padding:16px;border-radius:14px;text-align:center"><div style="width:100%;height:80px;background:linear-gradient(45deg,#5AC8FA,#007AFF);border-radius:8px;transform:scaleX(1.5)"></div><p style="font-size:10px;color:#8E8E93;margin-top:8px">aspectRatio를 무시하면 이미지가 왜곡됩니다</p></div>' },
      { title: '❌ Low Resolution', desc: '저해상도 이미지', html: '<div style="background:#F2F2F7;padding:16px;border-radius:14px;text-align:center"><div style="width:100px;height:100px;margin:0 auto;background:repeating-conic-gradient(#ccc 0% 25%,#999 0% 50%) 0 0/16px 16px;border-radius:8px;image-rendering:pixelated"></div><p style="font-size:10px;color:#8E8E93;margin-top:8px">Retina 디스플레이에 저해상도 이미지</p></div>' },
    ]
  },
  'text-views.html': {
    warning: '⚠️ HIG 위반: 텍스트가 가독성이 떨어집니다',
    items: [
      { title: '❌ Fixed Font Size', desc: '고정 폰트 크기', html: '<div style="background:#fff;padding:16px;border-radius:14px"><p style="font-size:8px;line-height:1.2;color:#000">This text uses a tiny fixed font size of 8px. It completely ignores Dynamic Type settings and will be unreadable for many users, especially those with visual impairments.</p></div>' },
      { title: '❌ Poor Contrast', desc: '낮은 대비', html: '<div style="background:#fff;padding:16px;border-radius:14px"><p style="font-size:15px;color:#D1D1D6">Light gray text on white background is very hard to read and fails WCAG contrast requirements.</p></div>' },
      { title: '❌ All Caps Body', desc: '본문 전체 대문자', html: '<div style="background:#fff;padding:16px;border-radius:14px"><p style="font-size:14px;text-transform:uppercase;letter-spacing:2px;color:#000;font-weight:700">THIS IS A LONG PARAGRAPH OF TEXT IN ALL CAPS WHICH IS EXTREMELY DIFFICULT TO READ FOR EXTENDED PERIODS.</p></div>' },
    ]
  },
  'web-views.html': {
    warning: '⚠️ HIG 위반: 웹뷰 사용이 부적절합니다',
    items: [
      { title: '❌ No Loading State', desc: '로딩 표시 없음', html: '<div style="background:#fff;padding:16px;border-radius:14px;height:120px;display:flex;align-items:center;justify-content:center"><p style="font-size:13px;color:#C7C7CC">빈 화면... 로딩 중인지 알 수 없음</p></div>' },
      { title: '❌ No Error Handling', desc: '오류 처리 없음', html: '<div style="background:#fff;padding:16px;border-radius:14px;text-align:center"><p style="font-size:11px;color:#FF3B30;font-family:monospace">Error -1009: The Internet connection appears to be offline.</p><p style="font-size:10px;color:#8E8E93;margin-top:4px">기술적 에러 메시지를 그대로 노출</p></div>' },
    ]
  },
  'collections.html': {
    warning: '⚠️ HIG 위반: 그리드 레이아웃이 부적절합니다',
    items: [
      { title: '❌ Tiny Tap Targets', desc: '너무 작은 탭 영역', html: '<div style="background:#F2F2F7;padding:8px;border-radius:14px;display:grid;grid-template-columns:repeat(6,1fr);gap:2px">' + Array(18).fill('<div style="background:#007AFF;height:20px;border-radius:2px;font-size:6px;color:#fff;display:flex;align-items:center;justify-content:center">item</div>').join('') + '</div>' },
      { title: '❌ Inconsistent Sizes', desc: '불균일한 크기', html: '<div style="background:#F2F2F7;padding:12px;border-radius:14px;display:flex;flex-wrap:wrap;gap:4px"><div style="background:#007AFF;width:80px;height:80px;border-radius:8px"></div><div style="background:#34C759;width:40px;height:120px;border-radius:8px"></div><div style="background:#FF9500;width:120px;height:40px;border-radius:8px"></div><div style="background:#AF52DE;width:60px;height:60px;border-radius:8px"></div></div>' },
    ]
  },
  'disclosure-groups.html': {
    warning: '⚠️ HIG 위반: 깊은 중첩이 혼란을 줍니다',
    items: [
      { title: '❌ Deep Nesting', desc: '4단계 이상 중첩', html: '<div style="background:#fff;padding:12px;border-radius:14px;font-size:12px;font-family:-apple-system,sans-serif"><div style="padding-left:0px">▶ Level 1<div style="padding-left:16px;margin-top:4px">▶ Level 2<div style="padding-left:16px;margin-top:4px">▶ Level 3<div style="padding-left:16px;margin-top:4px">▶ Level 4<div style="padding-left:16px;margin-top:4px;color:#8E8E93">▶ Level 5 — 사용자가 길을 잃습니다</div></div></div></div></div></div>' },
    ]
  },
  'labels.html': {
    warning: '⚠️ HIG 위반: 라벨이 혼란을 줍니다',
    items: [
      { title: '❌ Ambiguous Icons', desc: '아이콘만 단독 사용', html: '<div style="background:#fff;padding:16px;border-radius:14px;display:flex;gap:20px;justify-content:center;font-size:24px">🔧 ⚙️ 🛠️ ⚡</div><p style="font-size:10px;color:#8E8E93;text-align:center;margin-top:8px">텍스트 없이 비슷한 아이콘만 나열</p>' },
      { title: '❌ Mismatched Icons', desc: '의미 불일치 아이콘', html: '<div style="background:#fff;padding:16px;border-radius:14px;font-size:14px;font-family:-apple-system,sans-serif"><div style="display:flex;align-items:center;gap:8px;margin-bottom:8px">🗑️ Save Document</div><div style="display:flex;align-items:center;gap:8px;margin-bottom:8px">📤 Delete Account</div><div style="display:flex;align-items:center;gap:8px">✅ Cancel</div></div>' },
    ]
  },
  'outline-views.html': {
    warning: '⚠️ HIG 위반: 계층 구조가 불명확합니다',
    items: [
      { title: '❌ Flat Hierarchy', desc: '깊은 계층을 평면화', html: '<div style="background:#fff;padding:12px;border-radius:14px;font-size:12px;font-family:-apple-system,sans-serif"><div style="padding:6px 0;border-bottom:1px solid #E5E5EA">Documents / Work / 2024 / Q1 / Reports / Final</div><div style="padding:6px 0;border-bottom:1px solid #E5E5EA">Documents / Work / 2024 / Q1 / Reports / Draft</div><div style="padding:6px 0;border-bottom:1px solid #E5E5EA">Documents / Work / 2024 / Q2 / Reports / Final</div><div style="padding:6px 0;color:#8E8E93">경로가 길어서 읽기 어렵습니다</div></div>' },
    ]
  },
  'split-views.html': {
    warning: '⚠️ HIG 위반: 분할 뷰가 부적절합니다',
    items: [
      { title: '❌ Forced on Compact', desc: '작은 화면에 강제 분할', html: '<div style="background:#F2F2F7;padding:4px;border-radius:14px;display:flex;gap:2px;height:120px"><div style="background:#fff;flex:1;border-radius:8px;padding:4px;font-size:7px;overflow:hidden;color:#000">Sidebar items are squeezed into tiny space making them unreadable</div><div style="background:#fff;flex:1;border-radius:8px;padding:4px;font-size:7px;overflow:hidden;color:#000">Detail content is also cramped and unusable on small screen</div></div>' },
    ]
  },
  'tables.html': {
    warning: '⚠️ HIG 위반: 테이블이 가독성이 떨어집니다',
    items: [
      { title: '❌ Cramped Columns', desc: '컬럼이 너무 좁음', html: '<div style="background:#fff;padding:8px;border-radius:14px;font-size:7px;font-family:-apple-system,sans-serif;overflow:hidden"><table style="width:100%;border-collapse:collapse"><tr style="background:#F2F2F7"><th style="padding:2px;border:1px solid #E5E5EA">Name</th><th style="padding:2px;border:1px solid #E5E5EA">Email</th><th style="padding:2px;border:1px solid #E5E5EA">Phone</th><th style="padding:2px;border:1px solid #E5E5EA">Address</th><th style="padding:2px;border:1px solid #E5E5EA">City</th></tr><tr><td style="padding:2px;border:1px solid #E5E5EA">John...</td><td style="padding:2px;border:1px solid #E5E5EA">john@...</td><td style="padding:2px;border:1px solid #E5E5EA">010-...</td><td style="padding:2px;border:1px solid #E5E5EA">123 M...</td><td style="padding:2px;border:1px solid #E5E5EA">Seo...</td></tr></table></div>' },
    ]
  },
  'color-wells.html': {
    warning: '⚠️ HIG 위반: 색상 선택기가 사용하기 어렵습니다',
    items: [
      { title: '❌ Tiny Color Target', desc: '너무 작은 색상 원', html: '<div style="background:#fff;padding:20px;border-radius:14px;text-align:center"><div style="width:16px;height:16px;border-radius:50%;background:#007AFF;margin:0 auto;border:1px solid #E5E5EA"></div><p style="font-size:10px;color:#8E8E93;margin-top:12px">탭하기 어려운 16px 색상 선택기</p></div>' },
    ]
  },
  'pickers.html': {
    warning: '⚠️ HIG 위반: 피커 사용이 부적절합니다',
    items: [
      { title: '❌ Too Many Items', desc: '과도한 선택지', html: '<div style="background:#fff;padding:12px;border-radius:14px;font-size:11px;font-family:-apple-system,sans-serif;max-height:120px;overflow-y:auto">' + Array(30).fill(0).map((_,i) => `<div style="padding:4px 0;border-bottom:1px solid #F2F2F7;color:#000">Option ${i+1}: Very long description text here</div>`).join('') + '</div>' },
    ]
  },
  'steppers.html': {
    warning: '⚠️ HIG 위반: 스테퍼가 사용하기 어렵습니다',
    items: [
      { title: '❌ No Value Display', desc: '현재 값 미표시', html: '<div style="background:#fff;padding:20px;border-radius:14px;text-align:center"><div style="display:inline-flex;border:1px solid #C7C7CC;border-radius:8px;overflow:hidden"><div style="padding:8px 16px;font-size:16px;color:#007AFF;border-right:1px solid #C7C7CC">−</div><div style="padding:8px 16px;font-size:16px;color:#007AFF">+</div></div><p style="font-size:10px;color:#8E8E93;margin-top:8px">현재 값이 안 보여서 알 수 없음</p></div>' },
      { title: '❌ Unreasonable Steps', desc: '비합리적 증감 단위', html: '<div style="background:#fff;padding:16px;border-radius:14px;text-align:center;font-family:-apple-system,sans-serif"><div style="font-size:24px;font-weight:700;color:#000">7</div><div style="font-size:11px;color:#8E8E93;margin-top:4px">수량 (증감 단위: 17)</div><p style="font-size:10px;color:#FF3B30;margin-top:8px">왜 17씩 증가하나요?</p></div>' },
    ]
  },
  'activity-rings.html': {
    warning: '⚠️ HIG 위반: 링이 읽기 어렵습니다',
    items: [
      { title: '❌ Too Many Rings', desc: '링 개수 과다', html: '<div style="background:#000;padding:20px;border-radius:14px;text-align:center"><svg width="140" height="140" viewBox="0 0 140 140">' + [60,55,50,45,40,35,30].map((r,i) => `<circle cx="70" cy="70" r="${r}" fill="none" stroke="hsl(${i*50},70%,50%)" stroke-width="4" stroke-dasharray="${r*3.14} ${r*6.28}" opacity="0.7"/>`).join('') + '</svg><p style="font-size:10px;color:#8E8E93;margin-top:8px">7개 링은 구분이 불가능합니다</p></div>' },
    ]
  },
  'gauges.html': {
    warning: '⚠️ HIG 위반: 게이지가 오해를 줍니다',
    items: [
      { title: '❌ No Context', desc: '라벨/범위 없음', html: '<div style="background:#fff;padding:20px;border-radius:14px;text-align:center"><div style="width:80px;height:8px;background:#E5E5EA;border-radius:4px;margin:0 auto"><div style="width:60%;height:100%;background:#FF9500;border-radius:4px"></div></div><p style="font-size:10px;color:#8E8E93;margin-top:12px">60%? 0.6? 6/10? 기준을 알 수 없음</p></div>' },
    ]
  },
  'activity-views.html': {
    warning: '⚠️ HIG 위반: 공유 시트가 혼란스럽습니다',
    items: [
      { title: '❌ Too Many Options', desc: '과도한 공유 옵션', html: '<div style="background:#fff;padding:12px;border-radius:14px;font-size:10px;font-family:-apple-system,sans-serif">' + Array(12).fill(0).map((_,i) => `<div style="padding:3px 0;border-bottom:1px solid #F2F2F7;color:#000">Share Option ${i+1}</div>`).join('') + '</div>' },
    ]
  },
  'edit-menus.html': {
    warning: '⚠️ HIG 위반: 편집 메뉴가 부적절합니다',
    items: [
      { title: '❌ Irrelevant Actions', desc: '무관한 액션 포함', html: '<div style="background:#333;padding:8px 12px;border-radius:10px;display:flex;gap:12px;justify-content:center;margin:20px auto;width:fit-content"><span style="color:#fff;font-size:12px">Cut</span><span style="color:#fff;font-size:12px">Copy</span><span style="color:#fff;font-size:12px">Paste</span><span style="color:#fff;font-size:12px">Delete Account</span><span style="color:#FF3B30;font-size:12px">Format Disk</span></div>' },
    ]
  },
  'menus.html': {
    warning: '⚠️ HIG 위반: 메뉴 구성이 부적절합니다',
    items: [
      { title: '❌ No Grouping', desc: 'divider 없는 긴 메뉴', html: '<div style="background:#fff;padding:8px 0;border-radius:14px;font-size:13px;font-family:-apple-system,sans-serif;box-shadow:0 4px 20px rgba(0,0,0,0.15)">' + ['New', 'Open', 'Save', 'Print', 'Share', 'Export', 'Duplicate', 'Move', 'Rename', 'Delete', 'Archive', 'Settings'].map(t => `<div style="padding:8px 16px;color:#000">${t}</div>`).join('') + '</div>' },
    ]
  },
  'pop-up-buttons.html': {
    warning: '⚠️ HIG 위반: 팝업 버튼이 혼란스럽습니다',
    items: [
      { title: '❌ No Selection Indicator', desc: '선택 상태 미표시', html: '<div style="background:#fff;padding:16px;border-radius:14px;font-family:-apple-system,sans-serif"><div style="padding:8px 12px;background:#F2F2F7;border-radius:8px;font-size:13px;color:#000">Choose option ▾</div><p style="font-size:10px;color:#8E8E93;margin-top:8px">현재 선택된 값이 보이지 않음</p></div>' },
    ]
  },
  'pull-down-buttons.html': {
    warning: '⚠️ HIG 위반: 풀다운 버튼이 부적절합니다',
    items: [
      { title: '❌ Destructive Hidden', desc: '위험 액션이 숨겨짐', html: '<div style="background:#fff;padding:8px 0;border-radius:14px;font-size:13px;font-family:-apple-system,sans-serif;box-shadow:0 4px 20px rgba(0,0,0,0.15)"><div style="padding:8px 16px;color:#000">Edit</div><div style="padding:8px 16px;color:#000">Share</div><div style="padding:8px 16px;color:#000">Move</div><div style="padding:8px 16px;color:#FF3B30">Delete Everything Forever</div></div><p style="font-size:10px;color:#8E8E93;text-align:center;margin-top:4px">경고 없이 파괴 액션이 일반 메뉴에</p>' },
    ]
  },
  'toolbars.html': {
    warning: '⚠️ HIG 위반: 툴바가 복잡합니다',
    items: [
      { title: '❌ Too Many Items', desc: '과도한 아이템', html: '<div style="background:#F8F8F8;padding:8px;border-radius:14px;display:flex;justify-content:space-around;font-size:18px;border-top:1px solid #E5E5EA">📝✂️📋🔍📤🖨️📎🗂️⚙️🔧</div><p style="font-size:10px;color:#8E8E93;text-align:center;margin-top:4px">10개 아이콘은 구분이 어렵습니다</p>' },
    ]
  },
  'search-fields.html': {
    warning: '⚠️ HIG 위반: 검색 UI가 부적절합니다',
    items: [
      { title: '❌ No Placeholder', desc: 'placeholder 없음', html: '<div style="background:#fff;padding:16px;border-radius:14px"><div style="background:#E5E5EA;padding:8px 12px;border-radius:10px;font-size:14px;color:transparent;font-family:-apple-system,sans-serif">.</div><p style="font-size:10px;color:#8E8E93;margin-top:8px">무엇을 검색하는 필드인지 알 수 없음</p></div>' },
    ]
  },
  'sidebars.html': {
    warning: '⚠️ HIG 위반: 사이드바 구성이 부적절합니다',
    items: [
      { title: '❌ No Icons', desc: '아이콘 없는 단조로운 목록', html: '<div style="background:#F2F2F7;padding:12px;border-radius:14px;font-size:13px;font-family:-apple-system,sans-serif">' + ['Inbox', 'Sent', 'Drafts', 'Trash', 'Archive', 'Spam', 'All Mail', 'Starred', 'Important', 'Labels'].map(t => `<div style="padding:6px 8px;color:#000">${t}</div>`).join('') + '<p style="font-size:10px;color:#8E8E93;margin-top:4px">아이콘과 섹션 구분 없이 나열</p></div>' },
    ]
  },
  'page-controls.html': {
    warning: '⚠️ HIG 위반: 페이지 컨트롤이 부적절합니다',
    items: [
      { title: '❌ Too Many Dots', desc: '점이 너무 많음', html: '<div style="background:#fff;padding:20px;border-radius:14px;text-align:center"><div style="display:flex;gap:3px;justify-content:center">' + Array(20).fill(0).map((_,i) => `<div style="width:6px;height:6px;border-radius:50%;background:${i===7?'#007AFF':'#C7C7CC'}"></div>`).join('') + '</div><p style="font-size:10px;color:#8E8E93;margin-top:12px">20개 페이지 — 현재 위치 파악 불가</p></div>' },
    ]
  },
  'popovers.html': {
    warning: '⚠️ HIG 위반: 팝오버가 부적절합니다',
    items: [
      { title: '❌ Too Large', desc: '화면 전체를 가리는 팝오버', html: '<div style="background:rgba(0,0,0,0.4);padding:8px;border-radius:14px;height:140px;position:relative"><div style="position:absolute;inset:8px;background:#fff;border-radius:12px;padding:12px"><p style="font-size:11px;color:#000">이 팝오버는 화면 전체를 차지합니다. 뒤에 있는 콘텐츠를 완전히 가려서 맥락을 잃게 됩니다.</p></div></div>' },
    ]
  },
  'action-sheets.html': {
    warning: '⚠️ HIG 위반: 액션 시트 구성이 부적절합니다',
    items: [
      { title: '❌ No Cancel Button', desc: 'Cancel 버튼 없음', html: '<div style="background:#F2F2F7;padding:8px;border-radius:14px"><div style="background:#fff;border-radius:14px;overflow:hidden"><div style="padding:12px;text-align:center;border-bottom:1px solid #E5E5EA;color:#007AFF;font-size:14px">Share</div><div style="padding:12px;text-align:center;border-bottom:1px solid #E5E5EA;color:#007AFF;font-size:14px">Copy</div><div style="padding:12px;text-align:center;color:#FF3B30;font-size:14px;font-weight:600">Delete</div></div><p style="font-size:10px;color:#8E8E93;text-align:center;margin-top:8px">Cancel이 없어서 닫을 수 없음</p></div>' },
    ]
  },
  'alerts.html': {
    warning: '⚠️ HIG 위반: Alert 사용이 부적절합니다',
    items: [
      { title: '❌ Vague Message', desc: '불명확한 메시지', html: '<div style="background:rgba(0,0,0,0.3);padding:20px;border-radius:14px;display:flex;align-items:center;justify-content:center"><div style="background:#fff;border-radius:14px;padding:20px;width:200px;text-align:center"><p style="font-size:15px;font-weight:600;color:#000">Error</p><p style="font-size:13px;color:#8E8E93;margin:8px 0">Something went wrong.</p><div style="border-top:1px solid #E5E5EA;padding:10px;color:#007AFF;font-size:15px">OK</div></div></div>' },
      { title: '❌ Too Many Buttons', desc: '버튼이 너무 많음', html: '<div style="background:rgba(0,0,0,0.3);padding:10px;border-radius:14px;display:flex;align-items:center;justify-content:center"><div style="background:#fff;border-radius:14px;padding:16px;width:220px;text-align:center"><p style="font-size:14px;font-weight:600;color:#000">Save?</p>' + ['Save', 'Don\'t Save', 'Save As...', 'Cancel', 'Help'].map(t => `<div style="border-top:1px solid #E5E5EA;padding:8px;color:#007AFF;font-size:13px">${t}</div>`).join('') + '</div></div>' },
    ]
  },
  'sheets.html': {
    warning: '⚠️ HIG 위반: Sheet 사용이 부적절합니다',
    items: [
      { title: '❌ No Drag Indicator', desc: '드래그 인디케이터 없음', html: '<div style="background:#F2F2F7;border-radius:14px;height:130px;position:relative"><div style="position:absolute;bottom:0;left:0;right:0;background:#fff;border-radius:14px 14px 0 0;padding:16px;height:90px"><p style="font-size:13px;color:#000;font-weight:600">Modal Content</p><p style="font-size:11px;color:#8E8E93;margin-top:4px">닫을 수 있는지 알 수 없음 — drag indicator가 없음</p></div></div>' },
    ]
  },
  'context-menus.html': {
    warning: '⚠️ HIG 위반: 컨텍스트 메뉴가 부적절합니다',
    items: [
      { title: '❌ Too Many Items', desc: '메뉴 항목 과다', html: '<div style="background:#fff;padding:4px 0;border-radius:14px;font-size:11px;font-family:-apple-system,sans-serif;box-shadow:0 4px 20px rgba(0,0,0,0.15);max-height:140px;overflow-y:auto">' + Array(15).fill(0).map((_,i) => `<div style="padding:6px 12px;color:#000">Action ${i+1}</div>`).join('') + '</div>' },
    ]
  },
  'navigation-bars.html': {
    warning: '⚠️ HIG 위반: 네비게이션 바가 부적절합니다',
    items: [
      { title: '❌ Too Many Buttons', desc: '버튼 과다', html: '<div style="background:#F8F8F8;padding:8px 12px;border-radius:14px;border-bottom:1px solid #E5E5EA;font-family:-apple-system,sans-serif"><div style="display:flex;justify-content:space-between;align-items:center"><span style="font-size:13px;color:#007AFF">← Back</span><span style="font-size:15px;font-weight:600;color:#000">Title</span><div style="display:flex;gap:4px"><span style="font-size:12px;color:#007AFF">Edit</span><span style="font-size:12px;color:#007AFF">Add</span><span style="font-size:12px;color:#007AFF">Sort</span><span style="font-size:12px;color:#007AFF">Filter</span><span style="font-size:12px;color:#007AFF">More</span></div></div></div>' },
    ]
  },
  'tab-bars.html': {
    warning: '⚠️ HIG 위반: 탭 바가 부적절합니다',
    items: [
      { title: '❌ Too Many Tabs', desc: '탭 과다', html: '<div style="background:#F8F8F8;padding:4px 0;border-radius:14px;border-top:1px solid #E5E5EA;display:flex;justify-content:space-around;font-size:8px;font-family:-apple-system,sans-serif;text-align:center">' + ['Home','Search','Add','Likes','Cart','Profile','Settings','More'].map((t,i) => `<div style="color:${i===0?'#007AFF':'#8E8E93'};padding:4px 0"><div style="font-size:14px">${['🏠','🔍','➕','❤️','🛒','👤','⚙️','•••'][i]}</div>${t}</div>`).join('') + '</div>' },
    ]
  },
  'lists.html': {
    warning: '⚠️ HIG 위반: 리스트 구성이 부적절합니다',
    items: [
      { title: '❌ No Separators', desc: '구분선 없음', html: '<div style="background:#fff;padding:12px;border-radius:14px;font-size:14px;font-family:-apple-system,sans-serif">' + ['Inbox', 'Important', 'Sent', 'Drafts', 'Trash'].map(t => `<div style="padding:10px 0;color:#000">${t}</div>`).join('') + '<p style="font-size:10px;color:#8E8E93;margin-top:4px">항목 경계가 불명확합니다</p></div>' },
    ]
  },
  'text-fields.html': {
    warning: '⚠️ HIG 위반: 텍스트 필드가 부적절합니다',
    items: [
      { title: '❌ No Labels', desc: '라벨/placeholder 없음', html: '<div style="background:#fff;padding:16px;border-radius:14px;display:flex;flex-direction:column;gap:12px"><div style="background:#F2F2F7;padding:10px;border-radius:8px;font-size:14px;color:transparent;min-height:34px">.</div><div style="background:#F2F2F7;padding:10px;border-radius:8px;font-size:14px;color:transparent;min-height:34px">.</div><div style="background:#F2F2F7;padding:10px;border-radius:8px;font-size:14px;color:transparent;min-height:34px">.</div><p style="font-size:10px;color:#8E8E93;margin-top:4px">어떤 정보를 입력하는 필드인지 알 수 없음</p></div>' },
    ]
  },
  'date-pickers.html': {
    warning: '⚠️ HIG 위반: 날짜 선택기가 부적절합니다',
    items: [
      { title: '❌ Wheel for Simple Date', desc: '간단한 선택에 Wheel 사용', html: '<div style="background:#fff;padding:12px;border-radius:14px;text-align:center"><div style="font-size:11px;color:#8E8E93;height:100px;display:flex;align-items:center;justify-content:center;border:1px dashed #C7C7CC;border-radius:8px">🎰 3개 휠(년/월/일)이 화면의 절반을 차지<br><br>Compact 스타일이면 한 줄로 충분합니다</div></div>' },
    ]
  },
  'scroll-views.html': {
    warning: '⚠️ HIG 위반: 스크롤 뷰가 부적절합니다',
    items: [
      { title: '❌ Nested Scrolling', desc: '같은 방향 중첩 스크롤', html: '<div style="background:#F2F2F7;padding:8px;border-radius:14px;height:120px;overflow-y:auto"><div style="background:#fff;border-radius:8px;padding:8px;margin-bottom:8px;height:100px;overflow-y:auto;font-size:11px;color:#000">Scrollable content inside another scrollable container. This creates confusing gesture conflicts where the user doesn\'t know which container will scroll.</div><div style="background:#fff;border-radius:8px;padding:8px;height:100px;overflow-y:auto;font-size:11px;color:#000">Another nested scroll view that fights with the parent scroll.</div></div>' },
    ]
  },
  'segmented-controls.html': {
    warning: '⚠️ HIG 위반: 세그먼트 컨트롤이 부적절합니다',
    items: [
      { title: '❌ Too Many Segments', desc: '세그먼트 과다', html: '<div style="background:#fff;padding:16px;border-radius:14px"><div style="display:flex;background:#E5E5EA;border-radius:8px;overflow:hidden">' + ['One','Two','Three','Four','Five','Six','Seven'].map((t,i) => `<div style="flex:1;padding:6px 2px;text-align:center;font-size:8px;color:#000;${i===0?'background:#fff;border-radius:7px;':''}">${t}</div>`).join('') + '</div><p style="font-size:10px;color:#8E8E93;margin-top:8px">7개 세그먼트 — 라벨이 잘립니다</p></div>' },
    ]
  },
  'progress-indicators.html': {
    warning: '⚠️ HIG 위반: 진행 표시가 부적절합니다',
    items: [
      { title: '❌ No Progress Context', desc: '맥락 없는 진행 표시', html: '<div style="background:#fff;padding:20px;border-radius:14px;text-align:center"><div style="width:100%;height:4px;background:#E5E5EA;border-radius:2px"><div style="width:45%;height:100%;background:#007AFF;border-radius:2px"></div></div><p style="font-size:10px;color:#8E8E93;margin-top:12px">45%? 뭐의 45%? 얼마나 남았나?</p></div>' },
    ]
  },
  'sliders.html': {
    warning: '⚠️ HIG 위반: 슬라이더가 부적절합니다',
    items: [
      { title: '❌ No Value Feedback', desc: '값 피드백 없음', html: '<div style="background:#fff;padding:20px;border-radius:14px"><div style="position:relative;height:4px;background:#E5E5EA;border-radius:2px"><div style="position:absolute;left:0;top:0;width:70%;height:100%;background:#007AFF;border-radius:2px"></div><div style="position:absolute;left:68%;top:-8px;width:20px;height:20px;background:#fff;border-radius:50%;box-shadow:0 1px 4px rgba(0,0,0,0.2)"></div></div><p style="font-size:10px;color:#8E8E93;margin-top:16px">최소/최대 라벨도 없고 현재 값도 안 보임</p></div>' },
    ]
  },
  'toggles.html': {
    warning: '⚠️ HIG 위반: 토글 사용이 부적절합니다',
    items: [
      { title: '❌ Ambiguous Label', desc: '불명확한 라벨', html: '<div style="background:#fff;padding:16px;border-radius:14px;font-family:-apple-system,sans-serif"><div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:12px"><span style="font-size:14px;color:#000">Setting A</span><div style="width:44px;height:26px;background:#34C759;border-radius:13px"></div></div><div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:12px"><span style="font-size:14px;color:#000">Option 2</span><div style="width:44px;height:26px;background:#E5E5EA;border-radius:13px"></div></div><div style="display:flex;justify-content:space-between;align-items:center"><span style="font-size:14px;color:#000">Toggle</span><div style="width:44px;height:26px;background:#34C759;border-radius:13px"></div></div><p style="font-size:10px;color:#8E8E93;margin-top:8px">무엇을 켜고 끄는지 알 수 없는 라벨</p></div>' },
    ]
  },
};

// Process each file
let updated = 0;
let skipped = 0;

for (const file of files) {
  const filePath = path.join(componentsDir, file);
  let html = fs.readFileSync(filePath, 'utf-8');
  
  // Skip if already has interactive do/dont
  if (html.includes('do-dont-tabs')) {
    skipped++;
    continue;
  }
  
  const examples = dontExamples[file];
  if (!examples) {
    console.log(`SKIP (no examples): ${file}`);
    skipped++;
    continue;
  }

  // 1. Inject CSS before </style>
  html = html.replace('</style>', extraCSS + '\n</style>');

  // 2. Add warning banner before home-indicator
  html = html.replace(
    '<div class="home-indicator">',
    `<div class="hig-warning" id="higWarning">${examples.warning}</div>\n      <div class="home-indicator">`
  );

  // 3. Replace static do-dont with interactive tabs
  // Find the guidelines body and replace do-dont section
  const doDontRegex = /<div class="do-dont">[\s\S]*?<\/div>\s*<\/div>\s*<\/div>/;
  
  // Build dont screen items
  const dontItems = examples.items.map(item => `
        <div class="screen-section">
          <div class="screen-section-title" style="color:#FF3B30">${item.title}</div>
          <div class="screen-card">${item.html}</div>
        </div>`).join('');

  // Extract component name from title
  const titleMatch = html.match(/<div class="screen-nav-title">(.*?)<\/div>/);
  const compName = titleMatch ? titleMatch[1] : file.replace('.html', '');

  // Find and replace the guidelines section
  const guidelinesBodyRegex = /(<div class="guidelines-body">)\s*<div class="do-dont">([\s\S]*?)<\/div>\s*<\/div>\s*<\/div>/;
  const doCardMatch = html.match(/<div class="do-card">([\s\S]*?)<\/div>/);
  const dontCardMatch = html.match(/<div class="dont-card">([\s\S]*?)<\/div>/);
  
  if (!doCardMatch || !dontCardMatch) {
    console.log(`SKIP (no do/dont cards): ${file}`);
    skipped++;
    continue;
  }

  const doContent = doCardMatch[1].replace(/Do<\/h4>/, '이렇게 하세요</h4>').replace('✓', '✓');
  const dontContent = dontCardMatch[1].replace(/Don't<\/h4>/, '이렇게 하지 마세요</h4>');

  const newGuidelines = `<div class="guidelines-header">&#128218; HIG Guidelines — 직접 체험하기</div>
      <div class="guidelines-body">
        <div class="do-dont-tabs">
          <div class="do-dont-tab active-do" id="tabDo" onclick="showDoState()">✓ Do — 올바른 예시</div>
          <div class="do-dont-tab" id="tabDont" onclick="showDontState()">✗ Don't — 나쁜 예시</div>
        </div>
        <div class="do-dont-detail active" id="detailDo">
          <div class="do-card">${doContent}</div>
        </div>
        <div class="do-dont-detail" id="detailDont">
          <div class="dont-card">${dontContent}
            <p style="margin-top:10px;font-size:12px;color:var(--text-3)">👆 iPhone 미리보기에서 나쁜 패턴을 직접 확인해보세요</p>
          </div>
        </div>`;

  // Replace guidelines header and do-dont section
  html = html.replace(
    /<div class="guidelines-header">.*?<\/div>\s*<div class="guidelines-body">\s*<div class="do-dont">[\s\S]*?<\/div>\s*<\/div>\s*<\/div>/,
    newGuidelines
  );

  // 4. Add Do/Don't JS before closing </script>
  const dontScreenJS = `
// ─── Do/Don't Interactive ───
let isDontMode = false;
const originalScreenHTML = document.getElementById('screenContent').innerHTML;
const dontScreenHTML = \`
  <div class="screen-nav-title">${compName}</div>
  ${dontItems.replace(/`/g, '\\`').replace(/\$/g, '\\$')}
  <div style="height:20px"></div>
\`;

function showDoState() {
  isDontMode = false;
  document.getElementById('tabDo').className = 'do-dont-tab active-do';
  document.getElementById('tabDont').className = 'do-dont-tab';
  document.getElementById('detailDo').className = 'do-dont-detail active';
  document.getElementById('detailDont').className = 'do-dont-detail';
  document.getElementById('screenContent').innerHTML = originalScreenHTML;
  document.getElementById('higWarning').classList.remove('show');
  if (typeof updatePreview === 'function') updatePreview();
}

function showDontState() {
  isDontMode = true;
  document.getElementById('tabDont').className = 'do-dont-tab active-dont';
  document.getElementById('tabDo').className = 'do-dont-tab';
  document.getElementById('detailDont').className = 'do-dont-detail active';
  document.getElementById('detailDo').className = 'do-dont-detail';
  document.getElementById('screenContent').innerHTML = dontScreenHTML;
  document.getElementById('higWarning').classList.add('show');
}`;

  html = html.replace('</script>', dontScreenJS + '\n</script>');

  fs.writeFileSync(filePath, html);
  updated++;
  console.log(`UPDATED: ${file}`);
}

console.log(`\nDone: ${updated} updated, ${skipped} skipped`);
