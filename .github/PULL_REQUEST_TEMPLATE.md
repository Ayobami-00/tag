## Summary

<!-- What changed and why? -->

## Validation

<!-- List commands, simulator/device checks, screenshots, or manual validation performed. -->

- [ ] `flutter analyze`
- [ ] `flutter test`
- [ ] Live import/source-evidence flow checked where relevant
- [ ] Tag demo proof attached for the current head commit
- [ ] Greptile review reached `5/5`

## Tag Product Guardrails

- [ ] No login, cloud sync, telemetry, or remote LLM dependency was added.
- [ ] User-visible cards remain linked to source evidence.
- [ ] Each Tag Card still has exactly one primary Space.
- [ ] Suggestion and passive cards do not schedule notifications.
- [ ] Goal cards from suggestions/chat require preview and confirmation.
- [ ] Private screenshots, local databases, model weights, signing files, and generated artifacts are not committed.

## Screenshots

<!-- Add sanitized screenshots for UI changes. Do not include private saved content. -->

## Demo Proof

<!--
For UI or behavior fixes, generate a proof bundle with:

scripts/record_ios_demo.sh pr-<number>-attempt-<n> -- <your e2e command>
node scripts/demo_proof_manifest.mjs --pr <number> --attempt <n> --video <path-or-url> --command-log <path-or-url>

Paste the generated demo-proof-comment.md marker into the PR. The acceptance gate requires a passing marker for the current head SHA.
-->
