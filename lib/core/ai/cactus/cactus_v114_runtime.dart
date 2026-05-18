import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:tag/core/ai/cactus/cactus_model_registry.dart';
import 'package:tag/core/ai/cactus/cactus_model_service.dart';
import 'package:tag/core/ai/cactus/v114/cactus_v114.dart'
    deferred as cactus
    hide Utf8Pointer, Utf8PointerExtension;
import 'package:tag/core/error/app_error.dart';

class CactusV114Runtime {
  CactusV114Runtime();

  final Set<String> _initializedSlugs = {};
  final _CactusV114WorkerClient _worker = _CactusV114WorkerClient();

  bool isInitialized(String slug) {
    return _initializedSlugs.contains(slug);
  }

  Future<void> initializeModel({
    required String slug,
    required String modelPath,
  }) async {
    if (_initializedSlugs.contains(slug)) {
      return;
    }

    try {
      await _worker.request('initialize', {
        'slug': slug,
        'modelPath': modelPath,
      });
      _initializedSlugs.add(slug);
    } on Object catch (error) {
      throw AppError(
        CactusModelRegistry.directDownloadInitializationMessage(slug) ??
            'Cactus v1.14 model initialization failed for $slug.',
        cause: error,
      );
    }
  }

  Future<void> unloadModel(String slug) async {
    if (!_initializedSlugs.remove(slug)) {
      return;
    }

    await _worker.request('unload', {'slug': slug});
  }

  Future<AiCompletionResult> complete({
    required String modelSlug,
    required List<AiChatMessage> messages,
    required List<AiToolSchema> tools,
    required AiCompletionOptions options,
    void Function(String token)? onToken,
  }) async {
    if (!_initializedSlugs.contains(modelSlug)) {
      throw AppError('Cactus v1.14 model $modelSlug is not initialized.');
    }

    final rawResult = await _worker.request<String>('complete', {
      'slug': modelSlug,
      'messagesJson': jsonEncode(_messagesJson(messages)),
      'optionsJson': jsonEncode(_optionsJson(options)),
      'toolsJson': tools.isEmpty ? null : jsonEncode(_toolsJson(tools)),
    }, onToken: onToken);

    return _completionResultFromJson(modelSlug, rawResult);
  }

  Future<AiEmbeddingResult> embedText({
    required String modelSlug,
    required String text,
  }) async {
    if (!_initializedSlugs.contains(modelSlug)) {
      throw AppError('Cactus v1.14 model $modelSlug is not initialized.');
    }

    final configuredDimension = CactusModelRegistry.embeddingConfigForSlug(
      modelSlug,
    ).dimension;
    final rawValues = await _worker.request<List<Object?>>('embed', {
      'slug': modelSlug,
      'text': text,
      'dimension': configuredDimension,
    });
    final values = rawValues
        .whereType<num>()
        .map((value) => value.toDouble())
        .toList(growable: false);

    return AiEmbeddingResult(
      modelSlug: modelSlug,
      embeddings: values,
      dimension: values.length,
    );
  }

  List<Map<String, Object>> _messagesJson(List<AiChatMessage> messages) {
    return messages
        .map((message) {
          return <String, Object>{
            'role': message.role,
            'content': message.content,
            if (message.imagePaths.isNotEmpty) 'images': message.imagePaths,
          };
        })
        .toList(growable: false);
  }

  Map<String, Object> _optionsJson(AiCompletionOptions options) {
    return {
      'max_tokens': options.maxTokens,
      'auto_handoff': false,
      'telemetry_enabled': false,
      if (options.temperature != null) 'temperature': options.temperature!,
      if (options.topK != null) 'top_k': options.topK!,
      if (options.topP != null) 'top_p': options.topP!,
      if (options.stopSequences.isNotEmpty)
        'stop_sequences': options.stopSequences,
      if (options.forceTools != null) 'force_tools': options.forceTools!,
    };
  }

  List<Map<String, Object>> _toolsJson(List<AiToolSchema> tools) {
    return tools
        .map((tool) {
          final requiredParameters = tool.parameters.entries
              .where((entry) => entry.value.isRequired)
              .map((entry) => entry.key)
              .toList(growable: false);

          return <String, Object>{
            'type': 'function',
            'function': <String, Object>{
              'name': tool.name,
              'description': tool.description,
              'parameters': <String, Object>{
                'type': 'object',
                'properties': tool.parameters.map((name, parameter) {
                  return MapEntry(name, <String, Object>{
                    'type': parameter.type,
                    'description': parameter.description,
                  });
                }),
                if (requiredParameters.isNotEmpty)
                  'required': requiredParameters,
              },
            },
          };
        })
        .toList(growable: false);
  }

