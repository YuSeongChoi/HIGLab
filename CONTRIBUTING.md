# Contributing Guide

This repository follows a chapter-based learning workflow for `practice/HIGPractice`.

## Branch Strategy

- Keep `main` stable.
- Work in short-lived chapter branches.
- Branch naming:
  - `practice/p1-swiftui-ch01`
  - `practice/p2-cloudkit-ch03`

Start each new chapter branch from updated `main`:

```bash
scripts/start_chapter_branch.sh --phase p1 --framework swiftui --chapter day2
```

## Issue -> PR Cycle

1. Create chapter issue using `.github/ISSUE_TEMPLATE/chapter.yml`.
2. Implement only issue-scoped changes.
3. Push and open a PR.
4. Pass CI and review.
5. Merge (squash) and delete branch.
6. Write retrospective and update `practice/HIGPractice/LEARNING_LOG.md`.

## Commit Convention

Use Conventional Commits:

- `feat(scope): summary`
- `fix(scope): summary`
- `refactor(scope): summary`
- `docs(scope): summary`
- `test(scope): summary`
- `chore(scope): summary`

Examples:

- `feat(practice-home): add adaptive phase grid cards`
- `feat(chapter): complete swiftui chapter 1 exercises`

## Pull Request Convention

Use `.github/pull_request_template.md`.

PR title format:

- `type(scope): summary`

Examples:

- `feat(practice): finalize setup for learning workflow`
- `feat(chapter): phase 1 swiftui chapter 1 implementation`

## CI Policy

- Required: `Build HIGPractice (iOS 26)`
- Advisory: `SwiftLint (Advisory)`

## Local Validation

```bash
xcodebuild \
  -project practice/HIGPractice/HIGPractice.xcodeproj \
  -scheme HIGPractice \
  -destination 'generic/platform=iOS' \
  -derivedDataPath /tmp/HIGPracticeDerived \
  CODE_SIGNING_ALLOWED=NO build
```

## Labels and Branch Protection

Initialize labels:

```bash
.github/scripts/setup_labels.sh YuSeongChoi/HIGLab
```

Apply branch protection (repo admin required):

```bash
.github/scripts/protect_main_branch.sh YuSeongChoi/HIGLab
```

## Learning Log Automation

When a PR is merged, `Learning Log Reminder` workflow posts a table row template in the merged PR comments.

You can append one row with:

```bash
scripts/add_learning_log.sh \
  --date 2026-02-23 \
  --phase "Phase 1" \
  --framework "SwiftUI" \
  --chapter "Chapter 1" \
  --issue "#123" \
  --pr "#124" \
  --velog "https://velog.io/@..." \
  --key "State flow from @State to child views"
```
