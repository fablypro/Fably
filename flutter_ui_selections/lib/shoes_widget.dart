// importing all material from package:flutter/material.dart.
import 'package:flutter/material.dart';

// class for Shoes screen.
class ShoesWidget extends StatelessWidget {
  const ShoesWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // widget title.
        centerTitle: true,
        title: const Text('Shoes'),
        actions: const [
          // padding for the selections screen page.
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
          ),
        ],
      ),
      body: Center(
        // vertically arranges the buttons.
        child: Column(
          // centering the buttons vertically.
          mainAxisAlignment: MainAxisAlignment.center,
          // selection buttons.
          children: <Widget>[
          ],
        ),
      ),
    );
  }
}