  AiCompletionResult _completionResultFromJson(
    String modelSlug,
    String rawResult,
  ) {
    Object? decoded;
    try {
      decoded = jsonDecode(rawResult);
    } on FormatException {
      return AiCompletionResult(response: rawResult, rawResult: rawResult);
    }

    if (decoded is! Map<String, dynamic>) {
      return AiCompletionResult(
        response: decoded?.toString() ?? '',
        rawResult: decoded,
      );
    }

    return AiCompletionResult(
      response:
          _stringValue(decoded, 'response') ??
          _stringValue(decoded, 'text') ??
          _stringValue(decoded, 'content') ??
          '',
      toolCalls: _toolCallsFromJson(decoded['tool_calls']),
      timeToFirstTokenMs:
          _doubleValue(decoded, 'time_to_first_token_ms') ??
          _doubleValue(decoded, 'timeToFirstTokenMs') ??
          0,
      totalTimeMs:
          _doubleValue(decoded, 'total_time_ms') ??
          _doubleValue(decoded, 'totalTimeMs') ??
          0,
      tokensPerSecond:
          _doubleValue(decoded, 'tokens_per_second') ??
          _doubleValue(decoded, 'tokensPerSecond') ??
          0,
      prefillTokens:
          _intValue(decoded, 'prefill_tokens') ??
          _intValue(decoded, 'prefillTokens') ??
          0,
      decodeTokens:
          _intValue(decoded, 'decode_tokens') ??
          _intValue(decoded, 'decodeTokens') ??
          0,
      totalTokens:
          _intValue(decoded, 'total_tokens') ??
          _intValue(decoded, 'totalTokens') ??
          0,
      rawResult: decoded..putIfAbsent('model_slug', () => modelSlug),
    );
  }

  List<AiToolCall> _toolCallsFromJson(Object? rawToolCalls) {
    if (rawToolCalls is! List) {
      return const [];
    }

    return rawToolCalls
        .whereType<Map>()
        .map((rawToolCall) {
          final function = rawToolCall['function'];
          final functionMap = function is Map ? function : rawToolCall;
          final name =
              functionMap['name']?.toString() ??
              rawToolCall['name']?.toString() ??
              '';
          final arguments = _toolArguments(functionMap['arguments']);

          return AiToolCall(name: name, arguments: arguments);
        })
        .where((toolCall) {
          return toolCall.name.isNotEmpty;
        })
        .toList(growable: false);
  }

  Map<String, String> _toolArguments(Object? rawArguments) {
    if (rawArguments is String) {
      try {
        final decoded = jsonDecode(rawArguments);
        if (decoded is Map) {
          return decoded.map((key, value) {
            return MapEntry(key.toString(), value.toString());
          });
        }
      } on FormatException {
        return {'arguments': rawArguments};
      }
    }

    if (rawArguments is Map) {
      return rawArguments.map((key, value) {
        return MapEntry(key.toString(), value.toString());
      });
    }

    return const {};
  }

  String? _stringValue(Map<String, dynamic> json, String key) {
    final value = json[key];
    return value is String ? value : value?.toString();
  }

  double? _doubleValue(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '');
  }

  int? _intValue(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '');
  }
}

class _CactusV114WorkerClient {
  final Map<int, Completer<Object?>> _pending = {};
  final Map<int, void Function(String token)> _tokenHandlers = {};
  Future<SendPort>? _sendPortFuture;
  int _nextRequestId = 0;

  Future<T> request<T>(
    String operation,
    Map<String, Object?> payload, {
    void Function(String token)? onToken,
  }) async {
    final sendPort = await _ensureStarted();
    final id = _nextRequestId++;
    final completer = Completer<Object?>();
    _pending[id] = completer;
    if (onToken != null) {
      _tokenHandlers[id] = onToken;
    }

    sendPort.send({'id': id, 'operation': operation, ...payload});

    try {
      final value = await completer.future;
      return value as T;
    } finally {
      _pending.remove(id);
      _tokenHandlers.remove(id);
    }
  }

  Future<SendPort> _ensureStarted() {
    return _sendPortFuture ??= _startWorker();
  }

  Future<SendPort> _startWorker() async {
    final receivePort = ReceivePort();
    final sendPortCompleter = Completer<SendPort>();

    receivePort.listen((message) {
      if (message is SendPort && !sendPortCompleter.isCompleted) {
        sendPortCompleter.complete(message);
        return;
      }

      _handleMessage(message);
    });

    await Isolate.spawn(
      _cactusV114WorkerMain,
      receivePort.sendPort,
      debugName: 'tag_cactus_v114_worker',
    );

    return sendPortCompleter.future;
  }

