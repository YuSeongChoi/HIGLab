/**
 * HIG Lab — Floating Sponsor Button
 * Korean: KakaoPay QR popup
 * English: GitHub Sponsors popup
 */
(function () {
  if (document.getElementById('hig-sponsor-fab')) return;

  var isEn = (function () {
    var lang = (document.documentElement.lang || '').toLowerCase();
    var path = window.location.pathname;
    return lang.startsWith('en') || path.indexOf('/en/') !== -1 || path.indexOf('.en.html') !== -1;
  })();

  function qrPath() {
    var depth = (window.location.pathname.match(/\//g) || []).length;
    if (depth <= 2) return 'kakaopay-qr.jpg';
    if (depth === 3) return '../kakaopay-qr.jpg';
    return '../../kakaopay-qr.jpg';
  }

  var style = document.createElement('style');
  style.textContent =
    '.sp-overlay{display:none;position:fixed;inset:0;z-index:9998;background:rgba(0,0,0,.25)}' +
    '.sp-overlay.open{display:block}' +
    '.sp-fab{position:fixed;bottom:28px;right:28px;z-index:9999;display:flex;flex-direction:column;align-items:flex-end;gap:10px}' +
    '.sp-btn{width:48px;height:48px;border-radius:50%;background:#FFEB00;border:none;cursor:pointer;box-shadow:0 4px 16px rgba(0,0,0,.15);display:flex;align-items:center;justify-content:center;font-size:22px;transition:transform .2s,box-shadow .2s;text-decoration:none;color:inherit}' +
    '.sp-btn:hover{transform:scale(1.08);box-shadow:0 6px 24px rgba(0,0,0,.22)}' +
    '.sp-popup{display:none;background:#fff;border-radius:16px;box-shadow:0 12px 48px rgba(0,0,0,.18);padding:20px;text-align:center;width:240px;position:relative}' +
    '.sp-popup.open{display:block;animation:spIn .2s ease}' +
    '@keyframes spIn{from{opacity:0;transform:translateY(8px)}to{opacity:1;transform:translateY(0)}}' +
    '.sp-popup-title{font-size:14px;font-weight:700;color:#1d1d1f;margin-bottom:12px}' +
    '.sp-popup-qr img{width:160px;height:160px;border-radius:10px;object-fit:cover}' +
    '.sp-popup-label{font-size:11px;color:#999;margin-top:6px}' +
    '.sp-popup-close{position:absolute;top:8px;right:12px;background:none;border:none;font-size:18px;color:#999;cursor:pointer;padding:4px}' +
    '.sp-popup-link{display:inline-block;margin-top:14px;padding:10px 24px;background:#24292f;color:#fff;border-radius:10px;text-decoration:none;font-size:13px;font-weight:600;transition:background .2s}' +
    '.sp-popup-link:hover{background:#1a1e22}' +
    '@media(max-width:480px){.sp-popup{width:220px;padding:16px}.sp-popup-qr img{width:140px;height:140px}}';
  document.head.appendChild(style);

  var overlay = document.createElement('div');
  overlay.className = 'sp-overlay';
  overlay.onclick = close;

  var fab = document.createElement('div');
  fab.className = 'sp-fab';

  var popup = document.createElement('div');
  popup.className = 'sp-popup';

  if (isEn) {
    popup.innerHTML =
      '<button class="sp-popup-close">&times;</button>' +
      '<div class="sp-popup-title">Buy me a coffee ☕</div>' +
      '<div style="font-size:13px;color:#6e6e73;margin-bottom:14px;line-height:1.5">If HIG Lab helped you,<br>consider sponsoring on GitHub</div>' +
      '<a class="sp-popup-link" href="https://github.com/sponsors/M1zz" target="_blank" rel="noopener noreferrer">♥ Sponsor on GitHub</a>';
  } else {
    popup.innerHTML =
      '<button class="sp-popup-close">&times;</button>' +
      '<div class="sp-popup-title">커피 한 잔 사주기 ☕</div>' +
      '<div class="sp-popup-qr"><img src="' + qrPath() + '" alt="카카오페이 QR"></div>' +
      '<div class="sp-popup-label">카카오페이 · 이현호</div>';
  }

  popup.querySelector('.sp-popup-close').onclick = close;

  var btn = document.createElement('button');
  btn.id = 'hig-sponsor-fab';
  btn.className = 'sp-btn';
  btn.setAttribute('aria-label', isEn ? 'Sponsor' : '후원');
  btn.textContent = '☕';
  btn.onclick = toggle;

  fab.appendChild(popup);
  fab.appendChild(btn);

  function toggle() {
    popup.classList.toggle('open');
    overlay.classList.toggle('open');
  }
  function close() {
    popup.classList.remove('open');
    overlay.classList.remove('open');
  }

  function init() {
    document.body.appendChild(overlay);
    document.body.appendChild(fab);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
