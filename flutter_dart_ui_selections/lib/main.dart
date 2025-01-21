// importing all material from package:flutter/material.dart.
import 'package:flutter/material.dart';

// importing from other dart files.
import 'package:flutter_dart_ui_selections/BeltsWidget.dart';
import 'package:flutter_dart_ui_selections/ChainsWidget.dart';
import 'package:flutter_dart_ui_selections/GlassesWidget.dart';
import 'package:flutter_dart_ui_selections/GlovesWidget.dart';
import 'package:flutter_dart_ui_selections/HandbagsWidget.dart';
import 'package:flutter_dart_ui_selections/HatsWidget.dart';
import 'package:flutter_dart_ui_selections/RingsWidget.dart';
import 'package:flutter_dart_ui_selections/SocksWidget.dart';
import 'package:flutter_dart_ui_selections/ShoesWidget.dart';
import 'package:flutter_dart_ui_selections/WatchesWidget.dart';

// running the App.
void main() { runApp(const MySelectionApp()); }

// class with widgets and states.
class MySelectionApp extends StatelessWidget {
  const MySelectionApp({super.key});
  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Selection',
      // The theme of the application.
      theme: ThemeData(
        // the App is dark.
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.grey,
            brightness: Brightness.dark,
        ),
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
  // building the context of the App Page.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // background color to AppBar.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // widget title.
        title: Text(widget.title),
        actions: const [
          // padding for the selections screen page.
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
          ),
        ],
      ),
      // positioning the widget in middle of page.
      body: Center(
        // vertically arranges the buttons.
        child: GridView.count(
          // number of columns.
          crossAxisCount: 2,
          // spacing between buttons.
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          // padding around the grid.
          padding: const EdgeInsets.all(16),
          // fitting the grid size.
          shrinkWrap: true,
          // selection buttons.
          children: <Widget>[
            
            /*
            // back button.
            ElevatedButton(
              child: const Text("Back to Home Page"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute( builder: (context) => const  ),
                ),
              },
            ),
            */
            
            // shoe icon button.
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute( builder: (context) => const ShoesWidget(), ),
                );
              },
              icon: const ImageIcon(
                AssetImage("flutter_dart_ui_selections\\icon images\\shoe logo.png"),
                size: 12,
              ),
            ),
            const Text(
              'Shoes',
              style: TextStyle(fontSize: 14),
            ),

            // sock icon button.
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute( builder: (context) => const SocksWidget(), ),
                );
              },
              icon: const ImageIcon(
                AssetImage("flutter_dart_ui_selections\\icon images\\sock logo.png"),
                size: 12,
              ),
            ),
            const Text(
              'Socks',
              style: TextStyle(fontSize: 14),
            ),

            // gloves icon button.
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute( builder: (context) => const GlovesWidget(), ),
                );
              },
              icon: const ImageIcon(
                AssetImage("flutter_dart_ui_selections\\icon images\\gloves logo.png"),
                size: 12,
              ),
            ),
            const Text(
              'Gloves',
              style: TextStyle(fontSize: 14),
            ),
            
            // glasses icon button.
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute( builder: (context) => const GlassesWidget(), ),
                );
              },
              icon: const ImageIcon(
                AssetImage("flutter_dart_ui_selections\\icon images\\glasses logo.png"),
                size: 12,
              ),
            ),
            const Text(
              'Glasses',
              style: TextStyle(fontSize: 14),
            ),

            // watches icon button.
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute( builder: (context) => const WatchesWidget(), ),
                );
              },
              icon: const ImageIcon(
                AssetImage("flutter_dart_ui_selections\\icon images\\watches logo.png"),
                size: 12,
              ),
            ),
            const Text(
              'Watches',
              style: TextStyle(fontSize: 14),
            ),

            // ring icon button.
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute( builder: (context) => const RingsWidget(), ),
                );
              },
              icon: const ImageIcon(
                AssetImage("flutter_dart_ui_selections\\icon images\\ring logo.png"),
                size: 12,
              ),
            ),
            const Text(
              'Rings',
              style: TextStyle(fontSize: 14),
            ),

            // chains icon button.
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute( builder: (context) => const ChainsWidget(), ),
                );
              },
              icon: const ImageIcon(
                AssetImage("flutter_dart_ui_selections\\icon images\\chains logo.png"),
                size: 12,
              ),
            ),
            const Text(
              'Chains',
              style: TextStyle(fontSize: 14),
            ),

            // belt icon button.
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute( builder: (context) => const BeltsWidget(), ),
                );
              },
              icon: const ImageIcon(
                AssetImage("flutter_dart_ui_selections\\icon images\\belt logo.png"),
                size: 12,
              ),
            ),
            const Text(
              'Belts',
              style: TextStyle(fontSize: 14),
            ),

            // handbag icon button.
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute( builder: (context) => const HandbagsWidget(), ),
                );
              },
              icon: const ImageIcon(
                AssetImage("flutter_dart_ui_selections\\icon images\\handbag logo.png"),
                size: 12,
              ),
            ),
            const Text(
              'Handbags',
              style: TextStyle(fontSize: 14),
            ),

            // hat icon button.
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute( builder: (context) => const HatsWidget(), ),
                );
              },
              icon: const ImageIcon(
                AssetImage("flutter_dart_ui_selections\\icon images\\hat logo.png"),
                size: 12,
              ),
            ),
            const Text(
              'Hats',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}