import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:weathertracker/features/splash/presentation/pages/splash_page.dart';

void main() {
  testWidgets('SplashPage navigates to HomePage after delay', (tester) async {
    final router = GoRouter(
      initialLocation: '/splash',
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Home Page')),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
      ),
    );

    // Checking for initial splash screen content
    expect(find.text('Weather Tracker'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);

    // Advance the timer by 3 seconds
    await tester.pump(const Duration(seconds: 3));

    await tester.pumpAndSettle();

    // Check if navigation to home page occurred
    expect(find.text('Home Page'), findsOneWidget);
    expect(find.text('Weather Tracker'), findsNothing);
  });
} 