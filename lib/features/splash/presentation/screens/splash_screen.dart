import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pubmed_mobile/core/router/app_router.dart';

import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    // Show splash screen for at least 1.5 seconds for branding
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      context.go(AppRoutes.search);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            SvgPicture.asset(
              'assets/pubmed_logo.svg',
              width: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            // Loading Indicator
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
