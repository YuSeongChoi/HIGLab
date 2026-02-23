#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="practice/HIGPractice/LEARNING_LOG.md"

usage() {
  cat <<USAGE
Usage:
  scripts/add_learning_log.sh \
    --date YYYY-MM-DD \
    --phase "Phase 1" \
    --framework "WidgetKit" \
    --scope "Core timeline" \
    --issue "#123" \
    --pr "#124" \
    --velog "https://velog.io/@..." \
    --key "One key learning"
USAGE
}

DATE=""
PHASE=""
FRAMEWORK=""
SCOPE=""
ISSUE=""
PR=""
VELOG=""
KEY=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --date) DATE="$2"; shift 2 ;;
    --phase) PHASE="$2"; shift 2 ;;
    --framework) FRAMEWORK="$2"; shift 2 ;;
    --scope) SCOPE="$2"; shift 2 ;;
    --chapter) SCOPE="$2"; shift 2 ;;
    --issue) ISSUE="$2"; shift 2 ;;
    --pr) PR="$2"; shift 2 ;;
    --velog) VELOG="$2"; shift 2 ;;
    --key) KEY="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1"; usage; exit 1 ;;
  esac
done

for v in DATE PHASE FRAMEWORK SCOPE ISSUE PR VELOG KEY; do
  if [[ -z "${!v}" ]]; then
    echo "Missing required argument: ${v}"
    usage
    exit 1
  fi
done

if [[ ! -f "${LOG_FILE}" ]]; then
  echo "Log file not found: ${LOG_FILE}"
  exit 1
fi

ROW="| ${DATE} | ${PHASE} | ${FRAMEWORK} | ${SCOPE} | ${ISSUE} | ${PR} | ${VELOG} | ${KEY} |"

python3 - "${ROW}" <<'PY'
import sys
from pathlib import Path

log_file = Path("practice/HIGPractice/LEARNING_LOG.md")
row = sys.argv[1]

text = log_file.read_text(encoding="utf-8")
needle = "|---|---|---|---|---|---|---|---|"
if needle not in text:
    raise SystemExit("Could not find table separator row in LEARNING_LOG.md")

text = text.replace(needle, needle + "\n" + row, 1)
log_file.write_text(text, encoding="utf-8")
PY

echo "Added row to ${LOG_FILE}"