  void _handleMessage(Object? message) {
    if (message is! Map) {
      return;
    }

    final id = message['id'];
    if (id is! int) {
      return;
    }

    final type = message['type'];
    if (type == 'token') {
      final token = message['value'];
      if (token is String) {
        _tokenHandlers[id]?.call(token);
      }
      return;
    }

    final completer = _pending[id];
    if (completer == null || completer.isCompleted) {
      return;
    }

    if (type == 'error') {
      completer.completeError(
        AppError(
          message['message']?.toString() ??
              'Cactus v1.14 worker operation failed.',
          cause: message['stack']?.toString(),
        ),
      );
      return;
    }

    completer.complete(message['value']);
  }
}

@pragma('vm:entry-point')
void _cactusV114WorkerMain(SendPort mainSendPort) {
  final receivePort = ReceivePort();
  final worker = _CactusV114Worker(mainSendPort);
  mainSendPort.send(receivePort.sendPort);
  receivePort.listen(worker.handle);
}

class _CactusV114Worker {
  _CactusV114Worker(this._mainSendPort);

  final SendPort _mainSendPort;
  final Map<String, dynamic> _handlesBySlug = {};
  Future<void>? _bindingsLoad;
  Future<void> _lastOperation = Future<void>.value();

  void handle(Object? message) {
    _lastOperation = _lastOperation.then((_) => _handle(message));
  }

  Future<void> _handle(Object? message) async {
    if (message is! Map) {
      return;
    }

    final id = message['id'];
    final operation = message['operation'];
    if (id is! int || operation is! String) {
      return;
    }

    try {
      Object? value;
      switch (operation) {
        case 'initialize':
          await _initialize(message);
        case 'unload':
          await _unload(message);
        case 'complete':
          value = await _complete(id, message);
        case 'embed':
          value = await _embed(message);
        default:
          throw StateError('Unknown Cactus worker operation: $operation');
      }

      _mainSendPort.send({'id': id, 'type': 'result', 'value': value});
    } on Object catch (error, stackTrace) {
      _mainSendPort.send({
        'id': id,
        'type': 'error',
        'message': error.toString(),
        'stack': stackTrace.toString(),
      });
    }
  }

  Future<void> _initialize(Map<dynamic, dynamic> message) async {
    final slug = message['slug']?.toString() ?? '';
    final modelPath = message['modelPath']?.toString() ?? '';
    if (slug.isEmpty || modelPath.isEmpty) {
      throw StateError('Cactus worker initialize request was incomplete.');
    }
    if (_handlesBySlug.containsKey(slug)) {
      return;
    }

    await _loadBindings();
    _handlesBySlug[slug] = cactus.cactusInit(modelPath, null, false);
  }

  Future<void> _unload(Map<dynamic, dynamic> message) async {
    final slug = message['slug']?.toString() ?? '';
    final handle = _handlesBySlug.remove(slug);
    if (handle == null) {
      return;
    }

    await _loadBindings();
    cactus.cactusDestroy(handle);
  }

  Future<String> _complete(int id, Map<dynamic, dynamic> message) async {
    final slug = message['slug']?.toString() ?? '';
    final handle = _handlesBySlug[slug];
    if (handle == null) {
      throw StateError('Cactus v1.14 model $slug is not initialized.');
    }

    await _loadBindings();
    return cactus.cactusComplete(
      handle,
      message['messagesJson']?.toString() ?? '[]',
      message['optionsJson']?.toString() ?? '{}',
      message['toolsJson'] as String?,
      (token, _) {
        _mainSendPort.send({'id': id, 'type': 'token', 'value': token});
      },
    );
  }

  Future<List<double>> _embed(Map<dynamic, dynamic> message) async {
    final slug = message['slug']?.toString() ?? '';
    final handle = _handlesBySlug[slug];
    if (handle == null) {
      throw StateError('Cactus v1.14 model $slug is not initialized.');
    }

    await _loadBindings();
    final dimension = message['dimension'] is int
        ? message['dimension'] as int
        : int.tryParse(message['dimension']?.toString() ?? '') ?? 0;
    final embeddings = cactus.cactusEmbed(
      handle,
      message['text']?.toString() ?? '',
      true,
    );

    return embeddings
        .take(dimension)
        .map((value) => value.toDouble())
        .toList(growable: false);
  }

  Future<void> _loadBindings() {
    return _bindingsLoad ??= cactus.loadLibrary().then((_) {
      cactus.cactusLogSetLevel(3);
    });
  }
}
