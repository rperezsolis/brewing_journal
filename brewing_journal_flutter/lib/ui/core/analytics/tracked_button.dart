import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/services/analytics_service.dart';

/// Fires `button_tapped`, then calls [onPressed].
///
/// [buttonLabel] and [buttonAction] are stable ids, not translated captions,
/// so the same control stays one event in every locale. [currentScreen] is
/// the screen-name constant for the screen that owns the control.
///
/// [builder] receives the tracked callback and returns the real button, so
/// the same wrapper works for a filled button, an icon button, or a floating
/// action button. A null [onPressed] stays null and the button stays disabled.
class TrackedButton extends StatelessWidget {
  const TrackedButton({
    super.key,
    required this.buttonLabel,
    required this.buttonAction,
    required this.currentScreen,
    required this.onPressed,
    required this.builder,
  });

  final String buttonLabel;
  final String buttonAction;
  final String currentScreen;
  final VoidCallback? onPressed;
  final Widget Function(BuildContext context, VoidCallback? onPressed) builder;

  @override
  Widget build(BuildContext context) {
    return builder(
      context,
      trackButtonPress(
        context,
        buttonLabel: buttonLabel,
        buttonAction: buttonAction,
        currentScreen: currentScreen,
        onPressed: onPressed,
      ),
    );
  }
}

/// Records `button_tapped` and then runs [onPressed].
///
/// Returns null when [onPressed] is null. Use this for a control that already
/// exists when wrapping it in [TrackedButton] is awkward. Cubits should call
/// [AnalyticsService.trackButtonTapped] instead of this function.
VoidCallback? trackButtonPress(
  BuildContext context, {
  required String buttonLabel,
  required String buttonAction,
  required String currentScreen,
  required VoidCallback? onPressed,
}) {
  if (onPressed == null) return null;
  return () {
    final analytics = context.read<AnalyticsService>();
    _report(
      () => analytics.trackButtonTapped(
        buttonLabel: buttonLabel,
        buttonAction: buttonAction,
        currentScreen: currentScreen,
      ),
    );
    onPressed();
  };
}

void _report(Future<void> Function() send) {
  unawaited(() async {
    try {
      await send();
    } catch (_) {
      // A failed event still lets the button do its job.
    }
  }());
}
