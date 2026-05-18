import 'package:file_picker/file_picker.dart';
import 'package:tag/features/source_ingestion/domain/services/manual_source_picker.dart';

class FilePickerManualSourcePicker implements ManualSourcePicker {
  const FilePickerManualSourcePicker();

  @override
  Future<PickedImageSource?> pickImage() async {
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

    return PickedImageSource(
      path: path,
      originalUri: pickedFile.identifier,
      displayName: pickedFile.name,
      extension: pickedFile.extension,
      sizeBytes: pickedFile.size,
    );
  }
}
