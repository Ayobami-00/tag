import 'dart:convert';

import 'package:tag/features/source_ingestion/domain/entities/source_item_entity.dart';

abstract final class CactusPromptTemplates {
  static const extractionSystemPrompt = '''
You are Tag's local extraction model.
You run fully on-device. Do not mention cloud services.
Return only one JSON object. Do not use markdown.

Schema:
{
  "text": "all readable text or a concise visual description when text is absent",
  "visible_entities": ["people, places, products, apps, organizations"],
  "dates": ["raw date strings found in the source"],
  "times": ["raw time strings found in the source"],
  "links": ["visible URLs"],
  "content_type": "unknown",
  "language": "BCP-47 language code such as en",
  "confidence": 0.0
}

Rules:
- Preserve source evidence faithfully, including the exact wording of requests,
  deadlines, names, places, apps, products, organizations, and visible codes.
- Extract only what is visible or present in OCR/text. Do not infer hidden
  context, missing dates, missing times, or unstated actions.
- Do not decide whether this should become a card. This step only captures
  source evidence for the intention detector.
- If readable text exists, put that text in "text". If no readable text exists,
  put a concise visual description in "text".
- Keep dates and times as raw strings found in the source. Do not normalize
  them or convert relative dates.
- Use "unknown" when content type is unclear.
- content_type must be exactly one of: message, job_post, article, event, product, travel, unknown.
- confidence must be between 0 and 1 and should reflect evidence readability:
  0.90+ for clear text/OCR, 0.70-0.89 for mostly clear text, 0.50-0.69 for
  partial or ambiguous text, below 0.50 for weak evidence.
''';

  static const intentionSystemPrompt = '''
You are Tag's local intention detector.
You turn saved source evidence into a proposed intention, not a final card.
Return only one JSON object. Do not use markdown.

Schema:
{
  "intention_type": "learn | apply | buy | attend | reply | follow_up | plan | decide | read | remember | compare",
  "confidence": 0.0,
  "title": "short user-facing title",
  "reason": "why the saved source appears actionable",
  "next_active_deadline": null,
  "suggested_card_type": "urgent | goal | suggestion | passive",
  "space_suggestion": "one primary Space name",
  "source_summary": "short source label",
  "evidence_summary": "specific source-backed evidence"
}

Rules:
- The source evidence is private and local. Do not ask to upload it.
- Every actionable proposal must cite the saved source in reason or evidence_summary.
- Choose the narrowest intention type. Do not use "apply" to mean a generic action.
- Treat direct requests, favors, asks, and help-seeking language as actionable
  when the source asks the user to do something. Examples: "please...", "can
  you...", "could you...", "help me...", "remind me to...", "send...", "make...",
  "bring...", "call...", "reply...", "review...", "book...", "prepare...".
- Treat saved opportunities as actionable when the likely reason for saving is
  to act later: job/application pages, event invitations, sign-in/security
  messages, purchases, documents to review, comparisons, plans, and articles or
  resources clearly worth reading later.
- Treat calls, meetings, implementation walkthroughs, and feedback requests as
  actionable follow-ups when the source asks to arrange time or review work.
- Do not treat generic ads, marketing CTAs, historical posts, memes,
  screenshots kept for nostalgia, or completed status notes as actionable unless
  the source clearly asks the user to do something or shows a likely follow-up.
- Use "apply" only for applications to jobs, schools, grants, visas, programs,
  or similar formal opportunities.
- Use "buy" for purchasing, picking up, ordering, cooking/preparing requested
  items, or being asked to get a purchasable errand item. Do not use "buy" for
  phrases like "get feedback", "get help", "get access", or "get on a call".
- Use "attend" for events with a time/place, "reply" for messages needing a
  direct response, "follow_up" for doing or checking back on a request, "read"
  for documents/articles/resources to review, "decide" for choices/RSVP/security
  review, and "compare" for explicit alternatives.
- Card threshold: if confidence is below 0.60, set suggested_card_type to
  "passive" even if there may be an action. From 0.60 to 0.71, use "suggestion"
  unless there is a clear deadline or multi-step goal. At 0.72 or higher, use
  the best fitting urgent/goal/suggestion type.
- Use "urgent" only when source evidence contains a current or future deadline,
  date, time, expiry, event time, or same-day/soon pressure.
- Use "goal" for multi-step learning, application, planning, or progress-based
  work. Do not use "goal" for a one-off request.
- Use "suggestion" for actionable items without notification pressure.
- Use "passive" when no clear user action exists or confidence is below 0.60.
- next_active_deadline must be null or ISO-8601 with timezone when evidence
  supports it. Never invent a deadline.
- Use source_description as user-provided import context when present, but keep
  reason and evidence_summary grounded in the saved source.
''';

  static String extractionUserPromptForText(SourceItemEntity source) {
    return '''
Extract source content for Tag.

Source:
${_sourceContext(source)}

Raw text:
${source.rawText ?? ''}

Return valid JSON only.
''';
  }

  static String extractionUserPromptForImage(
    SourceItemEntity source, {
    String? recognizedText,
  }) {
    final descriptionBlock = _sourceDescriptionPromptBlock(source);
    final ocrText = recognizedText?.trim();
    final ocrBlock = ocrText == null || ocrText.isEmpty
        ? ''
        : '''

On-device OCR text from this same image:
$ocrText
''';

    return '''
Extract source content from the attached saved image for Tag.
Inspect the attached image itself. Use the on-device OCR text as source evidence when it is present, correcting obvious OCR mistakes from the image. Preserve direct request wording and visible deadlines exactly. Do not copy these instructions or any hidden source metadata.$descriptionBlock$ocrBlock

Return valid JSON only.
''';
  }

  static String intentionUserPrompt({
    required SourceItemEntity source,
    required Map<String, Object?> extractionJson,
    required DateTime now,
  }) {
    return '''
Detect the user's likely intention from this saved source.
Decide whether the evidence crosses Tag's card threshold. A card-worthy source
has a clear request, action, opportunity, deadline, decision, review, or
follow-up. If the evidence is merely interesting, promotional, historical,
completed, or unclear, return passive.

Current local time:
${now.toIso8601String()}

Source:
${_sourceContext(source)}

Validated extraction JSON:
${const JsonEncoder.withIndent('  ').convert(extractionJson)}

Return valid JSON only.
''';
  }

  static String retryPrompt(String validationError) {
    return '''
Your previous output was invalid:
$validationError

Return only one corrected JSON object matching the requested schema.
''';
  }

  static String _sourceContext(SourceItemEntity source) {
    final sourceDescriptionLine = source.sourceDescription == null
        ? ''
        : 'source_description: ${source.sourceDescription}\n';
    return '''
id: ${source.id}
type: ${source.type.storageValue}
app_source: ${source.appSource ?? 'Manual'}
summary: ${source.sourceSummary ?? 'Saved source'}
${sourceDescriptionLine}content_type: ${source.contentType}
''';
  }

  static String _sourceDescriptionPromptBlock(SourceItemEntity source) {
    final description = source.sourceDescription;
    if (description == null) {
      return '';
    }

    return '''

User-provided source_description:
$description

Use source_description only to disambiguate why the user saved the image. Keep extracted text, dates, times, links, and visible entities grounded in the attached image or OCR.
''';
  }
}
