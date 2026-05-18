import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TagPageRoutes {
  const TagPageRoutes._();

  static Page<void> withoutAnimation({required Widget child, String? name}) {
    return NoTransitionPage<void>(name: name, child: child);
  }
}
