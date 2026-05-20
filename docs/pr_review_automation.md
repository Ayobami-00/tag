# PR Review Automation

Tag uses a human-reviewable loop for AI-assisted fixes:

1. A beta issue creates a local Codex task.
2. Codex fixes the issue on a normal branch such as `feat/...`, `fix/...`, or `chore/...`.
3. A PR opens with concise validation evidence.
4. Greptile reviews the PR.
5. Codex keeps updating the same branch until Greptile reports `5/5`.
6. Demo proof is stored privately in Supabase Storage for user-visible or behavior-critical fixes.
7. The user reviews the PR and decides when to merge.

Greptile must be installed through the Greptile dashboard and enabled for this
repository. The repository keeps `greptile.json` with `triggerOnUpdates: true`
so every Codex push asks Greptile for a fresh pass. `statusCheck: true` asks
Greptile to publish its own PR status check when supported by the installation.

After Greptile is installed, protect `main` with:

```sh
node scripts/configure_branch_protection.mjs main
```

This requires the existing Flutter CI check only. Tag no longer has a custom
PR acceptance-gate workflow.

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

The manifest script uploads the video, command log, and JSON manifest to the
private `demo-proofs` Supabase Storage bucket and records metadata in
`public.demo_proofs`. Demo proof is not posted as a public PR comment.
