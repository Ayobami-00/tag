import 'package:tag/core/DI/di.dart';
import 'package:tag/core/local_storage/database/tag_database.dart';
import 'package:tag/features/cards/domain/use_cases/store_feedback_event.dart';
import 'package:tag/features/spaces/data/data_sources/spaces_local_data_source.dart';
import 'package:tag/features/spaces/data/repositories/spaces_repository_impl.dart';
import 'package:tag/features/spaces/domain/repositories/spaces_repository.dart';
import 'package:tag/features/spaces/domain/use_cases/get_space_detail.dart';
import 'package:tag/features/spaces/domain/use_cases/record_space_view.dart';
import 'package:tag/features/spaces/domain/use_cases/watch_space_summaries.dart';
import 'package:tag/features/spaces/presentation/logic/space_detail_cubit.dart';
import 'package:tag/features/spaces/presentation/logic/spaces_cubit.dart';

void setUpSpacesDependencies() {
  if (!locator.isRegistered<SpacesLocalDataSource>()) {
    locator.registerLazySingleton<SpacesLocalDataSource>(
      () => DriftSpacesLocalDataSource(locator<TagDatabase>()),
    );
  }

  if (!locator.isRegistered<SpacesRepository>()) {
    locator.registerLazySingleton<SpacesRepository>(
      () => SpacesRepositoryImpl(
        localDataSource: locator<SpacesLocalDataSource>(),
      ),
    );
  }

  if (!locator.isRegistered<WatchSpaceSummaries>()) {
    locator.registerLazySingleton(
      () => WatchSpaceSummaries(locator<SpacesRepository>()),
    );
  }

  if (!locator.isRegistered<GetSpaceDetail>()) {
    locator.registerLazySingleton(
      () => GetSpaceDetail(locator<SpacesRepository>()),
    );
  }

  if (!locator.isRegistered<RecordSpaceView>()) {
    locator.registerLazySingleton(
      () => RecordSpaceView(locator<StoreFeedbackEvent>()),
    );
  }

  if (!locator.isRegistered<SpacesCubit>()) {
    locator.registerFactory(
      () => SpacesCubit(
        watchSpaceSummaries: locator<WatchSpaceSummaries>(),
        recordSpaceView: locator<RecordSpaceView>(),
      ),
    );
  }

  if (!locator.isRegistered<SpaceDetailCubit>()) {
    locator.registerFactory(
      () => SpaceDetailCubit(getSpaceDetail: locator<GetSpaceDetail>()),
    );
  }
}
