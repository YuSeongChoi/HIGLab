#!/usr/bin/env node
const fs = require('fs');
const path = require('path');

const componentsDir = path.join(__dirname, 'components');

// CSS for inline violation warnings
const violationCSS = `
/* ─── Realtime HIG Violation Warnings ─── */
.hig-violations{
  margin-top:16px;display:flex;flex-direction:column;gap:8px;
}
.hig-violation-item{
  display:flex;align-items:flex-start;gap:8px;
  padding:10px 14px;border-radius:10px;
  background:rgba(255,59,48,0.08);border:1px solid rgba(255,59,48,0.2);
  font-size:12px;line-height:1.5;color:#FF3B30;
  animation:violationFadeIn .3s ease;
}
.hig-violation-item .v-icon{flex-shrink:0;font-size:14px;margin-top:1px}
.hig-violation-item .v-text{flex:1}
.hig-violation-item .v-text strong{font-weight:700}
.hig-ok{
  padding:10px 14px;border-radius:10px;
  background:rgba(52,199,89,0.08);border:1px solid rgba(52,199,89,0.2);
  font-size:12px;color:#34C759;text-align:center;font-weight:600;
}
@keyframes violationFadeIn{
  from{opacity:0;transform:translateY(-4px)}
  to{opacity:1;transform:translateY(0)}
}
.hig-live-badge{
  display:inline-flex;align-items:center;gap:4px;
  font-size:10px;font-weight:700;color:#FF3B30;
  text-transform:uppercase;letter-spacing:0.5px;
}
.hig-live-badge .dot{
  width:6px;height:6px;border-radius:50%;background:#FF3B30;
  animation:livePulse 1.5s infinite;
}
.hig-live-badge.ok .dot{background:#34C759;animation:none}
.hig-live-badge.ok{color:#34C759}
@keyframes livePulse{
  0%,100%{opacity:1}50%{opacity:0.3}
}`;

