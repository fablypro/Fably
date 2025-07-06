import 'package:fably/screens/home/home.dart';
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
        // Handle physical back button
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const HomeScreen()), // Replace with your actual home screen widget
                );
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
          SizedBox(height: size.height * 0.02),
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
          SizedBox(height: size.height * 0.02),
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
        SizedBox(height: size.height * 0.04),
        Container(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
          width: double.infinity,
          child: Image(
            fit: BoxFit.cover,
            image: AssetImage("assets/ladies.jpg"),
          ),
        ),
        SizedBox(height: size.height * 0.02),
        Container(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
          child: Text(
            "Vintage collection is back!",
            style: kHeadingTextStyle,
          ),
        ),
        SizedBox(height: size.height * 0.02),
        Container(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
          child: Text(
            "Vintage collection available in Fably, place your order today. All men and women love vintage styles. From 70 s to 20th century we are briging back the colourful and bright vibes back.",
            style: kDefaultTextStyle,
          ),
        ),
        SizedBox(height: size.height * 0.02),
        Container(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
          width: double.infinity,
          child: Image(
            fit: BoxFit.cover,
            image: AssetImage("assets/image.png"),
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
        SizedBox(height: size.height * 0.02),
        Container(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
          child: Text(
            "Men’s Fashion Week. We’re Officially Obsessed With Everything Drawstring",
            style: kDefaultTextStyle,
          ),
        ),
        SizedBox(height: size.height * 0.04),
        Container(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
          width: double.infinity,
          child: Image(
            fit: BoxFit.cover,
            image: AssetImage("assets/ariana.png"),
          ),
        ),
        SizedBox(height: size.height * 0.02),
        Container(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
          child: Text(
            "Ariana Grande launches her new clothing brand ARI!",
            style: kHeadingTextStyle,
          ),
        ),
        SizedBox(height: size.height * 0.02),
        Container(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
          child: Text(
            "Today in LosAngelis california Famous singer Ariana Grande launced her clothing brand Ari with over 20 designs just for women.",
            style: kDefaultTextStyle,
          ),
        ),
      ],
    );
  }
}

//constants

const kHeadingTextStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w600,
  color: Colors.white,
);

const kDefaultTextStyle = TextStyle(
  fontSize: 14,
  color: Colors.white70,
);
