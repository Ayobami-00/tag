import 'package:tag/core/ai/rag/local_rag_service.dart';
import 'package:tag/core/ai/rag/rag_models.dart';
import 'package:tag/core/use_cases/use_cases.dart';

class GetRagIndexStatus with UseCases<LocalRagIndexStatus, NoParams> {
  const GetRagIndexStatus(this._localRagService);

  final LocalRagService _localRagService;

  @override
  Future<LocalRagIndexStatus> call(NoParams params) {
    return _localRagService.getIndexStatus();
  }
}
