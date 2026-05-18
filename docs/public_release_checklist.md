# Public Release Checklist

Use this before making the repository public.

## Must Do Before Public Visibility

- Publish from a clean history, or rewrite existing history before making the current repository public.
- Do not expose old commits that contain personal identifiers, private OCR fixtures, signing settings, or local-only validation artifacts.
- Confirm `git status --short` contains only files intended for the public release.
- Confirm `git ls-files` does not include private screenshots, local databases, model weights, provisioning profiles, certificates, exported IPAs, or archives.
- Confirm README screenshots are synthetic or redacted.

## Current Tree Checks

Recommended scans:

```sh
git grep -n -I -E "(PRIVATE KEY|client secret|API key|access token|refresh token)"
git ls-files | rg "(artifacts|milestones|references|\\.sqlite|\\.db|\\.gguf|\\.safetensors|\\.onnx|\\.tflite|\\.mobileprovision|\\.p12|\\.pem|\\.key|\\.ipa|\\.xcarchive)"
rg -n -I "(private address|private email|personal fixture)" --glob '!artifacts/**' --glob '!build/**'
```

## Git History Checks

Before public release, check history too:

```sh
git grep -n -I -E "(PRIVATE KEY|client secret|API key|access token|refresh token)" $(git rev-list --all)
git rev-list --objects --all | rg "(artifacts|milestones|references|\\.sqlite|\\.db|\\.gguf|\\.safetensors|\\.onnx|\\.tflite|\\.mobileprovision|\\.p12|\\.pem|\\.key|\\.ipa|\\.xcarchive)"
```

If history contains anything sensitive, prefer creating a fresh public repository from the cleaned working tree. Rewriting a repository that has already been shared requires every collaborator to re-clone.

## Public Community Setup

- `CONTRIBUTING.md`
- `SECURITY.md`
- `CODE_OF_CONDUCT.md`
- GitHub issue forms for bugs, features, and privacy/local-first concerns
- Pull request template with Tag product guardrails
- CI workflow for `flutter analyze` and `flutter test`
- Dependabot for pub dependencies
