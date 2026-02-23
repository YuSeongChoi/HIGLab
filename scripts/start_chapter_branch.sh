#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage:
  scripts/start_chapter_branch.sh \
    --phase p1 \
    --framework widgetkit \
    --unit setup

Examples:
  scripts/start_chapter_branch.sh --phase p1 --framework widgetkit --unit core
  scripts/start_chapter_branch.sh --phase p2 --framework cloudkit --unit sync
USAGE
}

PHASE=""
FRAMEWORK=""
UNIT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --phase) PHASE="$2"; shift 2 ;;
    --framework) FRAMEWORK="$2"; shift 2 ;;
    --unit) UNIT="$2"; shift 2 ;;
    --chapter) UNIT="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1"; usage; exit 1 ;;
  esac
done

for v in PHASE FRAMEWORK UNIT; do
  if [[ -z "${!v}" ]]; then
    echo "Missing required argument: ${v}"
    usage
    exit 1
  fi
done

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Working tree is not clean. Commit or stash changes first."
  exit 1
fi

normalize() {
  echo "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//; s/-+/-/g'
}

PHASE_NORM="$(normalize "$PHASE")"
FRAMEWORK_NORM="$(normalize "$FRAMEWORK")"
UNIT_NORM="$(normalize "$UNIT")"

BRANCH_NAME="practice/${PHASE_NORM}-${FRAMEWORK_NORM}-${UNIT_NORM}"

CURRENT_BRANCH="$(git branch --show-current)"
if [[ "$CURRENT_BRANCH" != "main" ]]; then
  git switch main
fi

git pull origin main

git switch -c "$BRANCH_NAME"

echo "Created branch: $BRANCH_NAME"
echo "Next steps:"
echo "  1) Create learning issue"
echo "  2) Implement scoped changes"
echo "  3) Commit + push + PR"
