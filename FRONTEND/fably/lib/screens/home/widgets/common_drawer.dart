import 'package:fably/screens/home/home.dart';
import 'package:fably/screens/scanner/add_images.dart';
import 'package:fably/screens/shop/cart.dart';
import 'package:fably/screens/shop/shopping_history.dart';
import 'package:fably/screens/shop/wishlist.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../utils/prefs.dart';
import '../../../utils/requests.dart';
import '../../profile/pofile_page.dart';
import 'package:fably/screens/shop/Trending.dart';

class CommonDrawer extends StatefulWidget {
  const CommonDrawer({super.key});

  @override
  State<CommonDrawer> createState() => _CommonDrawerState();
}

class _CommonDrawerState extends State<CommonDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _blurAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _blurAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start the animation when the drawer opens
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> signOut(BuildContext context) async {
    final requests = BackendRequests();
    final prefs = Prefs();

    try {
      final response = await requests.getRequest('logout');
      if (response.statusCode == 200) {
        await prefs.clearPrefs();
        _showMessage(context, 'Logged out successfully');
      }
    } catch (e) {
      _showMessage(context, 'Error Logging out: $e');
    }
  }

  void _showMessage(BuildContext context, String message) {
    print(message);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Stack(
          children: [
            // Blurred Background
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: _blurAnimation.value,
                  sigmaY: _blurAnimation.value,
                ),
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
            ),
            // Drawer Content with Animation
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: -280, end: 0),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(value, 0),
                  child: child,
                );
              },
              child: SizedBox(
                width: 280,
                height: 450,
                child: Drawer(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      SizedBox(
                        height: 108, // Reduced header height
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
                                  // Run reverse animation before closing
                                  _animationController.reverse().then((_) {
                                    Navigator.of(context).pop();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildMenuItem(
                        icon: Icons.home,
                        title: 'HOME',
                        onTap: () => _navigateTo(context, const HomeScreen()),
                      ),
                      _buildMenuItem(
                        icon: Icons.heat_pump_outlined,
                        title: "Trending",
                        onTap: () => _navigateTo(context, Trending()),
                      ),
                      _buildMenuItem(
                        icon: Icons.shopping_bag_outlined,
                        title: 'MY CART',
                        onTap: () => _navigateTo(context, CartPage()),
                      ),
                      _buildMenuItem(
                        icon: Icons.favorite_border_outlined,
                        title: 'WISHLIST',
                        onTap: () => _navigateTo(context, WishlistPage()),
                      ),
                      _buildMenuItem(
                        icon: Icons.qr_code_scanner,
                        title: 'VIRTUAL TRY-ON',
                        onTap: () => _navigateTo(context, UploadImagesPage()),
                      ),
                      _buildMenuItem(
                        icon: Icons.person_outline,
                        title: 'PROFILE',
                        onTap: () => _navigateTo(context, ProfilePage()),
                      ),
                      _buildMenuItem(
                        icon: Icons.list_alt,
                        title: 'MY ORDERS',
                        onTap: () =>
                            _navigateTo(context, ShoppingHistoryScreen()),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Helper method to build menu items with consistent styling
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.white,
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: "Jura",
            fontWeight: FontWeight.bold,
            letterSpacing: 2.6,
          ),
        ),
        onTap: () {
          // Run reverse animation before navigating
          _animationController.reverse().then((_) {
            onTap();
          });
        },
      ),
    );
  }

  // Helper method to navigate to a new screen
  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}
