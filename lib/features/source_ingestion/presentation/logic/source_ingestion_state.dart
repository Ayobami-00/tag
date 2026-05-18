part of 'source_ingestion_cubit.dart';

enum SourceIngestionStatus { initial, loading, ready, saving, saved, failure }

class SourceIngestionState extends Equatable {
  const SourceIngestionState({
    this.status = SourceIngestionStatus.initial,
    this.recentSources = const [],
    this.lastSavedSource,
    this.actionMessage = '',
    this.errorMessage = '',
  });

  final SourceIngestionStatus status;
  final List<SourceItemEntity> recentSources;
  final SourceItemEntity? lastSavedSource;
  final String actionMessage;
  final String errorMessage;

  bool get isSaving => status == SourceIngestionStatus.saving;

  SourceIngestionState copyWith({
    SourceIngestionStatus? status,
    List<SourceItemEntity>? recentSources,
    Object? lastSavedSource = _sourceSentinel,
    String? actionMessage,
    String? errorMessage,
  }) {
    return SourceIngestionState(
      status: status ?? this.status,
      recentSources: recentSources ?? this.recentSources,
      lastSavedSource: identical(lastSavedSource, _sourceSentinel)
          ? this.lastSavedSource
          : lastSavedSource as SourceItemEntity?,
      actionMessage: actionMessage ?? this.actionMessage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    recentSources,
    lastSavedSource,
    actionMessage,
    errorMessage,
  ];
}

const Object _sourceSentinel = Object();
