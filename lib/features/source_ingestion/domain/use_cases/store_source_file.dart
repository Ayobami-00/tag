import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:tag/core/local_storage/file_store/local_file_store.dart';
import 'package:tag/core/use_cases/use_cases.dart';

enum StoreSourceFileKind { image, text }

class StoreSourceFileParams extends Equatable {
  const StoreSourceFileParams.image({
    required this.sourceId,
    required File this.sourceFile,
    this.extension,
  }) : kind = StoreSourceFileKind.image,
       text = null;

  const StoreSourceFileParams.text({
    required this.sourceId,
    required String this.text,
  }) : kind = StoreSourceFileKind.text,
       sourceFile = null,
       extension = null;

  final StoreSourceFileKind kind;
  final String sourceId;
  final File? sourceFile;
  final String? text;
  final String? extension;

  @override
  List<Object?> get props => [
    kind,
    sourceId,
    sourceFile?.path,
    text,
    extension,
  ];
}

class StoreSourceFile with UseCases<String, StoreSourceFileParams> {
  const StoreSourceFile(this._localFileStore);

  final LocalFileStore _localFileStore;

  @override
  Future<String> call(StoreSourceFileParams params) {
    return switch (params.kind) {
      StoreSourceFileKind.image => _localFileStore.copyImageSource(
        sourceId: params.sourceId,
        sourceFile: params.sourceFile!,
        extension: params.extension,
      ),
      StoreSourceFileKind.text => _localFileStore.writeTextSource(
        sourceId: params.sourceId,
        text: params.text!,
      ),
    };
  }
}
