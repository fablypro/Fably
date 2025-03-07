import 'package:fably/screens/auth/login.dart';
import 'package:fably/screens/home/widgets/bottom_nav_bar.dart';
import 'package:fably/screens/home/widgets/common_drawer.dart';
import 'package:fably/screens/shop/cart.dart';
import 'package:fably/screens/shop/product.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:stripe_payment/stripe_payment.dart'; // Stripe dependency
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  StripePayment.setOptions(StripeOptions(
    publishableKey: "pk_test_51QxRgVG8IzWoJC0qBdV4mI4vdKYPi0Wdsvg0NZXLbzVCk9eUAE994wDFibdd9bhcoDvSUvnCRv3SGcANvk2E4AN0004OyoOdxY", // Stripe Publishable Key
    merchantId: "Test", 
    androidPayMode: 'test',
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fably',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.tealAccent,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.tealAccent,
            foregroundColor: Colors.black,
          ),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

class ProductService {
  final String baseUrl = 'http://192.168.1.7:5000/products';

  Future<List<Product>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
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
                  : 'https://via.placeholder.com/150',
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
      futureProducts = ProductService().fetchProducts(); // Trigger a fresh fetch
    });
  }

  void _showMessage(String message) {
    print(message);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> signOut() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.1.7:5000/logout'));
      if (response.statusCode == 200) {
        _showMessage('Logged out successfully');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      _showMessage('Error Logging out: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    futureProducts = ProductService().fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
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
                  builder: (context) => const CartPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              signOut();
            },
          ),
        ],
      ),
      drawer: CommonDrawer(),
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
      ),
    );
  }
}
