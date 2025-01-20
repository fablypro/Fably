// importing all material from package:flutter/material.dart.
import 'package:flutter/material.dart';

// visuals of Suggestions page.
class AccessorySuggestions extends StatefulWidget {
  // creating the visuals of the Suggestions page title.
  const AccessorySuggestions({super.key, required this.title});

  // declare the title of the Suggestions page.
  final String title;

  @override
  State<AccessorySuggestions> createState() => _AccessorySuggestions();
}

// classes for Gloves screen.
class GlovesWidget extends StatelessWidget {
  const GlovesWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // widget title.
        title: const Text('Gloves'),
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