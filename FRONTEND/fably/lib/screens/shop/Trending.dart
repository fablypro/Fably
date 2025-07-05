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

class Trending extends StatelessWidget {
  const Trending({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context); // Handle physical back button
        return true;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context); // Handle app bar back button
              },
            ),
            title: const Text(
              "Trending",
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
          ),
          body: Body(size: size),
        ),
      ),
    );
  }
}

class Body extends StatelessWidget {
  const Body({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: size.height * 0.03),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
            child: Text(
              "New Fashion Trends",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: size.height * 0.03),
          buildTrendSection(size),
          //buildTrendSection(size),
          //buildTrendSection(size),
        ],
      ),
    );
  }

    Widget buildTrendSection(Size size) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
          width: double.infinity,
                    child: Image(
            fit: BoxFit.cover,
            image: AssetImage("assets/beautiful.png"),
          ),
        ),
                SizedBox(height: size.height * 0.02),
        Container(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
          child: Text(
            "13 Work-Appropriate Vests That’ll Make Dressing",
            style: kHeadingTextStyle,
          ),
        ),
        