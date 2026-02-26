#!/usr/bin/env python3
import re

# Read the file
with open('/Users/leeo/Documents/workspace/code/HIGLab/site/en/index.html', 'r', encoding='utf-8') as f:
    content = f.read()

# Translation mappings
replacements = [
    ('lang="ko"', 'lang="en"'),
    ('Apple 핵심 50개 프레임워크를 블로그, DocC 튜토리얼, 샘플 프로젝트로 학습하세요.', 
     "Learn Apple's core 50 frameworks with blogs, DocC tutorials, and sample projects."),
    ('Apple Frameworks를<br>코드로 실습하는 곳', 'Practice Apple Frameworks<br>with Code'),
    ('Apple Frameworks를 코드로 실습하는 곳', 'Practice Apple Frameworks with Code'),
    ('🌱 시작하기', '🌱 Get Started'),
    ('🗺️ 로드맵', '🗺️ Roadmap'),
    ('개발자리', 'YouTube'),
    ('button onclick="toggleLang()" id="lang-toggle" style="background:var(--accent);color:#fff;border:none;padding:4px 12px;border-radius:12px;font-size:12px;font-weight:600;cursor:pointer;margin-left:8px;">🌐 EN</button>',
     'a href="../ko/" style="background:var(--accent);color:#fff;border:none;padding:4px 12px;border-radius:12px;font-size:12px;font-weight:600;cursor:pointer;margin-left:8px;text-decoration:none;">🇰🇷 KO</a>'),
    ('367개 Apple 프레임워크 중 핵심 50개를 실전 중심으로 학습합니다.', 
     "Learn 50 essential frameworks from Apple's 367+ frameworks through hands-on practice."),
    ('각 기술별로 블로그 + DocC 튜토리얼 + 샘플 프로젝트를 제공합니다.', 
     'Each topic includes a blog post, DocC tutorial, and sample project.'),
    ('🌱 주니어 개발자 시작 가이드', '🌱 Getting Started Guide'),
    ('📝 블로그', '📝 Blog'),
    ('💻 샘플', '💻 Sample'),
    ('🎉 50/50 기술 완전 커버! (43개 샘플 프로젝트)', '🎉 50/50 technologies covered! (43 sample projects)'),
    ('📝 100% · 📚 100% · 💻 100% (148,411줄)', '📝 100% · 📚 100% · 💻 100% (148,411 lines)'),
    ('✅ 완성', '✅ Done'),
    ('🚧 진행중', '🚧 In Progress'),
    ('📋 계획됨', '📋 Planned'),
    ('🆕 신규', '🆕 New'),
    ('href="#" class="logo"', 'href="./" class="logo"'),
    # Card descriptions
    ('홈화면/잠금화면 위젯. Glanceable, Relevant, Personalized 원칙.', 
     'Home/Lock screen widgets. Glanceable, Relevant, Personalized principles.'),
    ('배달 추적 앱 만들기.', 'Build a delivery tracking app.'),
    ('블로그', 'Blog'),
    # Footer
    ('Made with ❤️ by', 'Made with ❤️ by'),
]

for old, new in replacements:
    content = content.replace(old, new)

# Write back
with open('/Users/leeo/Documents/workspace/code/HIGLab/site/en/index.html', 'w', encoding='utf-8') as f:
    f.write(content)

print("Done! en/index.html translated.")
