import 'package:uuid/uuid.dart';

typedef SourceIdFactory = String Function();

String defaultSourceIdFactory() {
  return 'src_${const Uuid().v4()}';
}
