#!/usr/bin/env bash
set -euo pipefail

REPO="${1:-YuSeongChoi/HIGLab}"

create_or_update_label() {
  local name="$1"
  local color="$2"
  local desc="$3"

  if gh label create "$name" --repo "$REPO" --color "$color" --description "$desc" 2>/dev/null; then
    echo "created: $name"
  else
    gh label edit "$name" --repo "$REPO" --color "$color" --description "$desc"
    echo "updated: $name"
  fi
}

create_or_update_label "learning" "1D76DB" "Learning task"
create_or_update_label "chapter" "0E8A16" "Single chapter scoped work"
create_or_update_label "retrospective" "5319E7" "Post-learning retrospective"
create_or_update_label "needs-review" "FBCA04" "Needs code review"
create_or_update_label "phase-1" "0052CC" "Phase 1: App Frameworks"
create_or_update_label "phase-2" "1D76DB" "Phase 2: App Services"
create_or_update_label "phase-3" "5319E7" "Phase 3: Graphics & Media"
create_or_update_label "phase-4" "C2E0C6" "Phase 4: System & Network"
create_or_update_label "phase-5" "B60205" "Phase 5: iOS 26"

echo "Label setup complete for $REPO"
