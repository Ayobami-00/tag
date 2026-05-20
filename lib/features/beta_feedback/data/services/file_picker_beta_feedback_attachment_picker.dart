import 'package:file_picker/file_picker.dart';
import 'package:tag/features/beta_feedback/domain/entities/beta_feedback_entities.dart';
import 'package:tag/features/beta_feedback/domain/services/beta_feedback_attachment_picker.dart';

class FilePickerBetaFeedbackAttachmentPicker
    implements BetaFeedbackAttachmentPicker {
  const FilePickerBetaFeedbackAttachmentPicker();

  @override
  Future<BetaFeedbackAttachment?> pickScreenshot() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: false,
      allowMultiple: false,
    );
    final pickedFile = result == null || result.files.isEmpty
        ? null
        : result.files.single;
    final path = pickedFile?.path;

    if (pickedFile == null || path == null || path.trim().isEmpty) {
      return null;
    }

    return BetaFeedbackAttachment(
      path: path,
      fileName: pickedFile.name,
      contentType: _contentTypeFor(pickedFile.extension),
      byteSize: pickedFile.size,
    );
  }

  String _contentTypeFor(String? extension) {
    return switch (extension?.toLowerCase()) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'webp' => 'image/webp',
      'heic' => 'image/heic',
      _ => 'image/png',
    };
  }
}
