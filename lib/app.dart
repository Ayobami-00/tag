import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tag/core/index.dart';
import 'package:tag/features/source_ingestion/index.dart';
import 'package:tag/utils/index.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  bool _isImportingPendingShares = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _importPendingShares();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _importPendingShares();
    }
  }

  void _importPendingShares() {
    if (_isImportingPendingShares ||
        !locator.isRegistered<ImportPendingSharedSources>()) {
      return;
    }

    _isImportingPendingShares = true;
    unawaited(
      locator<ImportPendingSharedSources>()
          .call(const NoParams())
          .catchError((Object _) => const <SourceItemEntity>[])
          .whenComplete(() {
            _isImportingPendingShares = false;
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppCubit>(
      create: (_) => locator<AppCubit>()..start(),
      child: BlocListener<AppCubit, AppState>(
        listenWhen: (previous, current) =>
            previous.status != current.status &&
            current.status == AppStartupStatus.ready,
        listener: (context, state) {
          final currentPath = router.routeInformationProvider.value.uri.path;
          if (currentPath == splashPath || currentPath == '/') {
            router.go(state.initialLocation);
          }
        },
        child: MaterialApp.router(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: TagTheme.lightTheme,
          darkTheme: TagTheme.darkTheme,
          themeMode: ThemeMode.system,
          routerConfig: router,
        ),
      ),
    );
  }
}
