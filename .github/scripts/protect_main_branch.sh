#!/usr/bin/env bash
set -euo pipefail

REPO="${1:-YuSeongChoi/HIGLab}"
BRANCH="${2:-main}"
REQUIRED_CHECK="${3:-Build HIGPractice (iOS 26)}"

# Requires admin permission on the repository.
# Usage:
#   .github/scripts/protect_main_branch.sh YuSeongChoi/HIGLab main "Build HIGPractice (iOS 26)"

gh api \
  --method PUT \
  -H "Accept: application/vnd.github+json" \
  "/repos/${REPO}/branches/${BRANCH}/protection" \
  --input - <<JSON
{
  "required_status_checks": {
    "strict": true,
    "contexts": [
      "${REQUIRED_CHECK}"
    ]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": false,
    "required_approving_review_count": 1
  },
  "restrictions": null,
  "required_linear_history": true,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "block_creations": false,
  "required_conversation_resolution": true,
  "lock_branch": false,
  "allow_fork_syncing": true
}
JSON

echo "Branch protection applied: ${REPO}:${BRANCH}"
