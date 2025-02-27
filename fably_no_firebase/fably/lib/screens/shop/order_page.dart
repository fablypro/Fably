import 'dart:convert';

import 'package:fably/screens/auth/login.dart';
import 'package:fably/screens/shop/shopping_history.dart';
import 'package:fably/utils/prefs.dart';
import 'package:fably/utils/requests.dart';
import 'package:flutter/material.dart';

class OrderPage extends StatefulWidget {
  final String orderId;

  const OrderPage({super.key, required this.orderId});

    @override
  _OrderPageState createState() => _OrderPageState();
}

<<<<<<< HEAD
class OrderPage extends StatelessWidget {
  const OrderPage({super.key});
=======
class _OrderPageState extends State<OrderPage> {
  
  // Example data for the order;
    String orderDate = "-";
    bool isLoading = true;
    List<Map<String, dynamic>> clothingItems = [];
>>>>>>> 0919118b447d98c00f5b0540ba8acc619059c068

  @override
  void initState() {
    super.initState();
    final requests = BackendRequests();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if(!await requests.isLoggedIn()){
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
      fetchOrderItems();
    });
    
  }

  void fetchOrderItems() async {
    final requests = BackendRequests();
    final prefs = Prefs();

    setState(() {
      isLoading = true;
    });

    Map userInfo = {};
    userInfo = jsonDecode( await prefs.getPrefs('userInfo') ?? '{}');

    final response = await requests.postRequest(
      'customer_orders_items/${userInfo["_id"]}/',
      body: {
        'order_id': widget.orderId,
      },
    );

    if (response.statusCode == 200) {
      //final data = jsonDecode(response.body);
      Map<String, dynamic> jsonData = jsonDecode(response.body);
      Map<String, dynamic> orderInfo = jsonData;
      setState(() {
        orderDate = orderInfo['orderDate'];
        clothingItems = (jsonData['items'] as List<dynamic>)
          .map((item) => item as Map<String, dynamic>)
          .toList();
      });
    } else {
      print('Failed to fetch order items: ${response.statusCode}');
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    

    // Calculate the total cost
    final double totalCost = clothingItems.fold(
      0.0,
      (sum, item) => sum + (item["price"] * item["quantity"]),
    );

    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ShoppingHistoryScreen()),
          );
          return true;
        },
        child:Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ShoppingHistoryScreen()),
                ); // Navigate back to the previous screen
              },
            ),
            backgroundColor: Colors.black,
            title: const Text(
              "Order Details",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true, // Centers the title
          ),
          body: isLoading ? Center(child: CircularProgressIndicator()) : SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Order ID: ${widget.orderId}",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Date: $orderDate",
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const Divider(height: 24, thickness: 2),
                      const Text(
                        "Clothing Items:",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                clothingItems.isEmpty ? Center(child: Text('No orders found')) : Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: clothingItems.length,
                    itemBuilder: (context, index) {
                      final item = clothingItems[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              // Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  item["photos"][0],
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Item details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item["name"],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Unit Price: \$${item['price'].toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Quantity: ${item['quantity']}",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Total price
                              Text(
                                "\$${(item['price'] * item['quantity']).toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(width: 1.0, color: Colors.grey),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total Cost:",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "\$${totalCost.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}