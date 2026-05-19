# PR Review Automation

Tag uses a human-reviewable loop for AI-assisted fixes:

1. A beta issue creates a local Codex task.
2. Codex fixes the issue on a normal branch such as `feat/...`, `fix/...`, or `chore/...`.
3. A PR opens with validation evidence and a Tag demo proof marker.
4. Greptile reviews the PR.
5. The PR acceptance gate blocks merge until:
   - `flutter analyze` / `flutter test` CI is green.
   - the latest Greptile score is `5/5`.
   - a current-head Tag demo proof marker is attached.
   - no human reviewer has an unresolved blocker such as `/codex not fixed` or “not fixed”.

Greptile must be installed through the Greptile dashboard and enabled for this
repository. The repository keeps `greptile.json` with `triggerOnUpdates: true`
so every Codex push asks Greptile for a fresh pass.

After Greptile is installed, protect `main` with:

```sh
node scripts/configure_branch_protection.mjs main
```

This requires the existing Flutter CI check plus `Tag PR acceptance gate`.
The gate itself verifies Greptile `5/5`, demo proof, and human blockers.

## Demo Proof

Record the simulator proof locally:

```sh
scripts/record_ios_demo.sh pr-12-attempt-1 -- node internal/supabase/scripts/run-app-live-e2e.mjs
```

Create the proof marker:

```sh
node scripts/demo_proof_manifest.mjs \
  --pr 12 \
  --attempt 1 \
  --video artifacts/demo_proofs/pr-12-attempt-1/demo_<timestamp>.mp4 \
  --command-log artifacts/demo_proofs/pr-12-attempt-1/command_<timestamp>.log
```

Paste the generated `demo-proof-comment.md` into the PR. The gate verifies that
the marker has `status: "pass"` and `head_sha` equal to the current PR head.

## Human Feedback

Use these comments to drive another Codex pass:

```text
/codex not fixed
```

or:

```text
not fixed: <what still fails>
```

When the fix is confirmed, resolve the blocker with:

```text
/codex fixed
```

The gate treats unresolved human blockers as merge blockers even if CI and
Greptile are green.
