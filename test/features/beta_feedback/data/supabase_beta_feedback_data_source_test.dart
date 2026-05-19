import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tag/core/config/app_config.dart';
import 'package:tag/features/beta_feedback/index.dart';

void main() {
  test('builds a private payload without public attachment URLs', () async {
    final temp = await File(
      '${Directory.systemTemp.path}/tag_beta_payload.png',
    ).writeAsBytes([1, 2, 3]);
    addTearDown(() async {
      if (await temp.exists()) {
        await temp.delete();
      }
    });

    final dataSource = SupabaseBetaFeedbackDataSource(
      appConfig: AppConfig(
        betaFeedbackEnabled: true,
        betaFeedbackEndpoint:
            'https://example.supabase.co/functions/v1/submit-beta-report',
        betaFeedbackAnonKey: 'anon-key',
      ),
    );

    final payload = await dataSource.buildPayload(
      draft: BetaFeedbackReportDraft(
        summary: 'Blank source preview',
        happened: 'The source preview was empty.',
        expected: 'The imported screenshot should be visible.',
        steps: 'Import screenshot, open card, open source.',
        area: BetaFeedbackArea.sourceEvidence,
        consentPrivateReview: true,
        contactEmail: ' beta@example.com ',
        attachments: [
          BetaFeedbackAttachment(
            path: temp.path,
            fileName: 'screenshot.png',
            contentType: 'image/png',
            byteSize: 3,
          ),
        ],
      ),
      diagnostics: const BetaFeedbackDiagnostics(
        appVersion: '1.0.0',
        buildNumber: '1',
        commitSha: 'local',
        deviceModel: 'iOS device',
        osVersion: 'iOS 26',
        currentSurface: 'settings/beta-feedback',
        generatedAtIso8601: '2026-05-19T00:00:00Z',
      ),
    );

    expect(payload['area'], 'Source evidence');
    expect(payload['contact_email'], 'beta@example.com');
    expect(payload.toString(), isNot(contains('storage_path')));
    expect(payload.toString(), isNot(contains('signedUrl')));

    final attachments = payload['attachments']! as List<Map<String, Object?>>;
    expect(attachments, hasLength(1));
    expect(attachments.single['content_type'], 'image/png');
    expect(attachments.single['base64_data'], isNotEmpty);
  });
}
