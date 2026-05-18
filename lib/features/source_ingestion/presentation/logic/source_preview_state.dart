part of 'source_preview_cubit.dart';

enum SourcePreviewStatus { initial, loading, ready, notFound, error }

class SourcePreviewState extends Equatable {
  const SourcePreviewState({
    this.status = SourcePreviewStatus.initial,
    this.preview,
    this.focusCardId,
    this.focusedSpaceId,
    this.errorMessage = '',
  });

  final SourcePreviewStatus status;
  final SourcePreviewEntity? preview;
  final String? focusCardId;
  final String? focusedSpaceId;
  final String errorMessage;

  bool get isLoading =>
      status == SourcePreviewStatus.initial ||
      status == SourcePreviewStatus.loading;

  SourcePreviewRelatedCardEntity? get focusedCard {
    return preview?.relatedCardFor(focusCardId);
  }

  List<SourcePreviewRelatedCardEntity> get visibleRelatedCards {
    final cards = preview?.relatedCards ?? const [];
    final selectedSpaceId = focusedSpaceId;
    if (selectedSpaceId == null || selectedSpaceId.isEmpty) {
      return cards;
    }

    return cards
        .where((card) => card.space.id == selectedSpaceId)
        .toList(growable: false);
  }

  SourcePreviewState copyWith({
    SourcePreviewStatus? status,
    SourcePreviewEntity? preview,
    String? focusCardId,
    String? focusedSpaceId,
    String? errorMessage,
  }) {
    return SourcePreviewState(
      status: status ?? this.status,
      preview: preview ?? this.preview,
      focusCardId: focusCardId ?? this.focusCardId,
      focusedSpaceId: focusedSpaceId ?? this.focusedSpaceId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    preview,
    focusCardId,
    focusedSpaceId,
    errorMessage,
  ];
}
