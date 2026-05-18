import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  BuildContext? get context => navigatorKey.currentContext;

  void goNamed(
    String routeName, {
    Object? extra,
    Map<String, String> pathParameters = const {},
    Map<String, dynamic> queryParameters = const {},
  }) {
    context?.goNamed(
      routeName,
      extra: extra,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
    );
  }

  Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? extra,
    Map<String, String> pathParameters = const {},
    Map<String, dynamic> queryParameters = const {},
  }) {
    return context?.pushNamed<T>(
          routeName,
          extra: extra,
          pathParameters: pathParameters,
          queryParameters: queryParameters,
        ) ??
        Future<T?>.value();
  }

  void pop<T extends Object?>([T? result]) {
    if (context?.canPop() ?? false) {
      context?.pop(result);
    }
  }
}
