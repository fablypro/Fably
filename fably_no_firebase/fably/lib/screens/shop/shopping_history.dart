import 'dart:convert';
import 'dart:ffi';

import 'package:fably/screens/auth/login.dart';
import 'package:fably/screens/home/home.dart';
import 'package:fably/screens/shop/order_page.dart';
import 'package:fably/utils/prefs.dart';
import 'package:fably/utils/requests.dart';
import 'package:flutter/material.dart';

class ShoppingHistoryScreen extends StatefulWidget {
  @override
  _ShoppingHistoryScreenState createState() => _ShoppingHistoryScreenState();
}

class _ShoppingHistoryScreenState extends State<ShoppingHistoryScreen> {
  List<Map<String, dynamic>> orders = [
    {
      '_id': 'ORD12345',
      'orderDate': 'Feb 20, 2025',
      'total': 120.50,
      'status': 'Delivered',
    },
    {
      '_id': 'ORD12346',
      'orderDate': 'Feb 18, 2025',
      'total': 85.75,
      'status': 'Shipped',
    },
    {
      '_id': 'ORD12347',
      'orderDate': 'Feb 15, 2025',
      'total': 45.00,
      'status': 'Cancelled',
    },
  ];
  bool isLoading = true;

  void goToOrder(index){
    final data = orders[index];

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => OrderPage(orderId: data['_id']),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    
    this.orders = [];

    final requests = BackendRequests();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if(!await requests.isLoggedIn()){
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
      fetchUserOrders();
    });
  }

  void fetchUserOrders() async {
    final requests = BackendRequests();
    final prefs = Prefs();

    Map userInfo = {};
    userInfo = jsonDecode( await prefs.getPrefs('userInfo') ?? '{}');
    isLoading = true;

    try {
      final response = await requests.postRequest(
        'customer_orders/${userInfo["_id"]}/'
        );
      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        orders = jsonData.map((item) => item as Map<String, dynamic>).toList();
        //final List<Map<String, dynamic>> orders = jsonDecode(response.body);
        setState(() {
          this.orders = orders;
          for (int i =0; i<orders.length; i++){
            orders[i]["status"] = "Delivered";
          }
        });
        print('Orders: $orders');
      }
      print("${response.body}");
    } catch (e) {
      print('Error fetching orders: $e');
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            ); // Navigate back to the previous screen
          },
        ),
        title: const Text(
          "Shopping History",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true, // Centers the title
      ),
      body: isLoading ? Center(child: CircularProgressIndicator()) : this.orders.isEmpty ? Center(child: Text('No orders found')) : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              onTap: () {
                goToOrder(index);
              },
              title: Text("Order: ${order['_id']}",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Date: ${order['orderDate']}"),
                  Text("Total: \$${order['total']}"),
                  Text("Status: ${order['status']}",
                      style: TextStyle(
                          color: order['status'] == 'Delivered'
                              ? Colors.green
                              : order['status'] == 'Shipped'
                                  ? Colors.orange
                                  : Colors.red)),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          );
        },
      ),
    );
  }
}
