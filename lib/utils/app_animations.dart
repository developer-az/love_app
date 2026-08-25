import 'package:flutter/material.dart';

/// Motion tokens. Only opacity and transform are animated so work stays on
/// the compositor. Whole-page fades are used instead of sliding text, which
/// previously ghosted labels on Safari.
class AppAnimations {
  AppAnimations._();

  static const Duration instant = Duration.zero;
  static const Duration press = Duration(milliseconds: 90);
  static const Duration fast = Duration(milliseconds: 160);
  static const Duration medium = Duration(milliseconds: 220);
  static const Duration page = Duration(milliseconds: 240);
  static const Duration pageReverse = Duration(milliseconds: 180);

  static const Curve inCurve = Curves.easeOutCubic;
  static const Curve outCurve = Curves.easeInCubic;

  static bool reduceMotion(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);

  static Duration of(BuildContext context, Duration duration) {
    return reduceMotion(context) ? instant : duration;
  }

  static Widget fade(
    Widget child,
    Animation<double> animation,
  ) {
    return FadeTransition(opacity: animation, child: child);
  }
}

class FadePageTransitionsBuilder extends PageTransitionsBuilder {
  const FadePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (AppAnimations.reduceMotion(context)) return child;
    final curved = CurvedAnimation(
      parent: animation,
      curve: AppAnimations.inCurve,
      reverseCurve: AppAnimations.outCurve,
    );
    return FadeTransition(opacity: curved, child: child);
  }
}

Route<T> fadeRoute<T extends Object?>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: AppAnimations.page,
    reverseTransitionDuration: AppAnimations.pageReverse,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (AppAnimations.reduceMotion(context)) return child;
      final curved = CurvedAnimation(
        parent: animation,
        curve: AppAnimations.inCurve,
        reverseCurve: AppAnimations.outCurve,
      );
      return FadeTransition(opacity: curved, child: child);
    },
  );
}
