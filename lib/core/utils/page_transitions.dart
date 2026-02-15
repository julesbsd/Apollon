import 'package:flutter/material.dart';

/// Transitions de page fluides réutilisables pour l'application Apollon
/// 
/// Usage:
/// ```dart
/// Navigator.push(
///   context,
///   AppPageRoute.slideUp(builder: (context) => MyScreen()),
/// );
/// ```
class AppPageRoute {
  AppPageRoute._();

  /// Transition slide from bottom (recommandé pour modals et nouvelles actions)
  static PageRouteBuilder<T> slideUp<T>({
    required WidgetBuilder builder,
    Duration duration = const Duration(milliseconds: 350),
    Curve curve = Curves.easeOutCubic,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        final offsetAnimation = animation.drive(tween);
        
        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  /// Transition slide from right (navigation standard)
  static PageRouteBuilder<T> slideRight<T>({
    required WidgetBuilder builder,
    Duration duration = const Duration(milliseconds: 350),
    Curve curve = Curves.easeOutCubic,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        final offsetAnimation = animation.drive(tween);
        
        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  /// Transition fade (navigation douce)
  static PageRouteBuilder<T> fade<T>({
    required WidgetBuilder builder,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation.drive(CurveTween(curve: curve)),
          child: child,
        );
      },
    );
  }

  /// Transition scale (pour dialogs ou focus)
  static PageRouteBuilder<T> scale<T>({
    required WidgetBuilder builder,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOutCubic,
    Alignment alignment = Alignment.center,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: animation.drive(
            Tween(begin: 0.8, end: 1.0).chain(CurveTween(curve: curve)),
          ),
          alignment: alignment,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  /// Transition combinée fade + slide (fluide et élégante) - Premium version
  static PageRouteBuilder<T> fadeSlide<T>({
    required WidgetBuilder builder,
    Duration duration = const Duration(milliseconds: 400),
    Curve curve = Curves.easeInOutCubic,
    Offset beginOffset = const Offset(0.0, 0.03),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Animation combinée plus fluide
        final slideAnimation = Tween(
          begin: beginOffset,
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: curve,
        ));

        final fadeAnimation = Tween(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Interval(0.0, 0.7, curve: curve), // Fade plus rapide
        ));
        
        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
    );
  }
}

/// Extension pour simplifier l'utilisation avec Navigator
extension NavigatorTransitionExtension on NavigatorState {
  /// Push avec transition fluide (fadeSlide par défaut)
  Future<T?> pushWithTransition<T>(
    WidgetBuilder builder, {
    AppPageTransitionType type = AppPageTransitionType.fadeSlide,
  }) {
    final route = _getRouteForType<T>(builder, type);
    return push(route);
  }

  /// Replace avec transition fluide
  Future<T?> pushReplacementWithTransition<T, TO>(
    WidgetBuilder builder, {
    AppPageTransitionType type = AppPageTransitionType.fadeSlide,
    TO? result,
  }) {
    final route = _getRouteForType<T>(builder, type);
    return pushReplacement(route, result: result);
  }

  PageRouteBuilder<T> _getRouteForType<T>(
    WidgetBuilder builder,
    AppPageTransitionType type,
  ) {
    switch (type) {
      case AppPageTransitionType.slideUp:
        return AppPageRoute.slideUp<T>(builder: builder);
      case AppPageTransitionType.slideRight:
        return AppPageRoute.slideRight<T>(builder: builder);
      case AppPageTransitionType.fade:
        return AppPageRoute.fade<T>(builder: builder);
      case AppPageTransitionType.scale:
        return AppPageRoute.scale<T>(builder: builder);
      case AppPageTransitionType.fadeSlide:
        return AppPageRoute.fadeSlide<T>(builder: builder);
    }
  }
}

/// Types de transitions disponibles
enum AppPageTransitionType {
  slideUp,
  slideRight,
  fade,
  scale,
  fadeSlide,
}