// Per-component violation rules
// Each rule: { condition: "JS expression using state", ko: "Korean warning", en: "English warning" }
const violationRules = {
  'buttons.html': [
    { cond: "state.destructive && state.style !== 'filled'", ko: "Destructive 액션은 Filled 스타일로 명확하게 표시하세요", en: "Use Filled style to clearly indicate destructive actions" },
    { cond: "state.disabled && state.destructive", ko: "비활성화된 destructive 버튼은 사용자를 혼란스럽게 합니다", en: "Disabled destructive buttons confuse users" },
    { cond: "state.size === 'small' && state.style === 'filled'", ko: "Small Filled 버튼은 탭하기 어렵습니다. Regular 이상을 권장합니다", en: "Small Filled buttons are hard to tap. Use Regular or larger" },
  ],
  'charts.html': [], // no state found
  'image-views.html': [
    { cond: "state.contentMode === 'fill' && state.clipShape === 'none'", ko: "Fill 모드에서 clipShape 없이 사용하면 이미지가 잘릴 수 있습니다", en: "Using Fill mode without clipShape may crop the image unexpectedly" },
    { cond: "state.showOverlay && state.overlayColor !== 'none' && state.showShadow", ko: "오버레이와 그림자를 동시에 쓰면 시각적으로 복잡해집니다", en: "Using overlay and shadow together creates visual noise" },
  ],
  'text-views.html': [
    { cond: "state.lineLimit !== 'none' && parseInt(state.lineLimit) === 1 && state.fontStyle === 'body'", ko: "Body 텍스트를 1줄로 제한하면 내용이 잘립니다", en: "Limiting body text to 1 line truncates content" },
    { cond: "state.weight === 'black' && state.fontStyle === 'body'", ko: "Body 텍스트에 Black 웨이트는 가독성을 떨어뜨립니다", en: "Black weight on body text reduces readability" },
    { cond: "state.textColor === '#C7C7CC' || state.textColor === '#D1D1D6'", ko: "텍스트 색상의 대비가 너무 낮습니다 (WCAG 미달)", en: "Text color contrast is too low (fails WCAG)" },
  ],
  'web-views.html': [
    { cond: "!state.showProgress", ko: "로딩 인디케이터 없이 웹뷰를 표시하면 사용자가 상태를 알 수 없습니다", en: "Showing web view without loading indicator leaves users guessing" },
    { cond: "!state.showNavBar", ko: "네비게이션 바 없이 웹뷰를 표시하면 뒤로 갈 수 없습니다", en: "Web view without nav bar prevents navigation back" },
  ],
  'collections.html': [
    { cond: "state.columns >= 4", ko: "4열 이상이면 항목이 너무 작아 탭하기 어렵습니다 (44pt 미만)", en: "4+ columns make items too small to tap (below 44pt minimum)" },
    { cond: "state.spacing < 4", ko: "간격이 너무 좁으면 잘못된 항목을 탭할 수 있습니다", en: "Spacing too narrow increases accidental taps" },
    { cond: "!state.showLabels && state.columns >= 3", ko: "라벨 없이 3열 이상이면 항목 구분이 어렵습니다", en: "3+ columns without labels makes items hard to distinguish" },
  ],
  'disclosure-groups.html': [], // no clear state
  'labels.html': [
    { cond: "state.labelStyle === 'iconOnly' && state.size === 'small'", ko: "작은 크기의 아이콘만 표시하면 의미를 파악하기 어렵습니다", en: "Small icon-only labels are hard to understand" },
    { cond: "state.labelStyle === 'iconOnly'", ko: "아이콘만 사용하면 의미가 모호할 수 있습니다. 텍스트를 함께 표시하세요", en: "Icon-only labels can be ambiguous. Include text for clarity" },
  ],
  'outline-views.html': [], // no clear state
  'split-views.html': [
    { cond: "state.sidebarWidth === 'wide'", ko: "Wide 사이드바는 detail 영역을 좁게 만듭니다. iPad에서만 권장합니다", en: "Wide sidebar narrows the detail area. Recommended for iPad only" },
  ],
  'tables.html': [], // no clear state
  'lists.html': [
    { cond: "!state.showHeaders && !state.showIcons", ko: "섹션 헤더와 아이콘 없이 리스트를 표시하면 항목 구분이 어렵습니다", en: "List without section headers and icons makes items hard to distinguish" },
    { cond: "!state.showChevrons && state.style === 'insetGrouped'", ko: "Inset Grouped 스타일에서 chevron 없으면 탭 가능한지 알 수 없습니다", en: "Without chevrons in Inset Grouped style, users can't tell items are tappable" },
  ],
  'navigation-bars.html': [
    { cond: "state.trailing === 'multiple'", ko: "trailing 버튼이 너무 많으면 네비게이션 바가 복잡해집니다 (최대 2개 권장)", en: "Too many trailing buttons clutter the navigation bar (max 2 recommended)" },
    { cond: "state.titleStyle === 'large' && state.search", ko: "Large 타이틀 + 검색 바는 스크린 공간을 많이 차지합니다", en: "Large title + search bar takes up significant screen space" },
  ],
  'tab-bars.html': [], // state structure different
  'scroll-views.html': [], // no clear state
  'action-sheets.html': [
    { cond: "state.actionCount >= 4", ko: "4개 이상의 액션은 사용자를 압도합니다. 중요한 것만 남기세요", en: "4+ actions overwhelm users. Keep only the essential ones" },
    { cond: "state.hasDestructive && !state.showTitle", ko: "Destructive 액션이 있을 때는 타이틀로 맥락을 설명하세요", en: "Include a title for context when destructive actions are present" },
  ],
  'alerts.html': [
    { cond: "state.buttonCount >= 3", ko: "3개 이상의 버튼은 사용자를 혼란스럽게 합니다. Action Sheet를 고려하세요", en: "3+ buttons confuse users. Consider using an Action Sheet instead" },
    { cond: "state.hasDestructive && state.buttonCount === 1", ko: "Destructive 단독 버튼은 위험합니다. Cancel 버튼을 추가하세요", en: "Destructive-only button is dangerous. Add a Cancel button" },
  ],
  'sheets.html': [
    { cond: "!state.showDragIndicator", ko: "Drag indicator 없이 sheet를 표시하면 닫는 방법을 알 수 없습니다", en: "Sheet without drag indicator doesn't show how to dismiss" },
    { cond: "!state.showDismissBtn && !state.showDragIndicator", ko: "닫기 버튼도 drag indicator도 없으면 sheet를 닫을 수 없습니다", en: "Without dismiss button or drag indicator, sheet cannot be closed" },
  ],
  'context-menus.html': [
    { cond: "state.itemCount >= 6", ko: "6개 이상의 메뉴 항목은 과합니다. 그룹핑하거나 줄이세요", en: "6+ menu items is excessive. Group or reduce them" },
    { cond: "!state.showDividers && state.itemCount >= 4", ko: "4개 이상의 항목에는 divider로 그룹을 나누세요", en: "Use dividers to group 4+ items" },
  ],
  'text-fields.html': [
    { cond: "state.showSecure && state.showClear", ko: "Secure 필드에 clear 버튼은 보안상 위험할 수 있습니다", en: "Clear button on secure field can be a security concern" },
  ],
  'date-pickers.html': [
    { cond: "state.style === 'wheel' && state.component === 'dateOnly'", ko: "날짜만 선택할 때 Wheel은 과합니다. Compact를 권장합니다", en: "Wheel is overkill for date-only selection. Use Compact instead" },
  ],
  'pickers.html': [
    { cond: "state.itemCount >= 8 && state.style === 'wheel'", ko: "8개 이상 항목의 Wheel 피커는 스크롤이 많아집니다", en: "Wheel picker with 8+ items requires excessive scrolling" },
    { cond: "state.itemCount <= 3 && state.style === 'wheel'", ko: "3개 이하 항목에는 Segmented Control이 더 적합합니다", en: "For 3 or fewer items, Segmented Control is more appropriate" },
  ],
  'steppers.html': [
    { cond: "state.step > (state.max - state.min) / 3", ko: "Step이 너무 크면 세밀한 조절이 불가능합니다", en: "Step too large prevents fine-grained control" },
    { cond: "state.max - state.min > 50", ko: "넓은 범위에는 Slider가 더 적합합니다", en: "For wide ranges, Slider is more appropriate" },
  ],
  'sliders.html': [], // no clear state found
  'segmented-controls.html': [], // no state found
  'progress-indicators.html': [], // no state found
  'toggles.html': [], // no state found
  'color-wells.html': [
    { cond: "state.supportsOpacity && state.opacity < 0.3", ko: "투명도가 너무 낮으면 선택한 색상을 확인하기 어렵습니다", en: "Very low opacity makes the selected color hard to see" },
  ],
  'activity-rings.html': [
    { cond: "state.ringCount >= 5", ko: "5개 이상의 링은 구분하기 어렵습니다 (Apple은 최대 3개)", en: "5+ rings are hard to distinguish (Apple uses max 3)" },
  ],
  'gauges.html': [
    { cond: "!state.showLabel", ko: "라벨 없는 게이지는 값의 의미를 알 수 없습니다", en: "Gauge without label doesn't convey what the value means" },
  ],
  'activity-views.html': [
    { cond: "!state.showAppIcons && !state.showActions", ko: "앱 아이콘과 액션 모두 숨기면 공유 시트가 비어 보입니다", en: "Hiding both app icons and actions makes the share sheet appear empty" },
  ],
  'edit-menus.html': [
    { cond: "state.customActions && !state.showCut && !state.showCopy && !state.showPaste", ko: "기본 편집 액션(Cut/Copy/Paste) 없이 커스텀만 표시하면 혼란스럽습니다", en: "Showing only custom actions without Cut/Copy/Paste is confusing" },
  ],
  'menus.html': [
    { cond: "state.itemCount >= 5 && !state.showDividers", ko: "5개 이상의 메뉴 항목에는 divider로 그룹을 나누세요", en: "Use dividers to group 5+ menu items" },
    { cond: "!state.showIcons && state.itemCount >= 4", ko: "4개 이상의 항목에는 아이콘으로 빠른 인지를 돕습니다", en: "Icons help quick recognition for 4+ items" },
  ],
  'pop-up-buttons.html': [
    { cond: "!state.selectionIndicator", ko: "선택 인디케이터 없으면 현재 선택된 값을 알 수 없습니다", en: "Without selection indicator, current value is not visible" },
    { cond: "state.itemCount >= 6", ko: "6개 이상의 항목은 Pop-Up보다 Picker를 권장합니다", en: "For 6+ items, Picker is recommended over Pop-Up Button" },
  ],
  'pull-down-buttons.html': [
    { cond: "state.itemCount >= 5 && !state.showDividers", ko: "5개 이상의 항목에는 divider로 그룹을 나누세요", en: "Use dividers to group 5+ items" },
  ],
  'toolbars.html': [
    { cond: "state.itemCount >= 6", ko: "6개 이상의 툴바 아이템은 과합니다. 핵심만 남기세요", en: "6+ toolbar items is excessive. Keep only essential ones" },
    { cond: "state.style === 'text' && state.itemCount >= 4", ko: "텍스트 전용 4개 이상이면 공간이 부족합니다. 아이콘을 사용하세요", en: "4+ text-only items run out of space. Use icons instead" },
  ],
  'search-fields.html': [
    { cond: "state.scopeBar && !state.suggestions", ko: "Scope Bar를 쓰면 검색 제안도 함께 제공하는 것이 좋습니다", en: "When using Scope Bar, providing search suggestions is recommended" },
  ],
  'sidebars.html': [
    { cond: "!state.showIcons", ko: "아이콘 없는 사이드바는 항목을 빠르게 구분하기 어렵습니다", en: "Sidebar without icons makes items hard to quickly distinguish" },
    { cond: "state.sections >= 4 && !state.showBadges", ko: "4개 이상의 섹션에서는 배지로 알림 상태를 표시하세요", en: "With 4+ sections, use badges to indicate notification status" },
  ],
  'page-controls.html': [
    { cond: "state.pageCount >= 8", ko: "8개 이상의 페이지는 dots로 표현하기 어렵습니다. 다른 네비게이션을 고려하세요", en: "8+ pages are hard to represent with dots. Consider alternative navigation" },
  ],
  'popovers.html': [
    { cond: "!state.dismissOnTap", ko: "외부 탭으로 닫히지 않으면 사용자가 갇힌 느낌을 받습니다", en: "Not dismissing on outside tap makes users feel trapped" },
    { cond: "state.size === 'large'", ko: "Large 팝오버는 화면을 너무 많이 가립니다. Sheet를 고려하세요", en: "Large popovers cover too much screen. Consider using a Sheet" },
  ],
};

