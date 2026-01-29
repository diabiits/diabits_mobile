import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// A screen that displays a loading animation.
///
/// This widget is used to indicate that the application is in a loading state
/// during app initialization.
/// Just a fun little Lottie animation that I made cause I needed a break.
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  /// Builds the UI for the loading screen.
  ///
  /// It displays a Lottie animation centered on the screen.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Lottie.asset(
          'assets/loading_icon.json',
          width: 250,
          height: 250,
          repeat: true,
        ),
      ),
    );
  }
}
