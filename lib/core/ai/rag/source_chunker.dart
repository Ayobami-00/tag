import 'dart:math' as math;

import 'package:tag/core/ai/rag/rag_models.dart';

class SourceChunker {
  const SourceChunker({
    this.minimumCharacters = 8,
    this.minimumWords = 2,
    this.overlapTokenEstimate = 48,
  });

  final int minimumCharacters;
  final int minimumWords;
  final int overlapTokenEstimate;

  List<RagChunkDraft> chunk(String text, {required int maxTokenEstimate}) {
    final words = RegExp(r'\S+').allMatches(text).toList(growable: false);
    if (words.isEmpty) {
      return const [];
    }

    final trimmed = text.trim();
    if (_isLowQuality(trimmed, words.length)) {
      return const [];
    }

    final maxWords = math.max(24, (maxTokenEstimate / 1.3).floor());
    if (words.length <= maxWords) {
      return [
        _draft(
          chunkIndex: 0,
          text: text,
          start: words.first.start,
          end: words.last.end,
          wordCount: words.length,
        ),
      ];
    }

    final overlapWords = math.min(
      math.max(8, (overlapTokenEstimate / 1.3).round()),
      math.max(1, maxWords ~/ 4),
    );
    final step = math.max(1, maxWords - overlapWords);
    final drafts = <RagChunkDraft>[];

    var chunkIndex = 0;
    var startWordIndex = 0;
    while (startWordIndex < words.length) {
      var endWordIndex = math.min(startWordIndex + maxWords, words.length);
      final remainingWords = words.length - endWordIndex;
      if (remainingWords > 0 && remainingWords < minimumWords + overlapWords) {
        endWordIndex = words.length;
      }

      final start = words[startWordIndex].start;
      final end = words[endWordIndex - 1].end;
      final wordCount = endWordIndex - startWordIndex;
      drafts.add(
        _draft(
          chunkIndex: chunkIndex,
          text: text,
          start: start,
          end: end,
          wordCount: wordCount,
        ),
      );

      if (endWordIndex == words.length) {
        break;
      }

      startWordIndex += step;
      chunkIndex++;
    }

    return drafts;
  }

  RagChunkDraft _draft({
    required int chunkIndex,
    required String text,
    required int start,
    required int end,
    required int wordCount,
  }) {
    return RagChunkDraft(
      chunkIndex: chunkIndex,
      chunkText: text.substring(start, end).trim(),
      charStart: start,
      charEnd: end,
      tokenCountEstimate: math.max(1, (wordCount * 1.3).ceil()),
    );
  }

  bool _isLowQuality(String text, int wordCount) {
    if (text.isEmpty) {
      return true;
    }

    if (text.length < minimumCharacters && wordCount < minimumWords) {
      return true;
    }

    return false;
  }
}
