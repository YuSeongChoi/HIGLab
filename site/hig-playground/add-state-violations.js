#!/usr/bin/env node
const fs = require('fs');
const path = require('path');

const componentsDir = path.join(__dirname, 'components');

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

const violationsHTML = `
    <!-- Realtime HIG Violations -->
    <div class="controls-panel" id="violationPanel" style="display:none">
      <div class="controls-header"><span class="hig-live-badge" id="violationBadge"><span class="dot"></span> LIVE HIG CHECK</span></div>
      <div class="controls-body">
        <div class="hig-violations" id="violationList"></div>
      </div>
    </div>`;

// For files that already have state (charts, tab-bars) — just add violations
// For files without state — add state extraction + violations

const configs = {
  'charts.html': {
    needsState: false,
    rules: [
      { cond: "state.chartType === 'pie' && state.dataPoints > 5", ko: "Pie 차트는 5개 이하 항목에 적합합니다. 많은 항목에는 Bar를 사용하세요", en: "Pie charts work best with 5 or fewer items. Use Bar for more" },
      { cond: "state.dataPoints >= 9", ko: "데이터 포인트가 너무 많으면 차트가 복잡해집니다", en: "Too many data points make the chart cluttered" },
      { cond: "!state.showGrid && state.chartType !== 'pie'", ko: "Grid 없이 Bar/Line 차트를 표시하면 값 비교가 어렵습니다", en: "Bar/Line charts without grid make value comparison difficult" },
      { cond: "!state.showLegend && state.dataPoints >= 5", ko: "5개 이상의 데이터에는 범례(Legend)를 표시하세요", en: "Show legend for 5+ data points" },
    ]
  },
  'tab-bars.html': {
    needsState: false,
    rules: [
      { cond: "state.tabCount >= 5", ko: "5개 이상의 탭은 라벨이 좁아져 읽기 어렵습니다", en: "5+ tabs make labels narrow and hard to read" },
      { cond: "state.showBadge && state.badgeCount > 99", ko: "배지 숫자가 99를 초과하면 '99+'로 표시하는 것이 좋습니다", en: "Badge numbers above 99 should display as '99+'" },
    ]
  },
  'segmented-controls.html': {
    needsState: true,
    stateInit: "var state = { segCount: segCount || 3, segStyle: segStyle || 'text' };",
    stateSync: "state.segCount = segCount; state.segStyle = segStyle;",
    rules: [
      { cond: "state.segCount >= 5", ko: "5개 이상의 세그먼트는 라벨이 잘립니다. 다른 UI를 고려하세요", en: "5+ segments cause label truncation. Consider alternative UI" },
      { cond: "state.segCount === 2 && state.segStyle === 'icon'", ko: "2개 아이콘만 있으면 Toggle이 더 적합할 수 있습니다", en: "With only 2 icons, a Toggle might be more appropriate" },
    ]
  },
  'toggles.html': {
    needsState: true,
    stateInit: "var state = { tintColor: tintColor || '#34C759', toggleCount: document.querySelectorAll('.ios-toggle').length };",
    stateSync: "state.tintColor = tintColor; state.toggleCount = document.querySelectorAll('.ios-toggle.on').length;",
    rules: [
      { cond: "state.tintColor === '#FF3B30'", ko: "빨간색 토글은 '위험' 의미로 오해될 수 있습니다. 초록색을 권장합니다", en: "Red toggle tint can be confused with 'danger'. Green is recommended" },
    ]
  },
  'sliders.html': {
    needsState: true,
    stateInit: "var state = { tintColor: tintColor || '#007AFF', showLabels: true };",
    stateSync: "state.tintColor = tintColor;",
    rules: [
      { cond: "state.tintColor === '#FF3B30'", ko: "빨간색 슬라이더는 경고 의미로 오해될 수 있습니다", en: "Red slider tint can be misinterpreted as a warning" },
    ]
  },
  'progress-indicators.html': {
    needsState: true,
    stateInit: "var state = { tintColor: tintColor || '#007AFF', progress: progress || 65, style: 'linear' };",
    stateSync: "state.tintColor = tintColor; state.progress = progress;",
    rules: [
      { cond: "state.progress === 0", ko: "진행률 0%는 시작 전인지 오류인지 구분이 안 됩니다. 로딩 인디케이터를 사용하세요", en: "0% progress is ambiguous — use a loading indicator for indeterminate state" },
    ]
  },
  'scroll-views.html': {
    needsState: true,
    stateInit: "var state = { direction: 'vertical', paging: false, showIndicators: true };",
    stateSync: "if(document.querySelector('.control-option.active[data-value=\"horizontal\"]')) state.direction='horizontal'; else state.direction='vertical'; state.paging = !!document.querySelector('#togglePaging.on'); state.showIndicators = !document.querySelector('#toggleIndicators.on');",
    rules: [
      { cond: "!state.showIndicators", ko: "스크롤 인디케이터 없이는 더 많은 콘텐츠가 있는지 알 수 없습니다", en: "Without scroll indicators, users can't tell there's more content" },
      { cond: "state.paging && state.direction === 'vertical'", ko: "Vertical 페이징은 일반적이지 않습니다. Horizontal 페이징이 더 자연스럽습니다", en: "Vertical paging is uncommon. Horizontal paging feels more natural" },
    ]
  },
  'disclosure-groups.html': {
    needsState: true,
    stateInit: "var state = { nestLevel: 2, defaultExpanded: true };",
    stateSync: "var expandedCount = document.querySelectorAll('.disc-content[style*=\"display: block\"], .disc-content[style*=\"display:block\"]').length; state.nestLevel = Math.max(1, expandedCount);",
    rules: [
      { cond: "state.nestLevel >= 3", ko: "3단계 이상 중첩은 사용자가 현재 위치를 파악하기 어렵습니다", en: "3+ nesting levels make it hard for users to track their position" },
    ]
  },
  'outline-views.html': {
    needsState: true,
    stateInit: "var state = { expandedNodes: 2 };",
    stateSync: "state.expandedNodes = document.querySelectorAll('.outline-row.expanded').length || 0;",
    rules: [
      { cond: "state.expandedNodes >= 5", ko: "너무 많은 노드가 펼쳐져 있으면 전체 구조 파악이 어렵습니다", en: "Too many expanded nodes make it hard to see the overall structure" },
    ]
  },
  'tables.html': {
    needsState: true,
    stateInit: "var state = { columns: 4, rows: 5, showSort: true };",
    stateSync: "var headers = document.querySelectorAll('th, .table-header-cell'); state.columns = headers.length || 4;",
    rules: [
      { cond: "state.columns >= 5", ko: "5개 이상의 컬럼은 모바일에서 읽기 어렵습니다. 핵심 데이터만 표시하세요", en: "5+ columns are hard to read on mobile. Show only essential data" },
    ]
  },
};

