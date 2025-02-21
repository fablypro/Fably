// importing all material from package:flutter/material.dart.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// importing from other classes.
import '';

// classes for Watches screen.
class WatchesWidget extends StatelessWidget {
  const WatchesWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // background color to AppBar.
        backgroundColor: Colors.black,
        // widget title.
        centerTitle: true,
        title: const Text('Watches', style: TextStyle(fontWeight: FontWeight.normal)),
        actions: const [
          // padding for the selections screen page.
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
          ),

          //shopping bag badge.
          Badge(
            badgeContent: Consumer<CartProvider> (
              builder: (context, value, child) {
                return Text(
                  value.getCounter().toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 17.5,),
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
          children: [
            Expanded(
              child: Consumer<CartProvider>(
                builder: (BuildContext context, provider, widget) {
                  if (provider.cart.isEmpty) {
                    return const Center(
                      child: Text(''),
                    );
                  } else {
                    return ListView.builder(itemBuilder: itemBuilder)
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}