let totalUpdated = 0;

for (const [file, rules] of Object.entries(violationRules)) {
  if (rules.length === 0) continue;
  
  const filePath = path.join(componentsDir, file);
  if (!fs.existsSync(filePath)) { console.log(`SKIP (missing): ${file}`); continue; }
  
  let html = fs.readFileSync(filePath, 'utf-8');
  
  // Skip if already has violation system
  if (html.includes('hig-violations')) { console.log(`SKIP (exists): ${file}`); continue; }
  
  // 1. Inject CSS
  html = html.replace('</style>', violationCSS + '\n</style>');
  
  // 2. Add violations container after controls-panel
  const violationsHTML = `
    <!-- Realtime HIG Violations -->
    <div class="controls-panel" id="violationPanel" style="display:none">
      <div class="controls-header"><span class="hig-live-badge" id="violationBadge"><span class="dot"></span> LIVE HIG CHECK</span></div>
      <div class="controls-body">
        <div class="hig-violations" id="violationList"></div>
      </div>
    </div>`;
  
  // Insert after last controls-panel closing div, before code-preview or guidelines
  // Try to insert before code-preview
  if (html.includes('class="code-preview"')) {
    html = html.replace(/(<div class="code-preview")/, violationsHTML + '\n    $1');
  } else if (html.includes('class="guidelines"')) {
    // If no code preview, insert before guidelines
    html = html.replace(/(<div class="guidelines")/, violationsHTML + '\n    $1');
  }
  
  // 3. Build violation check JS
  const rulesJS = rules.map((r, i) => 
    `    { check: function(){ return ${r.cond}; }, ko: "${r.ko.replace(/"/g, '\\"')}", en: "${r.en.replace(/"/g, '\\"')}" }`
  ).join(',\n');
  
  const violationJS = `
// ─── Realtime HIG Violation Detection ───
const higRules = [
${rulesJS}
];

function checkHigViolations() {
  if (typeof state === 'undefined' || isDontMode) return;
  const panel = document.getElementById('violationPanel');
  const list = document.getElementById('violationList');
  const badge = document.getElementById('violationBadge');
  if (!panel || !list) return;
  
  const violations = [];
  for (const rule of higRules) {
    try { if (rule.check()) violations.push(rule); } catch(e) {}
  }
  
  if (violations.length > 0) {
    panel.style.display = '';
    badge.className = 'hig-live-badge';
    badge.innerHTML = '<span class="dot"></span> ' + violations.length + ' HIG VIOLATION' + (violations.length > 1 ? 'S' : '');
    list.innerHTML = violations.map(function(v) {
      return '<div class="hig-violation-item"><span class="v-icon">⚠️</span><span class="v-text">' + v.ko + '</span></div>';
    }).join('');
    // Also show iPhone warning
    var w = document.getElementById('higWarning');
    if (w) { w.textContent = '⚠️ ' + violations[0].ko; w.classList.add('show'); }
  } else {
    panel.style.display = '';
    badge.className = 'hig-live-badge ok';
    badge.innerHTML = '<span class="dot"></span> HIG OK';
    list.innerHTML = '<div class="hig-ok">✅ HIG 가이드라인을 준수하고 있습니다</div>';
    var w = document.getElementById('higWarning');
    if (w) w.classList.remove('show');
  }
}

// Hook into updatePreview
var _origUpdatePreview = typeof updatePreview === 'function' ? updatePreview : null;
if (_origUpdatePreview) {
  updatePreview = function() {
    _origUpdatePreview();
    checkHigViolations();
  };
}

// Also check on any control click
document.querySelectorAll('.control-option, .toggle-switch, .color-swatch').forEach(function(el) {
  el.addEventListener('click', function() { setTimeout(checkHigViolations, 50); });
});

// Initial check
setTimeout(checkHigViolations, 100);`;

  html = html.replace('</script>', violationJS + '\n</script>');
  
  fs.writeFileSync(filePath, html);
  totalUpdated++;
  console.log(`UPDATED: ${file} (${rules.length} rules)`);
}

