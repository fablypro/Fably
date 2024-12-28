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
  Image image7 = '';

  void _shoes() {
    setState(() {
    });
  }
  void _socks() {
    setState(() {
    });
  }
  void _glasses() {
    setState(() {
    });
  }
  void _gloves() {
    setState(() {
    });
  }
  void _watches() {
    setState(() {
    });
  }
  void _rings() {
    setState(() {
    });
  }
  void _chains() {
    setState(() {
    });
  }

  // building the conmtext of the App Page.
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
            IconButton(
              onPressed: _shoes,
              icon: image1,
            ),
            SizedBox(height: 20, width: 20,),
            IconButton(
              onPressed: _socks,
              icon: image2,
            ),
            SizedBox(height: 20, width: 20,),
            IconButton(
              onPressed: _gloves,
              icon: image3,
            ),
            SizedBox(height: 20, width: 20,),
            IconButton(
              onPressed: _glasses,
              icon: image4,
            ),
            SizedBox(height: 20, width: 20,),
            IconButton(
              onPressed: _watches,
              icon: image5,
            ),
            SizedBox(height: 20, width: 20,),
            IconButton(
              onPressed: _rings,
              icon: image6,
            ),
            SizedBox(height: 20, width: 20,),
            IconButton(
              onPressed: _chains,
              icon: image7,
            ),
          ],
        ),
      ),
    );
  }
}
