import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:tag/core/config/app_config.dart';
import 'package:tag/features/beta_feedback/domain/entities/beta_feedback_entities.dart';

class SupabaseBetaFeedbackDataSource {
  SupabaseBetaFeedbackDataSource({
    required AppConfig appConfig,
    HttpClient Function()? httpClientFactory,
    this.timeout = const Duration(seconds: 20),
  }) : _appConfig = appConfig,
       _httpClientFactory = httpClientFactory ?? HttpClient.new;

  final AppConfig _appConfig;
  final HttpClient Function() _httpClientFactory;
  final Duration timeout;
  static const int maxAttachmentBytes = 8 * 1024 * 1024;

  Future<BetaFeedbackSubmissionResult> submit({
    required BetaFeedbackReportDraft draft,
    required BetaFeedbackDiagnostics diagnostics,
  }) async {
    if (!_appConfig.betaFeedbackConfigured) {
      throw const BetaFeedbackException(
        'Beta feedback is not configured for this build.',
      );
    }

    final endpoint = Uri.tryParse(_appConfig.betaFeedbackEndpoint.trim());
    if (endpoint == null || !endpoint.hasScheme || !endpoint.hasAuthority) {
      throw const BetaFeedbackException(
        'The beta feedback endpoint is not a valid URL.',
      );
    }

    final payload = await buildPayload(draft: draft, diagnostics: diagnostics);
    final client = _httpClientFactory();

    try {
      final request = await client.postUrl(endpoint).timeout(timeout);
      request.headers.contentType = ContentType.json;
      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer ${_appConfig.betaFeedbackAnonKey.trim()}',
      );
      request.headers.set('apikey', _appConfig.betaFeedbackAnonKey.trim());
      request.write(jsonEncode(payload));

      final response = await request.close().timeout(timeout);
      final responseBody = await utf8.decoder.bind(response).join();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw BetaFeedbackException(
          _errorMessageFromResponse(response.statusCode, responseBody),
        );
      }

      final decoded = jsonDecode(responseBody);
      if (decoded is! Map<String, dynamic>) {
        throw const BetaFeedbackException(
          'The beta feedback service returned an unexpected response.',
        );
      }

      final reportId = (decoded['report_id'] ?? decoded['id'])?.toString();
      if (reportId == null || reportId.trim().isEmpty) {
        throw const BetaFeedbackException(
          'The beta feedback service did not return a report id.',
        );
      }

      return BetaFeedbackSubmissionResult(
        reportId: reportId,
        publicIssueUrl: decoded['public_issue_url']?.toString(),
        publicIssueNumber: decoded['public_issue_number'] is int
            ? decoded['public_issue_number'] as int
            : int.tryParse(decoded['public_issue_number']?.toString() ?? ''),
      );
    } on TimeoutException {
      throw const BetaFeedbackException(
        'The beta feedback service took too long to respond. Please try again.',
      );
    } on SocketException {
      throw const BetaFeedbackException(
        'Tag could not reach the beta feedback service. Please try again when you are online.',
      );
    } finally {
      client.close(force: true);
    }
  }

  Future<Map<String, Object?>> buildPayload({
    required BetaFeedbackReportDraft draft,
    required BetaFeedbackDiagnostics diagnostics,
  }) async {
    final attachments = <Map<String, Object?>>[];

    for (final attachment in draft.attachments) {
      final bytes = await File(attachment.path).readAsBytes();
      if (bytes.length > maxAttachmentBytes) {
        throw const BetaFeedbackException(
          'The screenshot is over 8 MB. Please choose a smaller image.',
        );
      }
      attachments.add({
        'filename': attachment.fileName,
        'content_type': attachment.contentType,
        'byte_size': bytes.length,
        'base64_data': base64Encode(bytes),
      });
    }

    return {
      'summary': draft.summary.trim(),
      'happened': draft.happened.trim(),
      'expected': draft.expected.trim(),
      'steps': draft.steps.trim(),
      'area': draft.area.label,
      'area_label': draft.area.githubLabel,
      'contact_email': _nullIfBlank(draft.contactEmail),
      'consent_private_review': draft.consentPrivateReview,
      'include_diagnostics': draft.includeDiagnostics,
      'diagnostics': draft.includeDiagnostics ? diagnostics.toJson() : null,
      'app_version': diagnostics.appVersion,
      'build_number': diagnostics.buildNumber,
      'device_model': diagnostics.deviceModel,
      'os_version': diagnostics.osVersion,
      'attachments': attachments,
    };
  }

  String _errorMessageFromResponse(int statusCode, String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['error'] ?? decoded['message'];
        if (message != null && message.toString().trim().isNotEmpty) {
          return message.toString();
        }
      }
    } on FormatException {
      // Fall through to a generic message.
    }

    return 'The beta feedback service rejected the report ($statusCode).';
  }

  String? _nullIfBlank(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
