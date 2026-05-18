String normalizeTagCardTitle(String title) {
  var cleaned = title.replaceAll(RegExp(r'\s+'), ' ').trim();
  cleaned = cleaned.replaceFirst(
    RegExp(
      r'^\d{1,2}:\d{2}\s+.{0,56}\b(?:post|posts)\b\s*[•·.\-:]*\s*',
      caseSensitive: false,
    ),
    '',
  );
  cleaned = cleaned.replaceFirst(
    RegExp(
      r'^\d{1,2}:\d{2}\s*(?:[|Il1]{1,4}\s*)?(?:5g|4g|lte|wifi|wi-fi)?\s*\d{1,3}\s*',
      caseSensitive: false,
    ),
    '',
  );
  cleaned = cleaned.replaceFirst(
    RegExp(
      r'^(?:post|posts|x\.com|linkedin|whatsapp|messages?)\s*[•·.\-:]*\s+',
      caseSensitive: false,
    ),
    '',
  );
  cleaned = cleaned.replaceAll(RegExp(r'\s+[•·.]{2,}:?\s*'), ' ');
  cleaned = cleaned.replaceAll(RegExp(r'^[•·.\-:]+\s*'), '');
  cleaned = cleaned.replaceAllMapped(
    RegExp(r'\s+([:;,])'),
    (match) => match.group(1)!,
  );
  if (_looksAiRelatedTitle(cleaned)) {
    cleaned = cleaned.replaceAll(RegExp(r'\bA[Il1]\b'), 'AI');
  }

  return cleaned.isEmpty ? 'Review saved source' : cleaned;
}

bool _looksAiRelatedTitle(String title) {
  final lower = title.toLowerCase();
  return lower.contains('scientist') ||
      lower.contains('saturdays') ||
      lower.contains('deepmind') ||
      lower.contains('llm') ||
      lower.contains('machine learning') ||
      lower.contains('applied ai') ||
      lower.contains(' ai ');
}
