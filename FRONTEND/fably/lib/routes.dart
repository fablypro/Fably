import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/matching_screen.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/match':
        return MaterialPageRoute(builder: (_) => const MatchingScreen());
      default:
        return MaterialPageRoute(builder: (_) => const NotFoundScreen());
    }
  }
}

// A simple screen to handle unknown routes
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("404 - Page Not Found", style: Theme.of(context).textTheme.headlineLarge),
      ),
    );
  }
}
