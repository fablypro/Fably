// importing all material from package:flutter/material.dart.
import 'package:flutter/material.dart';

// running the App.
void main() {
  runApp(const MyApp());
}

// class with widgets and states.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Selection',
      // This is the theme of your application.
      theme: ThemeData(
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: const AccessorySuggestions(title: 'Accessory Suggestions'),
    );
  }
}

// visuals of Home page.
class AccessorySuggestions extends StatefulWidget {
  // creating the visuals of the Suggestions widget title.
  const AccessorySuggestions({super.key, required this.title});

  // declare the title of the Suggestions widget.
  final String title;

  @override
  State<AccessorySuggestions> createState() => _AccessorySuggestions();
}

// state of the Suggestions widget.
class _AccessorySuggestions extends State<AccessorySuggestions> {

  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // incrementing the count.
      _counter++;
    });
  }
  void _decrementCounter() {
      setState(() {
        // incrementing the count.
        _counter--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // background color to AppBar.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: <Widget>[
          Text("data"),
        ],
      ),
      // positioning the widget in middle of page.
      body: Center(
        // vertically arranges the buttons.
        child: Column(
          // centering the buttons vertically.
          mainAxisAlignment: MainAxisAlignment.center,
          // selection buttons.
          children: <Widget>[
            FloatingActionButton(
              onPressed: _incrementCounter,
              child: Icon(Icons.add),
            ),
            SizedBox(height: 20),
            FloatingActionButton(
              onPressed: _decrementCounter,
              child: Icon(Icons.remove),
            ),
          ],
        ),
      ),
    );
  }
}
