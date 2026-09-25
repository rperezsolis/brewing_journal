import 'package:flutter/material.dart';

/// Shown while the persisted session is being restored, so a signed-in user
/// never sees the sign-in screen flash on start.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
