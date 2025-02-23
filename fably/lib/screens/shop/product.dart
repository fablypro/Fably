import 'package:flutter/material.dart';
import 'dart:convert'; // For JSON decoding, if needed
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'cart.dart';
import '../auth/login.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final List<String> images;
  final String category;
  final int stockQuantity;
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.images,
    required this.category,
    required this.stockQuantity,
    required this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      price: json['price'] ?? 0.0,
      images: List<String>.from(json['photos'] ?? []),
      category: json['category'] ?? 'No category',
      stockQuantity: json['stockQuantity'] ?? 0,
      description: json['description'] ?? 'No description',
    );
  }
}

class ProductPage extends StatefulWidget {
  final Product product;

  const ProductPage({super.key, required this.product});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  int _quantity = 1;
  String _selectedSize = "M";
  final PageController _pageController = PageController();
  int _currentPage = 0;

  Future<String?> getPrefs(pref) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? value = prefs.getString(pref);
    return value;
  }

  bool checkLoggedIn(context){
    if (getPrefs('userInfo') == Null || getPrefs('cookies') == Null){
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ),
      );
      return false;
    }
    return true;
  }

  Future<bool> addToCart(String id, int quantity) async {
    String cookies = '';
    Map userInfo = {};
    getPrefs('cookies').then((c){
      cookies = c ?? '';
      
    });
    getPrefs('userInfo').then((c){
      String userInfoStr = c ?? '{}';
      userInfo = jsonDecode(userInfoStr);
      
    });
    // Step 1: Retrieve the CSRF token
    final csrfUrl = Uri.parse('http://127.0.0.1:5000/get-csrf-token');
    final csrfResponse = await http.get(csrfUrl);
    
    if (csrfResponse.statusCode != 200) {
      throw Exception("Failed to fetch CSRF token: ${csrfResponse.statusCode}");
    }
    
    // Assume the CSRF token is returned as plain text
    final csrfToken = csrfResponse.body.trim();
    print("CSRF Token: $csrfToken");

    // Step 2: Prepare the login data as JSON
    final changePayload = jsonEncode({
      'item_id': id,
      'quantity': quantity,
    });

    // Step 3: Send a POST request to the login endpoint with the CSRF token in headers
    final url = Uri.parse('http://127.0.0.1:5000/add_to_cart/${userInfo["_id"]}/');
    final changeResponse = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "X-CSRFToken": csrfToken, // Adjust header name if needed
        "Cookies": cookies
      },
      body: changePayload,
    );

    // Step 4: Handle the login response
    if (changeResponse.statusCode == 200) {
      // Parse the returned user info
      print(changeResponse.body);

      // Extract cookies from the response headers
      // Note: The cookie string might include additional attributes
      final String? cookies = changeResponse.headers['set-cookie'];
      print("Cookies: $cookies");

      // Step 5: Save the user info and cookies using SharedPreferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userInfo', jsonEncode(userInfo));
      if (cookies != null) {
        await prefs.setString('cookies', cookies);
      }

      print("Removed Item Successfully");
      return true;
    } else {
      print("Failed to remove item: ${changeResponse.statusCode}");
      print("Response: ${changeResponse.body}");
    }
    return false;
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    setState(() {
      if (_quantity > 1) {
        _quantity--;
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Text(
                            "Fably",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        SizedBox(
                          height: 300,
                          child: PageView.builder(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() {
                                _currentPage = index;
                              });
                            },
                            itemCount: widget.product.images.isEmpty
                                ? 1
                                : widget.product.images.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.network(
                                    widget.product.images.isEmpty
                                        ? 'https://via.placeholder.com/250'
                                        : widget.product.images[index],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        if (widget.product.images.length > 1)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                widget.product.images.length,
                                (index) => Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentPage == index
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Size",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: ["S", "M", "L"].map((size) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedSize = size;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _selectedSize == size
                                  ? Colors.white
                                  : Colors.grey[900],
                              foregroundColor: _selectedSize == size
                                  ? Colors.black
                                  : Colors.white,
                            ),
                            child: Text(size),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.product.description,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Price: \$${widget.product.price}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.favorite_border,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            // Implement favorites functionality
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Quantity: $_quantity",
                          style: const TextStyle(color: Colors.white),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon:
                                  const Icon(Icons.remove, color: Colors.white),
                              onPressed: _decrementQuantity,
                            ),
                            Text(
                              _quantity.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, color: Colors.white),
                              onPressed: _incrementQuantity,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Implement virtual try-on
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text("Virtual Try-On"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Implement add to cart
                              if (checkLoggedIn(context)){
                                addToCart(widget.product.id, _quantity);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text("Add to Cart"),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Implement buy now
                          if (checkLoggedIn(context)){
                            addToCart(widget.product.id, _quantity);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CartPage(),
                                //builder: (context) => ProductPage(product: myProduct),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Buy Now",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
