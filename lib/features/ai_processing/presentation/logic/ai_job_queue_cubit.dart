import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/ai_processing/domain/entities/ai_processing_job_entity.dart';
import 'package:tag/features/ai_processing/domain/use_cases/cancel_ai_job.dart';
import 'package:tag/features/ai_processing/domain/use_cases/queue_debug_failing_ai_job.dart';
import 'package:tag/features/ai_processing/domain/use_cases/retry_ai_job.dart';
import 'package:tag/features/ai_processing/domain/use_cases/watch_ai_jobs.dart';

part 'ai_job_queue_state.dart';

class AiJobQueueCubit extends Cubit<AiJobQueueState> {
  AiJobQueueCubit({
    required WatchAiJobs watchAiJobs,
    required RetryAiJob retryAiJob,
    required CancelAiJob cancelAiJob,
    required QueueDebugFailingAiJob queueDebugFailingAiJob,
  }) : _watchAiJobs = watchAiJobs,
       _retryAiJob = retryAiJob,
       _cancelAiJob = cancelAiJob,
       _queueDebugFailingAiJob = queueDebugFailingAiJob,
       super(const AiJobQueueState());

  final WatchAiJobs _watchAiJobs;
  final RetryAiJob _retryAiJob;
  final CancelAiJob _cancelAiJob;
  final QueueDebugFailingAiJob _queueDebugFailingAiJob;
  StreamSubscription<List<AiProcessingJobEntity>>? _jobsSubscription;

  void load() {
    if (_jobsSubscription != null) {
      return;
    }

    emit(state.copyWith(status: AiJobQueueViewStatus.loading));
    _jobsSubscription = _watchAiJobs(const WatchAiJobsParams()).listen(
      _onJobsChanged,
      onError: (Object error) {
        if (isClosed) {
          return;
        }
        emit(
          state.copyWith(
            status: AiJobQueueViewStatus.failure,
            errorMessage: 'AI queue could not be loaded.',
          ),
        );
      },
    );
  }

  Future<void> retryJob(String jobId) async {
    emit(state.copyWith(actionMessage: '', errorMessage: ''));

    try {
      await _retryAiJob(RetryAiJobParams(jobId));
      emit(state.copyWith(actionMessage: 'Job queued for retry.'));
    } on Object {
      emit(state.copyWith(errorMessage: 'Job could not be retried.'));
    }
  }

  Future<void> cancelJob(String jobId) async {
    emit(state.copyWith(actionMessage: '', errorMessage: ''));

    try {
      await _cancelAiJob(CancelAiJobParams(jobId));
      emit(state.copyWith(actionMessage: 'Job cancelled.'));
    } on Object {
      emit(state.copyWith(errorMessage: 'Job could not be cancelled.'));
    }
  }

  Future<void> queueDebugFailure() async {
    emit(state.copyWith(actionMessage: '', errorMessage: ''));

    try {
      await _queueDebugFailingAiJob(const NoParams());
      emit(state.copyWith(actionMessage: 'Fake failing job queued.'));
    } on Object {
      emit(state.copyWith(errorMessage: 'Debug job could not be queued.'));
    }
  }

  void clearMessages() {
    if (state.actionMessage.isEmpty && state.errorMessage.isEmpty) {
      return;
    }

    emit(state.copyWith(actionMessage: '', errorMessage: ''));
  }

  void _onJobsChanged(List<AiProcessingJobEntity> jobs) {
    if (isClosed) {
      return;
    }

    emit(state.copyWith(status: AiJobQueueViewStatus.ready, jobs: jobs));
  }

  @override
  Future<void> close() async {
    await _jobsSubscription?.cancel();
    return super.close();
  }
}
