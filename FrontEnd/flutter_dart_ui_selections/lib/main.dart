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
        // the App is dark.
        colorScheme: ColorScheme.dark(),
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

  Image image1 = '';
  Image image2 = '';
  Image image3 = '';
  Image image4 = '';
  Image image5 = '';
  Image image6 = '';

  int counter = 0;

  void _incrementCounter() {
    setState(() {
      // incrementing the count.
      counter++;
    });
  }
  void _decrementCounter() {
    setState(() {
        // incrementing the count.
        counter--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // background color to AppBar.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // widget title.
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
            SizedBox(height: 20, width: 20,),
            FloatingActionButton(
              onPressed: _incrementCounter,
              child: Icon(image1),
            ),
            SizedBox(height: 20, width: 20,),
            FloatingActionButton(
              onPressed: _decrementCounter,
              child: Icon(image2),
            ),
            SizedBox(height: 20, width: 20,),
            FloatingActionButton(
              onPressed: _decrementCounter,
              child: Icon(image3),
            ),
            SizedBox(height: 20, width: 20,),
            FloatingActionButton(
              onPressed: _incrementCounter,
              child: Icon(image4),
            ),
            SizedBox(height: 20, width: 20,),
            FloatingActionButton(
              onPressed: _decrementCounter,
              child: Icon(image5),
            ),
            SizedBox(height: 20, width: 20,),
            FloatingActionButton(
              onPressed: _decrementCounter,
              child: Icon(image6),
            ),
            IconButton(onPressed: onPressed, icon: icon),
          ],
        ),
      ),
    );
  }
}
