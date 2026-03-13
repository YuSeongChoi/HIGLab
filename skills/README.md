# HIG Lab Skills / HIG Lab 스킬

Ready-to-use AI configuration files for Apple framework development.  
Apple 프레임워크 개발을 위한 AI 설정 파일 모음입니다.

## 📁 What's Inside / 포함 내용

| Directory | Tool | Description |
|-----------|------|-------------|
| `claude-code/` | [Claude Code](https://docs.anthropic.com/en/docs/claude-code) | `/hig` slash command — fetch AI Reference on demand |
| `cursor/` | [Cursor](https://cursor.sh) | `.cursorrules` — automatic AI Reference awareness |
| `copilot/` | [GitHub Copilot](https://github.com/features/copilot) | `copilot-instructions.md` — framework-aware code generation |

---

## 🚀 Installation / 설치 방법

### Claude Code

Copy the command file to your global commands directory:

```bash
# Global (available in all projects)
cp claude-code/hig.md ~/.claude/commands/hig.md

# Or project-local
cp claude-code/hig.md .claude/commands/hig.md
```

Then use `/hig storekit` or `/hig 인앱결제` in Claude Code.

**Or install via npm:**
```bash
npm install -g higlab-skill
```

### Cursor

Copy `.cursorrules` to your project root:

```bash
cp cursor/.cursorrules /path/to/your/project/.cursorrules
```

### GitHub Copilot

Copy to your project's `.github/` directory:

```bash
mkdir -p /path/to/your/project/.github
cp copilot/copilot-instructions.md /path/to/your/project/.github/copilot-instructions.md
```

---

## 🇰🇷 한국어 안내

### Claude Code

커맨드 파일을 복사하세요:

```bash
# 전역 설치 (모든 프로젝트에서 사용)
cp claude-code/hig.md ~/.claude/commands/hig.md

# 또는 프로젝트 로컬
cp claude-code/hig.md .claude/commands/hig.md
```

Claude Code에서 `/hig storekit` 또는 `/hig 인앱결제`로 사용합니다.

**npm으로 설치:**
```bash
npm install -g higlab-skill
```

### Cursor

`.cursorrules` 파일을 프로젝트 루트에 복사하세요:

```bash
cp cursor/.cursorrules /path/to/your/project/.cursorrules
```

### GitHub Copilot

`.github/` 디렉토리에 복사하세요:

```bash
mkdir -p /path/to/your/project/.github
cp copilot/copilot-instructions.md /path/to/your/project/.github/copilot-instructions.md
```

---

## 🔗 Links

- [HIG Lab](https://m1zz.github.io/HIGLab/) — Browse all 50 AI References
- [GitHub](https://github.com/YuSeongChoi/HIGLab)
- [npm package](https://www.npmjs.com/package/higlab-skill)
