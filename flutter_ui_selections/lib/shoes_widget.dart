// importing all material from package:flutter/material.dart.
import 'package:flutter/material.dart';

// class for Shoes screen.
class ShoesWidget extends StatelessWidget {
  const ShoesWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // background color to AppBar.
        backgroundColor: Colors.black,
        // widget title.
        centerTitle: true,
        title: const Text('Shoes', style: TextStyle(fontWeight: FontWeight.normal)),
        actions: const [
          // padding for the selections screen page.
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
          ),
        ],
      ),
      body: Center(
        // vertically arranges the buttons.
        child: GridView.count(
          // number of columns.
          crossAxisCount: 2,
          // spacing between item buttons.
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          // padding around the grid.
          padding: const EdgeInsets.all(16),
          // fitting the grid size.
          shrinkWrap: true,
          // selection item buttons.
          children: <Widget>[],
        ),
      ),
    );
  }
}