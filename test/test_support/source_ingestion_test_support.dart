import 'package:tag/core/DI/di.dart';
import 'package:tag/features/source_ingestion/index.dart';

Future<void> registerStableSourceIngestionCubitForWidgetTests() async {
  if (locator.isRegistered<SourceIngestionCubit>()) {
    await locator.unregister<SourceIngestionCubit>();
  }

  locator.registerFactory(
    () => SourceIngestionCubit(
      importImageSource: locator<ImportImageSource>(),
      createTextSource: locator<CreateTextSource>(),
      watchRecentSources: _StableWatchRecentSources(
        locator<SourceRepository>(),
      ),
    ),
  );
}

class _StableWatchRecentSources extends WatchRecentSources {
  const _StableWatchRecentSources(super.sourceRepository);

  @override
  Stream<List<SourceItemEntity>> call(WatchRecentSourcesParams params) {
    return Stream<List<SourceItemEntity>>.value(const []);
  }
}
