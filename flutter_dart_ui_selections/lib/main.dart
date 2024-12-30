// importing all material from package:flutter/material.dart.
import 'package:flutter/material.dart';

// running the App.
void main() { runApp(const MyApp()); }

// class with widgets and states.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Selection',
      // The theme of the application.
      theme: ThemeData(
        // the App is dark.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: const AccessorySuggestions(title: 'Accessory Suggestions'),
    );
  }
}

// visuals of Suggestions page.
class AccessorySuggestions extends StatefulWidget {
  // creating the visuals of the Suggestions page title.
  const AccessorySuggestions({super.key, required this.title});

  // declare the title of the Suggestions page.
  final String title;

  @override
  State<AccessorySuggestions> createState() => _AccessorySuggestions();
}

// state of the Suggestions page.
class _AccessorySuggestions extends State<AccessorySuggestions> {

  // methods for each selection button.
  void _shoes() { setState(() { print("Shoes Button Pressed!"); }); }

  void _socks() { setState(() { print("Socks Button Pressed!"); }); }

  void _glasses() { setState(() { print("Glasses Button Pressed!"); }); }

  void _gloves() { setState(() { print("Gloves Button Pressed!"); }); }

  void _watches() { setState(() { print("Watches Button Pressed!"); }); }

  void _rings() { setState(() { print("Rings Button Pressed!"); }); }

  void _chains() { setState(() { print("Chains Button Pressed!"); }); }

  void _belts() { setState(() { print("Belts Button Pressed!"); }); }

  void _handbags() { setState(() { print("Belts Button Pressed!"); }); }
  
  void _hats() { setState(() { print("Belts Button Pressed!"); }); }

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
            
            // back button.
            ElevatedButton(onPressed: onPressed, child: child),
            
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

// class for Shoes screen.
class ShoesWidget extends StatelessWidget {
  const ShoesWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(),
    );
  }
}
// classes for Socks screen.
class SocksWidget extends StatelessWidget {
  const SocksWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(),
    );
  }
}
// classes for Chains screen.
class ChainsWidget extends StatelessWidget {
  const ChainsWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(),
    );
  }
}
// classes for Rings screen.
class RingsWidget extends StatelessWidget {
  const RingsWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(),
    );
  }
}
// classes for Glasses screen.
class GlassesWidget extends StatelessWidget {
  const GlassesWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(),
    );
  }
}
// classes for Gloves screen.
class GlovesWidget extends StatelessWidget {
  const GlovesWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(),
    );
  }
}
// classes for Watches screen.
class WatchesWidget extends StatelessWidget {
  const WatchesWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(),
    );
  }
}
// classes for Hats screen.
class HatsWidget extends StatelessWidget {
  const HatsWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(),
    );
  }
}
// classes for Belts screen.
class BeltsWidget extends StatelessWidget {
  const BeltsWidget({super.key});
  @override
 Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(),
    );
  }
}
// classes for Handbags screen.
class HandbagsWidget extends StatelessWidget {
  const HandbagsWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(),
    );
  }
}