console.log(`\nDone: ${totalUpdated} files updated with realtime violation detection`);

// ─── Now create EN versions with translated violations ───
console.log('\n--- Generating EN versions ---');

for (const [file, rules] of Object.entries(violationRules)) {
  if (rules.length === 0) continue;
  
  const koPath = path.join(componentsDir, file);
  const enFile = file.replace('.html', '.en.html');
  const enPath = path.join(componentsDir, enFile);
  
  if (!fs.existsSync(koPath)) continue;
  
  let html = fs.readFileSync(koPath, 'utf-8');
  
  // Translate violation-related text
  html = html.replace(/LIVE HIG CHECK/g, 'LIVE HIG CHECK');
  html = html.replace(/HIG 가이드라인을 준수하고 있습니다/g, 'Following HIG guidelines correctly');
  html = html.replace('HIG VIOLATION', 'HIG VIOLATION');
  
  // Replace Korean messages with English in the JS
  for (const rule of rules) {
    html = html.replace(
      `ko: "${rule.ko.replace(/"/g, '\\"')}"`,
      `ko: "${rule.en.replace(/"/g, '\\"')}"`
    );
    // Also in inline warning
    html = html.replace(`'⚠️ ' + violations[0].ko`, `'⚠️ ' + violations[0].ko`);
  }
  
  // Apply the same general KO→EN translations
  html = html.replace('<html lang="ko">', '<html lang="en">');
  
  // Swap lang toggle
  if (html.includes(`href="${enFile}"`)) {
    html = html.replace(new RegExp(`href="${enFile.replace('.', '\\.')}"[^>]*>🇺🇸 EN</a>`), `href="${file}" class="lang-toggle" style="font-size:12px;font-weight:600;color:#0071e3;text-decoration:none;padding:4px 10px;border:1.5px solid #0071e3;border-radius:12px;margin-left:8px;">🇰🇷 KO</a>`);
  }

  // Write EN file (overwrite previous EN version)
  fs.writeFileSync(enPath, html);
  console.log(`EN: ${enFile}`);
}

console.log('\nAll done!');
