# Fix Gemma4 DFlash draft-model load (use_mm_prefix)

## Problem

Launching Gemma4 targets (e.g. `google/gemma-4-26B-A4B-it`) with a DFlash
drafter (`z-lab/gemma-4-26B-A4B-it-DFlash`) crashes at draft-model load:

```
ValueError: Selected backend AttentionBackendEnum.FLASH_ATTN is not valid
for this configuration. Reason: ['partial multimodal token full attention
not supported', 'mm_prefix (PrefixLM bidirectional attention) requires
FlashAttention v4, which does not resolve for this head_size']
```

Gemma4 is multimodal with PrefixLM bidirectional attention, so vLLM
restricts its attention backend selection (`use_mm_prefix`). The DFlash
draft attention layers were inheriting that target restriction, and the
requested `flash_attn` drafter backend then failed to resolve.

## Fix

Upstream vLLM PR [#41703](https://github.com/vllm-project/vllm/pull/41703)
adds a `use_mm_prefix` override to `Attention` and a `DFlashAttention`
subclass that opts draft layers out of the restriction. As of September
2026 the PR is unmerged (labelled needs-rebase/stale).

The raw PR diff (last rebased May 2026) does not apply to current vLLM
nightlies. This mod instead carries `gemma4-dflash-mm-prefix.patch`, a
two-file subset of the PR (attention.py use_mm_prefix kwarg + qwen3_dflash.py
DFlashAttention subclass) rebased against the container's vLLM build
(commit 7a9993878, 2026-08-26 nightly — verified by source sha256 match).
The mod is idempotent: it applies cleanly, detects an already-applied
patch, and skips gracefully if the container's vLLM changes shape again
(will need a rebase against the new build at that point).

## Health check after launch

Expected DFlash acceptance length on Gemma-4-26B-A4B is ~7.7 tokens
(z-lab benchmark, 15 speculative tokens). A much lower value suggests
the PR's Gemma4 logits-correctness change (embedding normalization +
final_logit_softcapping) did not apply cleanly.