class AiSchemaValidationException implements Exception {
  const AiSchemaValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}
