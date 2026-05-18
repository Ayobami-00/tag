import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tag/core/presentation/top_signal_banner.dart';
import 'package:tag/utils/index.dart';

void main() {
  testWidgets('shows a top signal banner above app content', (tester) async {
    late BuildContext buttonContext;

    await tester.pumpWidget(
      MaterialApp(
        theme: TagTheme.lightTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) {
              buttonContext = context;
              return const Center(child: Text('Today content'));
            },
          ),
        ),
      ),
    );

    showTopSignalBanner(
      buttonContext,
      message: 'Completed "Buy bread".',
      icon: Icons.check_rounded,
      tone: TopSignalTone.success,
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Today content'), findsOneWidget);
    expect(find.text('Completed "Buy bread".'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });
}
