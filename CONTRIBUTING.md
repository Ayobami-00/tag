# Contributing to Tag

Thanks for helping improve Tag. The project is a local-first personal intention inbox: saved thing -> detected intention -> Tag Card -> action.

## Product Principles

- Keep Tag local-first by default.
- Do not add login, cloud sync, telemetry, remote LLM processing, or hybrid cloud fallback behavior.
- Every user-visible Tag Card must link back to source evidence.
- Every Tag Card must have exactly one primary Space.
- Suggestion Cards and passive sources must not schedule notifications.
- Active urgent cards and active goal cards are the only card types that may schedule local notifications.
- Chat answers must not create cards unless the user confirms a proposed action.
- Goal cards created from suggestions require preview and confirmation.

## Development Setup

Prerequisites:

- Flutter SDK
- Xcode
- CocoaPods
- An iOS simulator, or a signed physical iPhone target

Install dependencies:

```sh
flutter pub get
```

Run checks:

```sh
flutter analyze
flutter test
```

Build for an iOS simulator:

```sh
flutter build ios --simulator --debug
flutter run -d <simulator_id> --debug
```

Unsigned release validation:

```sh
flutter build ios --release --no-codesign
```

## iOS Signing

The public project should not contain personal Apple signing material. For local device builds, set your own Apple Team in Xcode and use your own bundle IDs, App Group, certificates, and provisioning profiles as needed.

Do not commit:

- Apple Team IDs added only for your local signing setup.
- provisioning profiles, certificates, keys, exported IPAs, or Xcode archives.
- local app containers, SQLite databases, screenshots with private content, or generated test artifacts.

## Models and Private Data

Model assets and private screenshots are intentionally not committed. Use redacted or synthetic data in public issues, pull requests, screenshots, and tests.

If a bug requires real saved content to reproduce, create a synthetic fixture that preserves the behavior class without exposing private information.

## Code Style

- Follow the existing Flutter feature-first structure.
- Keep changes scoped to the product behavior being fixed.
- Prefer existing local repositories, validators, and platform wrappers over new global services.
- Add tests for validator changes, notification policy, source evidence, card creation, and retrieval behavior.
- Keep UI changes aligned with the existing theme and avoid adding generic task-manager or folder-system surfaces.

## Pull Requests

Before opening a pull request:

1. Run `flutter analyze`.
2. Run `flutter test`.
3. For user-facing flows, validate with the real app where practical.
4. Confirm no private data, signing material, model weights, local databases, or generated artifacts are included.
5. Fill out the pull request template, including product guardrails and validation notes.

## Issues

Use the issue templates for bug reports, feature requests, and privacy/local-first concerns. Include reproduction steps and sanitized evidence. Please do not upload private screenshots, tokens, databases, model files, or unredacted logs.
