// importing all flutter material.
import 'package:flutter/material.dart';

// importing from other dart files.
import 'package:flutter_ui_selections/belts_widget.dart';
import 'package:flutter_ui_selections/chains_widget.dart';
import 'package:flutter_ui_selections/glasses_widget.dart';
import 'package:flutter_ui_selections/gloves_widget.dart';
import 'package:flutter_ui_selections/handbags_widget.dart';
import 'package:flutter_ui_selections/hats_widget.dart';
import 'package:flutter_ui_selections/rings_widget.dart';
import 'package:flutter_ui_selections/socks_widget.dart';
import 'package:flutter_ui_selections/shoes_widget.dart';
import 'package:flutter_ui_selections/watches_widget.dart';

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
          seedColor: Colors.black,
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
        backgroundColor: Colors.black,
        // widget title.
        centerTitle: true,
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
            /* back button.*/
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute( builder: (context) => const  ),
                ),
              },
            ),
            */

            // handbag icon button.
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute( builder: (context) => const HandbagsWidget(), ),
                );
              },
              icon: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ImageIcon(
                    AssetImage("assets/icon_images/handbag_logo.png"),
                    size: 60,
                  ),
                  const Text(
                    'Handbags',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),


            // hat icon button.
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute( builder: (context) => const HatsWidget(), ),
                );
              },
              icon: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ImageIcon(
                    AssetImage("assets/icon_images/hat_logo.png"),
                    size: 60,
                  ),
                  const Text(
                    'Hats',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),


            // shoe icon button.
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute( builder: (context) => const ShoesWidget(), ),
                );
              },
              icon: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ImageIcon(
                    AssetImage("assets/icon_images/shoe_logo.png"),
                    size: 60,
                  ),
                  const Text(
                    'Shoes',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),


            // sock icon button.
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute( builder: (context) => const SocksWidget(), ),
                );
              },
              icon: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ImageIcon(
                    AssetImage("assets/icon_images/sock_logo.png"),
                    size: 60,
                  ),
                  const Text(
                    'Socks',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),


            // gloves icon button.
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute( builder: (context) => const GlovesWidget(), ),
                );
              },
              icon: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ImageIcon(
                    AssetImage("assets/icon_images/gloves_logo.png"),
                    size: 60,
                  ),
                  const Text(
                    'Gloves',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),


            // glasses icon button.
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute( builder: (context) => const GlassesWidget(), ),
                );
              },
              icon: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ImageIcon(
                    AssetImage("assets/icon_images/glasses_logo.png"),
                    size: 60,
                  ),
                  const Text(
                    'Glasses',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),


            // watches icon button.
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute( builder: (context) => const WatchesWidget(), ),
                );
              },
              icon: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ImageIcon(
                    AssetImage("assets/icon_images/watches_logo.png"),
                    size: 60,
                  ),
                  const Text(
                    'Watches',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),


            // ring icon button.
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute( builder: (context) => const RingsWidget(), ),
                );
              },
              icon: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ImageIcon(
                    AssetImage("assets/icon_images/ring_logo.png"),
                    size: 60,
                  ),
                  const Text(
                    'Rings',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),


            // chains icon button.
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute( builder: (context) => const ChainsWidget(), ),
                );
              },
              icon: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ImageIcon(
                    AssetImage("assets/icon_images/chains_logo.png"),
                    size: 60,
                  ),
                  const Text(
                    'Chains',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),


            // belt icon button.
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute( builder: (context) => const BeltsWidget(), ),
                );
              },
              icon: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ImageIcon(
                    AssetImage("assets/icon_images/belt_logo.png"),
                    size: 60,
                  ),
                  const Text(
                    'Belts',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),


          ],
        ),
      ),
    );
  }
}