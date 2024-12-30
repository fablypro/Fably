// importing all material from package:flutter/material.dart.
import 'package:flutter/material.dart';

// running the App.
void main() {runApp(const MyApp());}

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

  // methods for each selection button.
  void _shoes() {
    setState(() {
      print("Shoes Button Pressed!");
    });
  }
  void _socks() {
    setState(() {
      print("Socks Button Pressed!");
    });
  }
  void _glasses() {
    setState(() {
      print("Glasses Button Pressed!");
    });
  }
  void _gloves() {
    setState(() {
      print("Gloves Button Pressed!");
    });
  }
  void _watches() {
    setState(() {
      print("Watches Button Pressed!");
    });
  }
  void _rings() {
    setState(() {
      print("Rings Button Pressed!");
    });
  }
  void _chains() {
    setState(() {
      print("Chains Button Pressed!");
    });
  }
  void _belts() {
    setState(() {
      print("Belts Button Pressed!");
    });
  }
  void _handbags() {
    setState(() {
      print("Belts Button Pressed!");
    });
  }
  void _hats() {
    setState(() {
      print("Belts Button Pressed!");
    });
  }
  
  // widgets for each accessory.
  Widget shoesWidget() {
    @override
    State<Shoes> createState() => ();
  }
  Widget socksWidget() {
    @override
    State<Socks> createState() => ();
  }
  Widget glassesWidget() {
    @override
    State<Gloves> createState() => ();
  }
  Widget glovesWidget() {
    State<Chains> createState() => ();
  }
  Widget watchesWidget() {
    @override
    State<Shoes> createState() => ();
  }
  Widget ringsWidget() {
    @override
    State<Socks> createState() => ();
  }
  Widget chainsWidget() {
    @override
    State<Chains> createState() => ();
  }
  Widget beltsWidget() {
    @override
    State<Chains> createState() => ();
  }
  Widget handbagsWidget() {
    @override
    State<Chains> createState() => ();
  }
  Widget hatsWidget() {
    @override
    State<Chains> createState() => ();
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
            
            // shoe icon button.
            SizedBox(height: 20, width: 20,),
            IconButton(
              onPressed: _shoes,
              icon: ImageIcon(
                AssetImage("flutter_dart_ui_selections\\icon images\\shoe logo.png"),
                size: 20,
              ),
            ),

            // sock icon button.
            SizedBox(height: 20, width: 20,),
            IconButton(
              onPressed: _socks,
              icon: ImageIcon(
                AssetImage("flutter_dart_ui_selections\\icon images\\sock logo.png"),
                size: 20,
              ),
            ),

            // gloves icon button.
            SizedBox(height: 20, width: 20,),
            IconButton(
              onPressed: _gloves,
              icon: ImageIcon(
                AssetImage("flutter_dart_ui_selections\\icon images\\gloves logo.png"),
                size: 20,
              ),
            ),
            
            // glasses icon button.
            SizedBox(height: 20, width: 20,),
            IconButton(
              onPressed: _glasses,
              icon: ImageIcon(
                AssetImage("flutter_dart_ui_selections\\icon images\\glasses logo.png"),
                size: 20,
              ),
            ),

            // watches icon button.
            SizedBox(height: 20, width: 20,),
            IconButton(
              onPressed: _watches,
              icon: ImageIcon(
                AssetImage("flutter_dart_ui_selections\\icon images\\watches logo.png"),
                size: 20,
              ),
            ),

            // ring icon button.
            SizedBox(height: 20, width: 20,),
            IconButton(
              onPressed: _rings,
              icon: ImageIcon(
                AssetImage("flutter_dart_ui_selections\\icon images\\ring logo.png"),
                size: 20,
              ),
            ),

            // chains icon button.
            SizedBox(height: 20, width: 20,),
            IconButton(
              onPressed: _chains,
              icon: ImageIcon(
                AssetImage("flutter_dart_ui_selections\\icon images\\chains logo.png"),
                size: 20,
              ),
            ),

            // belt icon button.
            SizedBox(height: 20, width: 20,),
            IconButton(
              onPressed: _belts,
              icon: ImageIcon(
                AssetImage("flutter_dart_ui_selections\\icon images\\belt logo.png"),
                size: 20,
              ),
            ),

            // handbag icon button.
            SizedBox(height: 20, width: 20,),
            IconButton(
              onPressed: _handbags,
              icon: ImageIcon(
                AssetImage("flutter_dart_ui_selections\\icon images\\handbag logo.png"),
                size: 20,
              ),
            ),

            // hat icon button.
            SizedBox(height: 20, width: 20,),
            IconButton(
              onPressed: _hats,
              icon: ImageIcon(
                AssetImage("flutter_dart_ui_selections\\icon images\\hat logo.png"),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
