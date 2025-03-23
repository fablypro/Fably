import 'package:flutter/material.dart';
import 'routes.dart';
import 'screens/auth/login.dart';
import 'screens/auth/register.dart';
import 'screens/home/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fably',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.tealAccent,
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          bodyLarge: TextStyle(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
        ),
      ),
      initialRoute: '/login',
      onGenerateRoute: Routes.generateRoute,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}