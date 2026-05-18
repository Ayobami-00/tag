# Security Policy

Tag is designed to be local-first. Saved sources, extracted text, cards, chat history, embeddings, local files, and notification state should remain on device unless the user explicitly exports or shares something outside the app.

## Reporting a Vulnerability

Please use GitHub private vulnerability reporting if it is enabled for this repository. If it is not enabled, open a public issue only with a sanitized high-level description and no exploit details, secrets, private screenshots, local databases, or personal data.

Useful report details:

- affected app version or commit;
- device and OS version;
- concise reproduction steps;
- whether the issue involves network access, local storage, source evidence, notifications, or model processing;
- sanitized logs or screenshots.

## Scope

High-priority security and privacy issues include:

- private saved content leaving the device unexpectedly;
- card creation without required source evidence;
- notifications scheduled for passive or suggestion cards;
- cards created from chat or suggestions without user confirmation;
- sensitive data written to logs, screenshots, artifacts, or crash output;
- local database or file-store corruption.

## Public Data Hygiene

Do not commit or attach:

- private screenshots or message/email content;
- local SQLite databases or app containers;
- Apple certificates, provisioning profiles, keys, exported IPAs, or archives;
- model weights or converted local model artifacts;
- API keys, tokens, or service credentials.
