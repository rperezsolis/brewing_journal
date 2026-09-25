import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../../../../client.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final signIn = SignInWidget(
      client: client,
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // SignInWidget only forwards user-facing exceptions, whose
            // toString() is the message to display.
            content: Text(
              error.toString(),
              style: TextStyle(color: colors.onErrorContainer),
            ),
            backgroundColor: colors.errorContainer,
            duration: const Duration(seconds: 5),
          ),
        );
      },
    );

    return Scaffold(
      body: SafeArea(
        // SignInWidget has a fixed height (~380px), so it scrolls on short
        // screens and stays centered on tall ones.
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(child: signIn),
            ),
          ),
        ),
      ),
    );
  }
}