function buildViolationJS(config) {
  const rulesJS = config.rules.map(r =>
    `    { check: function(){ return ${r.cond}; }, ko: "${r.ko.replace(/"/g, '\\"')}", en: "${r.en.replace(/"/g, '\\"')}" }`
  ).join(',\n');

  let js = '\n// ─── Realtime HIG Violation Detection ───\n';
  
  if (config.needsState) {
    js += config.stateInit + '\n';
  }
  
  js += `
var higRules = [
${rulesJS}
];

function checkHigViolations() {
  if (typeof isDontMode !== 'undefined' && isDontMode) return;
  ${config.needsState && config.stateSync ? config.stateSync : ''}
  var panel = document.getElementById('violationPanel');
  var list = document.getElementById('violationList');
  var badge = document.getElementById('violationBadge');
  if (!panel || !list) return;
  
  var violations = [];
  for (var i = 0; i < higRules.length; i++) {
    try { if (higRules[i].check()) violations.push(higRules[i]); } catch(e) {}
  }
  
  if (violations.length > 0) {
    panel.style.display = '';
    badge.className = 'hig-live-badge';
    badge.innerHTML = '<span class="dot"></span> ' + violations.length + ' HIG VIOLATION' + (violations.length > 1 ? 'S' : '');
    list.innerHTML = violations.map(function(v) {
      return '<div class="hig-violation-item"><span class="v-icon">⚠️</span><span class="v-text">' + v.ko + '</span></div>';
    }).join('');
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

// Hook into existing updatePreview if exists
var _origUp = typeof updatePreview === 'function' ? updatePreview : null;
if (_origUp) {
  updatePreview = function() { _origUp(); checkHigViolations(); };
}

// Listen on all controls
document.querySelectorAll('.control-option, .toggle-switch, .color-swatch, input[type=range]').forEach(function(el) {
  el.addEventListener('click', function() { setTimeout(checkHigViolations, 100); });
  el.addEventListener('input', function() { setTimeout(checkHigViolations, 100); });
});

setTimeout(checkHigViolations, 200);`;

  return js;
}

let updated = 0;

for (const [file, config] of Object.entries(configs)) {
  const filePath = path.join(componentsDir, file);
  if (!fs.existsSync(filePath)) { console.log(`SKIP: ${file}`); continue; }
  
  let html = fs.readFileSync(filePath, 'utf-8');
  
  if (html.includes('hig-violations')) { console.log(`SKIP (exists): ${file}`); continue; }
  
  // 1. CSS
  html = html.replace('</style>', violationCSS + '\n</style>');
  
  // 2. Violations panel HTML
  if (html.includes('class="code-preview"')) {
    html = html.replace(/(<div class="code-preview")/, violationsHTML + '\n    $1');
  } else if (html.includes('class="guidelines"')) {
    html = html.replace(/(<div class="guidelines")/, violationsHTML + '\n    $1');
  }
  
  // 3. JS
  html = html.replace('</script>', buildViolationJS(config) + '\n</script>');
  
  fs.writeFileSync(filePath, html);
  updated++;
  console.log(`UPDATED: ${file} (${config.rules.length} rules)`);
}

console.log(`\nDone: ${updated} files updated`);
