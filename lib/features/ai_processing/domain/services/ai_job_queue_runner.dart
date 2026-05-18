abstract interface class AiJobQueueRunner {
  bool get isProcessing;

  void start();

  void stop();

  void requestProcessing();

  Future<void> drain();
}
