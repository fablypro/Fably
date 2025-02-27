<<<<<<< Updated upstream
=======
import 'dart:io';

import 'package:fably/screens/home/widgets/common_appbar.dart';
>>>>>>> Stashed changes
import 'package:flutter/material.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

import '../shop/product.dart';
import '../shop/cart.dart';
import '../../utils/requests.dart';
import 'widgets/common_drawer.dart';
import 'widgets/bottom_nav_bar.dart';

class ProductService {
  final requests = BackendRequests();
  
   static String _baseUrl = 'http://192.168.1.7:5000/products';

  Future<List<Product>> fetchProducts() async {
    _baseUrl = '${requests.getUrl()}/products';
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        // If the server returns a successful response, parse the JSON
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }
}

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              product.images.isNotEmpty
                  ? product.images[0]
                  : '', // Show the first image
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          product.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '\$${product.price}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Product>> futureProducts;


  // Refresh method to reload data from API

  Future<void> _refreshProducts() async {
    setState(() {
      futureProducts =
          ProductService().fetchProducts(); // Trigger a fresh fetch
    });
  }

  void _showMessage(String message) {
    print(message);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> signOut() async {
    final requests = BackendRequests();

    try{
      final response = await requests.getRequest('logout');
      if (response.statusCode==200){
        _showMessage('Logged out successfully');
      }
    }catch (e) {
      _showMessage('Error Loging out: $e');
    }

  }

  @override
  void initState() {
    super.initState();
    futureProducts = ProductService().fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< Updated upstream
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fably - Home'),
        centerTitle: true,
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartPage(),
                  //builder: (context) => ProductPage(product: myProduct),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      drawer: CommonDrawer(),
      /*drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.tealAccent),
              child: Text('Menu',
                  style: TextStyle(color: Colors.black, fontSize: 24)),
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
      ),*/
      body: LiquidPullToRefresh(
        color: const Color.fromARGB(255, 255, 255, 255),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        height: 60.0,
        showChildOpacityTransition: false,
        onRefresh: _refreshProducts,
        child: FutureBuilder<List<Product>>(
          future: futureProducts,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final products = snapshot.data!;
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // Navigate to the ProductPage and pass the selected product

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductPage(
                            product: products[index], // Pass the product to ProductPage
                          ),
                        ),
                      );
                    },
                    child: ProductCard(product: products[index]),
                  );
                },
              );
            } else {
              return const Center(child: Text('No products available.'));
            }
          },
        ),
      ),
      bottomNavigationBar: CommonBottomNavBar(
        currentIndex: 0,
        //onTap: _onNavBarTap,
=======
    return WillPopScope(
      onWillPop: () async {
        if (Platform.isAndroid) {
          SystemNavigator.pop(); // For Android
        } else if (Platform.isIOS) {
          exit(0); // For iOS and other platforms
        }
        return false;
      },
      child:SafeArea(
        child:Scaffold(
          backgroundColor: Colors.black,
          appBar: CommonAppBar(
            title: 'FABLY'
            ),
          /*appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.black,
            title: const Text(
              'FABLY',
              style: TextStyle(
                letterSpacing: 3,
                fontFamily: 'jura',
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.white,
              ),
            ),
<<<<<<< HEAD
          ),
          // Category selector - with reduced height
          SizedBox(
            height: 30, // Reduced from 48
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: _selectedCategory == index 
                          ? Colors.white 
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white,
                        width: 1,
                      ),
=======
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CartPage(),
>>>>>>> 0919118b447d98c00f5b0540ba8acc619059c068
                    ),
                  );
                },
              ),
            ],
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          ),*/
          drawer: CommonDrawer(),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  'Discover',
                  style: TextStyle(
                    fontFamily: 'jura',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              // Category selector - with reduced height
              SizedBox(
                height: 36, // Reduced from 48
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = index;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: _selectedCategory == index 
                              ? Colors.white 
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white,
                            width: 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _categories[index],
                          style: TextStyle(
                            fontFamily: 'jura',
                            color: _selectedCategory == index 
                                ? Colors.black 
                                : Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Products grid - Modified to create unbalanced look without staggered grid
              Expanded(
                child: LiquidPullToRefresh(
                  color: Colors.white,
                  backgroundColor: Colors.black,
                  height: 60.0,
                  showChildOpacityTransition: false,
                  onRefresh: _refreshProducts,
                  child: FutureBuilder<List<Product>>(
                    future: futureProducts,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error: ${snapshot.error}',
                            style: const TextStyle(
                              fontFamily: 'jura',
                              color: Colors.white,
                            ),
                          ),
                        );
                      } else if (snapshot.hasData) {
                        final products = snapshot.data!;
                        
                        return GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.68, // Taller aspect ratio for all items
                          ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            // Create visual imbalance by applying different padding
                            EdgeInsets padding;
                            if (index % 4 == 0) {
                              padding = const EdgeInsets.only(bottom: 24); // Push down
                            } else if (index % 4 == 1) {
                              padding = const EdgeInsets.only(top: 24); // Push up
                            } else if (index % 4 == 2) {
                              padding = const EdgeInsets.only(bottom: 12); // Slight push down
                            } else {
                              padding = const EdgeInsets.only(top: 12); // Slight push up
                            }
                            
                            return Padding(
                              padding: padding,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductPage(
                                        product: products[index],
                                      ),
                                    ),
                                  );
                                },
                                child: ProductCard(
                                  product: products[index],
                                  heightFactor: _getItemHeight(index),
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        return const Center(
                          child: Text(
                            'No products available.',
                            style: TextStyle(
                              fontFamily: 'jura',
                              color: Colors.white,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: CommonBottomNavBar(
            currentIndex: 0,
          ),
        ),
>>>>>>> Stashed changes
      ),
    );
  }
}
