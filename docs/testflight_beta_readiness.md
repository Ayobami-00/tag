# Tag TestFlight Beta Readiness

This is the intended beta scope for the first TestFlight build.

## Bundle And Signing

- App bundle ID: `com.usetag.tag`
- Share extension bundle ID: `com.usetag.tag.share`
- App group: `group.com.festusowumi.usetag`
- Display name: `Tag`
- Version: `1.0.0`
- Build: `1`

These are the maintainer-owned identifiers used for the current beta. Forks and local device builds should use their own Apple Developer Team, bundle IDs, App Group, certificates, and provisioning profiles.

Before archiving, make sure the Apple Developer account has:

- an App ID for `com.usetag.tag`;
- an App ID for `com.usetag.tag.share`;
- the App Group `group.com.festusowumi.usetag`;
- both targets associated with the App Group entitlement;
- automatic signing or provisioning profiles updated for the new identifiers.

## Beta Scope

Market this beta around:

- single-image import through Photos/share flows;
- Today cards for reminders, reading, source-backed goals, and suggestions;
- source evidence previews;
- local-only storage and local-first processing;
- notification policy for active reminder and goal cards.

Do not market these as fully reliable yet:

- multi-select import from Photos;
- guided planning from suggestions;
- long-running chat planning workflows.

## App Store Connect Privacy Draft

Recommended App Privacy answer for this local-first beta:

- Data collection: `No, we do not collect data from this app`.

Use this only while Tag has no account system, backend sync, remote LLM, telemetry, ads, analytics SDK, or crash reporting SDK that sends user or device data off-device. If any third-party SDK or remote service is added, update App Store Connect before release.

App Store Connect still requires a privacy policy URL for the iOS app. The policy should state that saved screenshots, extracted text, cards, chat history, model assets, and notifications remain on device unless the user explicitly exports or shares them outside Tag.

Apple references:

- https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy
- https://developer.apple.com/app-store/app-privacy-details/
- https://developer.apple.com/help/app-store-connect/test-a-beta-version/testflight-overview

## Required Pre-Beta Validation

Run these before uploading a build:

```sh
flutter pub get
flutter analyze
flutter test
flutter build ios --simulator --debug
flutter build ios --release --no-codesign
```

Then run one clean-device simulator or physical-device smoke pass after model setup:

- fresh install and onboarding;
- notification permission prompt;
- model setup reaches usable UI;
- single-image import from Photos/share sheet;
- Today card appears after processing;
- source preview opens from the card;
- no notification is scheduled for suggestion/passive cards;
- app relaunch preserves cards and sources.

Physical-device signed validation is preferred before external TestFlight because release mode and entitlements are closest to the beta build.
