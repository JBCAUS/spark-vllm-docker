#!/bin/bash
set -e

MOD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATCH_FILE="$MOD_DIR/gemma4-dflash-mm-prefix.patch"

cd /usr/local/lib/python3.12/dist-packages
echo "Applying Gemma4 DFlash mm_prefix fix (curated from vLLM PR #41703, rebased to the container's vLLM nightly 7a9993878)"
if git apply --check "$PATCH_FILE" 2>/dev/null; then
  git apply "$PATCH_FILE"
  echo "- patch applied successfully"
elif git apply --reverse --check "$PATCH_FILE" 2>/dev/null; then
  echo "- patch already applied, skipping"
else
  echo "- patch does not apply to this vLLM build, skipping"
fi