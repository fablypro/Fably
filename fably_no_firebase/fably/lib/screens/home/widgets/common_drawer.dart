import 'package:flutter/material.dart';
<<<<<<< Updated upstream
import '../../gender/gender_selection.dart';
=======
import '../../../utils/prefs.dart';
import '../../../utils/requests.dart';
import '../../profile/pofile_page.dart';
>>>>>>> Stashed changes

class CommonDrawer extends StatelessWidget {
  const CommonDrawer({super.key});

  @override
  Widget build(BuildContext context) {
<<<<<<< Updated upstream
    return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.tealAccent),
              child: Text('Menu',
                  style: TextStyle(color: Colors.black, fontSize: 24)),
=======
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
          ),
        ),
        SizedBox(
          width: 280, // Increased overall drawer width
<<<<<<< HEAD
          height: 470,
=======
          height: 450,
>>>>>>> 0919118b447d98c00f5b0540ba8acc619059c068
          child: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                SizedBox(
                  height: 108, // Reduced header height (default is 160)
                  child: Stack(
                    children: [
                      Container(
                        height: 80,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.only(left: 30.0, top: 20.0),
                          child: Text(
                            'MENU',
                            style: TextStyle(
                              fontFamily: "jura",
                              letterSpacing: 6,
                              fontWeight: FontWeight.bold,
                              color: Colors.black, 
                              fontSize: 24),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 8,
                        top: 13,
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: ListTile(
                    leading: const Icon(
                      Icons.home,
                      color: Colors.white,
                    ),
                    title: const Text(
                      'HOME',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: "Jura",
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.6),
                    ),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                      );
                    },
                  )),
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: ListTile(
                    leading: const Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.white,
                    ),
                    title: const Text(
                      'MY CART',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: "Jura",
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.6),
                    ),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => CartPage()),
                      );
                    },
                  )),
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: ListTile(
                    leading: const Icon(
                      Icons.favorite_border_outlined,
                      color: Colors.white,
                    ),
                    title: const Text(
                      'WISHLIST',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: "Jura",
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.6),
                    ),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => WishlistPage()),
                      );
                    },
                  )),
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: ListTile(
                    leading: const Icon(
                      Icons.qr_code_scanner,
                      color: Colors.white,
                    ),
                    title: const Text(
                      'VIRTUAL TRY-ON',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: "Jura",
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.6),
                    ),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => UploadImagesPage()),
                      );
                    },
                  )
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: ListTile(
                    leading: const Icon(
                      Icons.person_outline,
                      color: Colors.white,
                    ),
                    title: const Text(
                      'PROFILE',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: "Jura",
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.6),
                    ),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => ProfilePage()),
                      );
                    },
                  )
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: ListTile(
                    leading: const Icon(
                      Icons.list_alt,
                      color: Colors.white,
                    ),
                    title: const Text(
                      'MY ORDERS',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: "Jura",
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.6),
                    ),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => ShoppingHistoryScreen()),
                      );
                    },
                  )
                ),
              ],
>>>>>>> Stashed changes
            ),
            ListTile(
              leading: const Icon(Icons.settings_backup_restore),
              title: const Text('Back to Selection Screen'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AreYouScreen()),
                );
              },
            ),
          ],
        ),
      );
  }
}