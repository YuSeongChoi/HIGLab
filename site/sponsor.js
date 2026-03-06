/**
 * HIG Lab — 후원 플로팅 버튼
 * 한국어 페이지: 카카오페이 QR 모달
 * 영어 페이지:   GitHub Sponsors 링크
 */
(function () {
  if (document.getElementById('hig-sponsor-fab')) return;

  const KAKAOPAY_QR = 'https://m1zz.github.io/HIGLab/kakao-pay-qr.jpg';
  const GITHUB_SPONSORS_URL = 'https://github.com/sponsors/M1zz';

  function isEnglish() {
    const lang = (document.documentElement.lang || '').toLowerCase();
    const path = window.location.pathname;
    return lang.startsWith('en') || path.includes('/en/') || path.endsWith('.en.html');
  }

  function injectCSS() {
    if (document.getElementById('hig-sponsor-fab-css')) return;
    const s = document.createElement('style');
    s.id = 'hig-sponsor-fab-css';
    s.textContent = `
.hig-sponsor-fab {
  position: fixed;
  bottom: 28px;
  right: 28px;
  z-index: 9999;
  display: flex;
  align-items: center;
  gap: 8px;
  border: none;
  border-radius: 100px;
  padding: 12px 20px 12px 16px;
  font-size: .9rem;
  font-weight: 700;
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
  cursor: pointer;
  box-shadow: 0 6px 24px rgba(0,0,0,.22);
  transition: transform .2s, box-shadow .2s;
  text-decoration: none;
}
.hig-sponsor-fab:hover {
  transform: translateY(-3px);
  box-shadow: 0 12px 32px rgba(0,0,0,.28);
}
.hig-sponsor-fab.kakao {
  background: #3C1E1E;
  color: #FEE500;
}
.hig-sponsor-fab.github {
  background: #24292f;
  color: #fff;
}
.hig-sponsor-overlay {
  display: none;
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,.5);
  z-index: 10000;
  align-items: center;
  justify-content: center;
  backdrop-filter: blur(4px);
}
.hig-sponsor-overlay.open { display: flex; }
.hig-sponsor-modal {
  background: #fff;
  border-radius: 24px;
  padding: 32px 28px 28px;
  max-width: 320px;
  width: 90%;
  text-align: center;
  box-shadow: 0 24px 80px rgba(0,0,0,.18);
  position: relative;
  animation: hig-modal-in .25s ease;
}
@keyframes hig-modal-in {
  from { opacity: 0; transform: scale(.92) translateY(12px); }
  to   { opacity: 1; transform: scale(1)  translateY(0); }
}
.hig-sponsor-modal .hig-modal-close {
  position: absolute;
  top: 16px; right: 18px;
  background: none; border: none;
  font-size: 1.3rem; cursor: pointer;
  color: #999; line-height: 1;
}
.hig-sponsor-modal .hig-modal-title {
  font-size: 1.15rem; font-weight: 800;
  color: #1d1d1f; margin-bottom: 4px;
}
.hig-sponsor-modal .hig-modal-desc {
  font-size: .82rem; color: #6e6e73;
  margin-bottom: 20px; line-height: 1.6;
}
.hig-sponsor-modal .hig-modal-qr {
  width: 200px; height: 200px;
  border-radius: 16px;
  object-fit: cover;
  margin: 0 auto 12px;
  display: block;
  box-shadow: 0 4px 16px rgba(0,0,0,.1);
}
.hig-sponsor-modal .hig-modal-label {
  font-size: .78rem; color: #aaa; font-weight: 500;
}
    `;
    document.head.appendChild(s);
  }

  function injectKakao() {
    const fab = document.createElement('button');
    fab.id = 'hig-sponsor-fab';
    fab.className = 'hig-sponsor-fab kakao';
    fab.innerHTML = '<span style="font-size:1.2rem">☕</span> 후원하기';
    document.body.appendChild(fab);

    const overlay = document.createElement('div');
    overlay.id = 'hig-sponsor-overlay';
    overlay.className = 'hig-sponsor-overlay';
    overlay.innerHTML = `
      <div class="hig-sponsor-modal">
        <button class="hig-modal-close" id="hig-modal-close-btn">✕</button>
        <div class="hig-modal-title">☕ HIG Lab 후원하기</div>
        <div class="hig-modal-desc">카카오페이로 소액 후원하시면<br>콘텐츠 제작에 큰 힘이 됩니다 🙏</div>
        <img class="hig-modal-qr" src="${KAKAOPAY_QR}" alt="카카오페이 후원 QR"/>
        <div class="hig-modal-label">카메라로 QR 스캔 · 카카오페이</div>
      </div>
    `;
    document.body.appendChild(overlay);

    fab.addEventListener('click', () => overlay.classList.add('open'));
    document.getElementById('hig-modal-close-btn').addEventListener('click', () => overlay.classList.remove('open'));
    overlay.addEventListener('click', (e) => { if (e.target === overlay) overlay.classList.remove('open'); });
  }

  function injectGitHub() {
    const fab = document.createElement('a');
    fab.id = 'hig-sponsor-fab';
    fab.className = 'hig-sponsor-fab github';
    fab.href = GITHUB_SPONSORS_URL;
    fab.target = '_blank';
    fab.rel = 'noopener noreferrer';
    fab.innerHTML = `
      <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
        <path d="M8 .25a.75.75 0 0 1 .673.418l1.882 3.815 4.21.612a.75.75 0 0 1 .416 1.279l-3.046 2.97.719 4.192a.751.751 0 0 1-1.088.791L8 12.347l-3.766 1.98a.75.75 0 0 1-1.088-.79l.72-4.194L.818 6.374a.75.75 0 0 1 .416-1.28l4.21-.611L7.327.668A.75.75 0 0 1 8 .25Z"/>
      </svg>
      Sponsor`;
    document.body.appendChild(fab);
  }

  function inject() {
    injectCSS();
    if (isEnglish()) {
      injectGitHub();
    } else {
      injectKakao();
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', inject);
  } else {
    inject();
  }
})();
