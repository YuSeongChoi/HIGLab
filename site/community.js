/**
 * HIG Lab — 챕터 커뮤니티 위젯
 *
 * 포함: KakaoTalk 오픈채팅 배너 (QR 포함) + Giscus 댓글 + 카카오페이 후원 플로팅 버튼
 */

(function () {
  const KAKAO_URL = 'https://open.kakao.com/o/pjNluRji';
  const GISCUS_REPO = 'M1zz/HIGLab';
  const GISCUS_REPO_ID = 'R_kgDORQ1tLA';
  const GISCUS_CATEGORY = 'General';
  const GISCUS_CATEGORY_ID = 'DIC_kwDORQ1tLM4C3uw-';

  // QR 이미지 경로: 호출하는 HTML의 depth에 따라 자동 감지
  function getQRPath() {
    const depth = (window.location.pathname.match(/\//g) || []).length;
    // depth 2: site/index.html, depth 3: site/<fw>/xx.html, depth 4: site/en/<fw>/xx.html
    if (depth <= 2) return 'kakao-openchat-qr.jpg';
    if (depth === 3) return '../kakao-openchat-qr.jpg';
    return '../../kakao-openchat-qr.jpg';
  }

  function injectCSS() {
    if (document.getElementById('hig-community-css')) return;
    const s = document.createElement('style');
    s.id = 'hig-community-css';
    s.textContent = `
.hig-community {
  margin: 3rem auto 0;
  max-width: 860px;
  padding: 0 1.5rem 3rem;
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
}

/* ── 카카오 카드 ── */
.hig-kakao-card {
  display: flex;
  gap: 1.4rem;
  align-items: center;
  background: #FEE500;
  border-radius: 18px;
  padding: 1.2rem 1.6rem;
  margin-bottom: 2rem;
  text-decoration: none;
  color: #3C1E1E;
  transition: transform .2s, box-shadow .2s;
}
.hig-kakao-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 10px 32px rgba(254,229,0,.5);
  color: #3C1E1E;
}

.hig-kakao-body { flex: 1; }
.hig-kakao-body strong {
  display: block; font-size: 1rem; font-weight: 800; margin-bottom: 4px;
}
.hig-kakao-body p { font-size: .84rem; opacity: .72; margin: 0; line-height: 1.5; }
.hig-kakao-body .hig-kakao-tag {
  display: inline-block; margin-top: .6rem;
  background: rgba(0,0,0,.1); border-radius: 100px;
  padding: 3px 10px; font-size: .75rem; font-weight: 600;
}

.hig-qr-wrap {
  flex-shrink: 0;
  background: #fff;
  border-radius: 12px;
  padding: 8px;
  box-shadow: 0 2px 10px rgba(0,0,0,.12);
}
.hig-qr-wrap img {
  width: 90px; height: 90px;
  display: block; border-radius: 6px;
  object-fit: cover;
}
.hig-qr-label {
  text-align: center; font-size: .65rem; color: #888;
  margin-top: 4px; font-weight: 500;
}

@media (max-width: 480px) {
  .hig-qr-wrap { display: none; }
}

/* ── Giscus 제목 ── */
.hig-giscus-title {
  font-size: 1.05rem; font-weight: 700;
  color: #1d1d1f;
  margin-bottom: .4rem;
}
.hig-giscus-desc {
  font-size: .83rem;
  color: #6e6e73;
  margin-bottom: 1rem;
}

    `;
    document.head.appendChild(s);
  }

  function render() {
    const container = document.getElementById('community-widget');
    if (!container) return;

    injectCSS();
    const qr = getQRPath();

    container.innerHTML = `
      <div class="hig-community">

        <a class="hig-kakao-card" href="${KAKAO_URL}" target="_blank" rel="noopener noreferrer">
          <div class="hig-kakao-body">
            <strong>💬 HIG Lab 오픈 카톡방</strong>
            <p>막히는 부분 질문 · 학습 인증 · 정보 공유<br>같이 공부하는 사람들이 모여 있어요</p>
            <span class="hig-kakao-tag">참여하기 →</span>
          </div>
          <div class="hig-qr-wrap">
            <img src="${qr}" alt="오픈채팅 QR"/>
            <div class="hig-qr-label">카메라로 스캔</div>
          </div>
        </a>

        <p class="hig-giscus-title">📣 피드백 &amp; 댓글</p>
        <p class="hig-giscus-desc">이 챕터가 도움이 됐나요? GitHub 계정으로 댓글이나 반응을 남겨주세요.</p>

      </div>
    `;

    const script = document.createElement('script');
    script.src = 'https://giscus.app/client.js';
    script.setAttribute('data-repo', GISCUS_REPO);
    script.setAttribute('data-repo-id', GISCUS_REPO_ID);
    script.setAttribute('data-category', GISCUS_CATEGORY);
    script.setAttribute('data-category-id', GISCUS_CATEGORY_ID);
    script.setAttribute('data-mapping', 'pathname');
    script.setAttribute('data-strict', '0');
    script.setAttribute('data-reactions-enabled', '1');
    script.setAttribute('data-emit-metadata', '0');
    script.setAttribute('data-input-position', 'top');
    script.setAttribute('data-theme', 'light');
    script.setAttribute('data-lang', 'ko');
    script.crossOrigin = 'anonymous';
    script.async = true;
    container.querySelector('.hig-community').appendChild(script);

    injectSponsorFab();
  }


  function init() {
    render();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
