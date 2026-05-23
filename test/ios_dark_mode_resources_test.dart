import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('iOS dark appearance resources', () {
    test('provide adaptive launch background colors', () {
      final colorset = File(
        'ios/Runner/Assets.xcassets/LaunchBackground.colorset/Contents.json',
      );

      expect(colorset.existsSync(), isTrue);

      final contents =
          jsonDecode(colorset.readAsStringSync()) as Map<String, dynamic>;
      final colors = contents['colors'] as List<dynamic>;

      expect(colors, hasLength(2));
      expect(colors.any(_isDefaultColor), isTrue);
      expect(colors.any(_isDarkAppearanceColor), isTrue);
      expect(
        _componentValue(colors.firstWhere(_isDefaultColor), 'red'),
        '0xF8',
      );
      expect(
        _componentValue(colors.firstWhere(_isDarkAppearanceColor), 'red'),
        '0x0F',
      );
    });

    test('use the adaptive launch background in native storyboards', () {
      for (final path in [
        'ios/Runner/Base.lproj/LaunchScreen.storyboard',
        'ios/Runner/Base.lproj/Main.storyboard',
      ]) {
        final storyboard = File(path).readAsStringSync();

        expect(storyboard, contains('name="LaunchBackground"'));
        expect(
          storyboard,
          isNot(contains('<namedColor name="LaunchBackground"')),
        );
        expect(storyboard, isNot(contains('red="1" green="1" blue="1"')));
        expect(storyboard, isNot(contains('white="1" alpha="1"')));
      }
    });
  });
}

bool _isDefaultColor(dynamic entry) {
  final color = entry as Map<String, dynamic>;
  return color['appearances'] == null;
}

bool _isDarkAppearanceColor(dynamic entry) {
  final color = entry as Map<String, dynamic>;
  final appearances = color['appearances'] as List<dynamic>?;
  if (appearances == null) {
    return false;
  }

  return appearances.any((appearance) {
    final values = appearance as Map<String, dynamic>;
    return values['appearance'] == 'luminosity' && values['value'] == 'dark';
  });
}

String _componentValue(dynamic entry, String component) {
  final color = entry as Map<String, dynamic>;
  final colorValues = color['color'] as Map<String, dynamic>;
  final components = colorValues['components'] as Map<String, dynamic>;
  return components[component] as String;
}
