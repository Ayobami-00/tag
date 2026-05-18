import 'package:equatable/equatable.dart';

class PickedImageSource extends Equatable {
  const PickedImageSource({
    required this.path,
    this.originalUri,
    this.displayName,
    this.extension,
    this.sizeBytes,
  });

  final String path;
  final String? originalUri;
  final String? displayName;
  final String? extension;
  final int? sizeBytes;

  @override
  List<Object?> get props => [
    path,
    originalUri,
    displayName,
    extension,
    sizeBytes,
  ];
}

abstract interface class ManualSourcePicker {
  Future<PickedImageSource?> pickImage();
}
