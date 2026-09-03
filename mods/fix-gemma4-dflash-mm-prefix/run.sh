#!/bin/bash
set -e

cd /usr/local/lib/python3.12/dist-packages
echo "Applying PR #41703 (Gemma4 DFlash: draft attention must not inherit mm_prefix)"
if curl -fsL https://patch-diff.githubusercontent.com/raw/vllm-project/vllm/pull/41703.diff | git apply --exclude="tests/*"; then
  echo "- PR #41703 applied successfully"
else
  echo "- PR #41703 can't be applied, skipping"
fi