import 'package:equatable/equatable.dart';

enum BetaFeedbackArea {
  importShareExtension(
    label: 'Import / share extension',
    githubLabel: 'area: import-share-extension',
  ),
  ocrExtraction(label: 'OCR / extraction', githubLabel: 'area: ocr-extraction'),
  intentDetection(
    label: 'Intent detection',
    githubLabel: 'area: intent-detection',
  ),
  todayCards(label: 'Today cards', githubLabel: 'area: today-cards'),
  sourceEvidence(
    label: 'Source evidence',
    githubLabel: 'area: source-evidence',
  ),
  spaces(label: 'Spaces', githubLabel: 'area: spaces'),
  chatRetrieval(label: 'Chat / retrieval', githubLabel: 'area: chat-retrieval'),
  notifications(label: 'Notifications', githubLabel: 'area: notifications'),
  modelSetup(label: 'Model setup', githubLabel: 'area: model-setup'),
  performanceJank(
    label: 'Performance / jank',
    githubLabel: 'area: performance-jank',
  ),
  other(label: 'Other', githubLabel: 'area: other');

  const BetaFeedbackArea({required this.label, required this.githubLabel});

  final String label;
  final String githubLabel;
}

class BetaFeedbackAttachment extends Equatable {
  const BetaFeedbackAttachment({
    required this.path,
    required this.fileName,
    required this.contentType,
    required this.byteSize,
  });

  final String path;
  final String fileName;
  final String contentType;
  final int byteSize;

  bool get isImage => contentType.startsWith('image/');

  @override
  List<Object?> get props => [path, fileName, contentType, byteSize];
}

class BetaFeedbackDiagnostics extends Equatable {
  const BetaFeedbackDiagnostics({
    required this.appVersion,
    required this.buildNumber,
    required this.commitSha,
    required this.deviceModel,
    required this.osVersion,
    required this.currentSurface,
    required this.generatedAtIso8601,
    this.extra = const {},
  });

  final String appVersion;
  final String buildNumber;
  final String commitSha;
  final String deviceModel;
  final String osVersion;
  final String currentSurface;
  final String generatedAtIso8601;
  final Map<String, Object?> extra;

  Map<String, Object?> toJson() {
    return {
      'app_version': appVersion,
      'build_number': buildNumber,
      'commit_sha': commitSha,
      'device_model': deviceModel,
      'os_version': osVersion,
      'current_surface': currentSurface,
      'generated_at': generatedAtIso8601,
      ...extra,
    };
  }

  @override
  List<Object?> get props => [
    appVersion,
    buildNumber,
    commitSha,
    deviceModel,
    osVersion,
    currentSurface,
    generatedAtIso8601,
    extra,
  ];
}

class BetaFeedbackReportDraft extends Equatable {
  const BetaFeedbackReportDraft({
    required this.summary,
    required this.happened,
    required this.expected,
    required this.steps,
    required this.area,
    required this.consentPrivateReview,
    this.contactEmail,
    this.attachments = const [],
    this.includeDiagnostics = true,
  });

  final String summary;
  final String happened;
  final String expected;
  final String steps;
  final BetaFeedbackArea area;
  final String? contactEmail;
  final bool consentPrivateReview;
  final List<BetaFeedbackAttachment> attachments;
  final bool includeDiagnostics;

  BetaFeedbackReportDraft copyWith({
    String? summary,
    String? happened,
    String? expected,
    String? steps,
    BetaFeedbackArea? area,
    String? contactEmail,
    bool? consentPrivateReview,
    List<BetaFeedbackAttachment>? attachments,
    bool? includeDiagnostics,
  }) {
    return BetaFeedbackReportDraft(
      summary: summary ?? this.summary,
      happened: happened ?? this.happened,
      expected: expected ?? this.expected,
      steps: steps ?? this.steps,
      area: area ?? this.area,
      contactEmail: contactEmail ?? this.contactEmail,
      consentPrivateReview: consentPrivateReview ?? this.consentPrivateReview,
      attachments: attachments ?? this.attachments,
      includeDiagnostics: includeDiagnostics ?? this.includeDiagnostics,
    );
  }

  @override
  List<Object?> get props => [
    summary,
    happened,
    expected,
    steps,
    area,
    contactEmail,
    consentPrivateReview,
    attachments,
    includeDiagnostics,
  ];
}

class BetaFeedbackSubmissionResult extends Equatable {
  const BetaFeedbackSubmissionResult({
    required this.reportId,
    this.publicIssueUrl,
    this.publicIssueNumber,
  });

  final String reportId;
  final String? publicIssueUrl;
  final int? publicIssueNumber;

  @override
  List<Object?> get props => [reportId, publicIssueUrl, publicIssueNumber];
}

class BetaFeedbackException implements Exception {
  const BetaFeedbackException(this.message);

  final String message;

  @override
  String toString() => message;
}
