import 'package:tag/core/DI/di.dart';
import 'package:tag/core/ai/rag/local_rag_service.dart';
import 'package:tag/core/ai/rag/local_rag_service_impl.dart';
import 'package:tag/core/ai/rag/local_vector_index.dart';
import 'package:tag/core/ai/rag/source_chunker.dart';
import 'package:tag/core/local_storage/database/data_sources/rag_local_data_source.dart';
import 'package:tag/core/local_storage/database/tag_database.dart';
import 'package:tag/core/local_storage/file_store/local_file_store.dart';
import 'package:tag/core/ai/cactus/cactus_model_service.dart';
import 'package:tag/features/model_setup/domain/repositories/model_setup_repository.dart';
import 'package:tag/features/rag/domain/use_cases/get_rag_index_status.dart';
import 'package:tag/features/rag/domain/use_cases/search_saved_context.dart';
import 'package:tag/features/rag/presentation/logic/rag_debug_cubit.dart';

void setUpRagDependencies() {
  if (!locator.isRegistered<RagLocalDataSource>()) {
    locator.registerLazySingleton<RagLocalDataSource>(
      () => DriftRagLocalDataSource(locator<TagDatabase>()),
    );
  }

  if (!locator.isRegistered<SourceChunker>()) {
    locator.registerLazySingleton(SourceChunker.new);
  }

  if (!locator.isRegistered<LocalVectorIndex>()) {
    locator.registerLazySingleton<LocalVectorIndex>(CactusLocalVectorIndex.new);
  }

  if (!locator.isRegistered<LocalRagService>()) {
    locator.registerLazySingleton<LocalRagService>(
      () => LocalRagServiceImpl(
        cactusModelService: locator<CactusModelService>(),
        localDataSource: locator<RagLocalDataSource>(),
        localFileStore: locator<LocalFileStore>(),
        vectorIndex: locator<LocalVectorIndex>(),
        sourceChunker: locator<SourceChunker>(),
        embeddingModelSlugProvider: locator.isRegistered<ModelSetupRepository>()
            ? () => locator<ModelSetupRepository>()
                  .loadSelectedEmbeddingModelSlug()
            : null,
      ),
    );
  }

  if (!locator.isRegistered<GetRagIndexStatus>()) {
    locator.registerLazySingleton(
      () => GetRagIndexStatus(locator<LocalRagService>()),
    );
  }

  if (!locator.isRegistered<SearchSavedContext>()) {
    locator.registerLazySingleton(
      () => SearchSavedContext(locator<LocalRagService>()),
    );
  }

  if (!locator.isRegistered<RagDebugCubit>()) {
    locator.registerFactory(
      () => RagDebugCubit(
        getRagIndexStatus: locator<GetRagIndexStatus>(),
        searchSavedContext: locator<SearchSavedContext>(),
      ),
    );
  }
}
