# Tag Local Demo Guide

This guide is for running and inspecting the Tag MVP locally.

## What The Demo Shows

The demo path should show:

1. Fresh launch and local-first onboarding.
2. Local model setup where device capacity allows.
3. Importing saved screenshots or images through the app or iOS share flow.
4. Tag creating source-backed cards for reminders, job follow-ups, read-later items, and learning goals.
5. Opening source evidence from a card.
6. Asking chat questions over saved context.
7. Creating a guided plan from related saved learning resources.
8. Local notification policy: only active reminder and goal cards notify.

## Run Locally

```sh
flutter pub get
flutter analyze
flutter test
flutter build ios --simulator --debug
flutter run -d <simulator_id> --debug
```

For release build validation:

```sh
flutter build ios --release --no-codesign
```

Physical iPhone release runs require Apple signing, provisioning, and Developer Mode:

```sh
flutter run -d <physical_device_id> --release
```

## Demo Data

Use redacted or synthetic screenshots for public demo recording. Real private screenshots should not be published unredacted.

Recommended public demo scenarios:

- An email with an application deadline.
- A message asking to schedule a family call.
- A saved article to finish later.
- A saved company formation note.
- Three related learning resources that cluster into a goal.

## Expected Flow

### 1. Save Something

Import or share a screenshot into Tag.

Expected:

- The app confirms the source was saved quickly.
- The source appears in local storage.
- Processing continues without freezing the UI.

### 2. Recover The Intention

Tag analyzes the saved source locally and proposes the relevant intention.

Expected:

- Deadline screenshots become active reminder cards.
- Read-later screenshots become reading cards or passive saved knowledge depending on actionability.
- Passive notes are retrievable in chat without unnecessary notifications.
- Related learning resources become a non-notifying suggestion card.

### 3. Trust But Verify

Open a card and inspect its source.

Expected:

- The original screenshot is visible.
- Extracted evidence is visible.
- The card explains why it exists.
- Every card has exactly one primary Space.

### 4. Ask Chat

Ask questions such as:

```text
What company formation information have I saved?
What learning resources have I saved?
What job applications do I need to follow up on?
What personal reminders do I have this weekend?
```

Expected:

- Answers are grounded in local saved context.
- Citation or source chips open the relevant source preview.
- Chat does not create or edit cards without confirmation.
- Loading and error states are visible and recoverable.

### 5. Plan From Related Saves

Tap `Plan this` on a learning suggestion card.

Expected:

- Guided planning opens.
- Tag previews goal cards.
- No goal cards are created before confirmation.
- Confirmed goal cards link back to the saved sources.

## Live Validation

Use live app flows for product validation. Do not seed the database, mock AI responses, or hand-edit rows to create passing states unless the specific test is explicitly marked as a fixture-based developer test.
