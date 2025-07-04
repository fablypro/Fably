import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import 'checkout_screen.dart';
import '../auth/login.dart';
import '../shop/product.dart';
import '../../utils/requests.dart';
import '../../utils/prefs.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Trending(),
      debugShowCheckedModeBanner: false,
    );
  }
}
