// importing all material from package below.
import 'package:flutter/material.dart';

// classes for Belts screen.
class BeltsWidget extends StatelessWidget {
  const BeltsWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // background color to AppBar.
        backgroundColor: Colors.black,
        // widget title.
        centerTitle: true,
        title: const Text('Belts', style: TextStyle(fontWeight: FontWeight.normal)),
        actions: const [
          // padding for the selections screen page.
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
          ),
        ],
      ),
      body: Column(
        // arranges all items in shopping cart.
        children: [
          Expanded(

          )
        ],
      ),
    );
  }
}