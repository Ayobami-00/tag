import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tag/core/DI/di.dart';
import 'package:tag/core/config/app_config.dart';
import 'package:tag/core/local_storage/database/tag_database.dart';
import 'package:tag/core/local_storage/file_store/local_file_store_impl.dart';
import 'package:tag/core/navigation/route_constants.dart';
import 'package:tag/core/startup/app_cubit.dart';
import 'package:tag/features/beta_feedback/presentation/screens/beta_feedback_screen.dart';
import 'package:tag/features/today/presentation/screens/today_screen.dart';
import 'package:tag/utils/theme/tag_theme.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDirectory;

  setUp(() async {
    await locator.reset();
    tempDirectory = await Directory.systemTemp.createTemp(
      'tag_beta_feedback_icon_e2e_',
    );
    setUpAppLocator(
      appConfig: AppConfig(
        betaFeedbackEnabled: true,
        autoDownloadRequiredModels: false,
      ),
      tagDatabase: TagDatabase.forTesting(NativeDatabase.memory()),
      localFileStore: LocalFileStoreImpl(
        appDocumentsDirectoryProvider: () async => tempDirectory,
      ),
    );
  });

  tearDown(() async {
    await locator.reset();
    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  testWidgets('opens beta feedback from the Today app bar icon', (
    tester,
  ) async {
    final appCubit = locator<AppCubit>();
    addTearDown(appCubit.close);
    await appCubit.start();

    final router = GoRouter(
      initialLocation: todayPath,
      routes: [
        GoRoute(path: todayPath, builder: (_, __) => const TodayScreen()),
        GoRoute(
          path: betaFeedbackPath,
          builder: (_, __) => const BetaFeedbackScreen(),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      BlocProvider.value(
        value: appCubit,
        child: MaterialApp.router(
          theme: TagTheme.lightTheme,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('Beta feedback'), findsOneWidget);

    await tester.tap(find.byTooltip('Beta feedback'));
    await tester.pumpAndSettle();

    expect(router.canPop(), isTrue);
    expect(find.text('Beta feedback'), findsOneWidget);
    expect(find.text('Private beta report'), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, todayPath);
  });
}
