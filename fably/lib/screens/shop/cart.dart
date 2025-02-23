import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For JSON decoding, if needed
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import 'checkout_screen.dart';
import '../auth/login.dart';

/*void main() {
  runApp(MyApp());
}*/

ElevatedButton backButton = ElevatedButton(
    style: ElevatedButton.styleFrom(
      foregroundColor: Color.fromARGB(255, 255, 255, 255),
      backgroundColor: Color.fromARGB(255, 0, 0, 0),
    ),
    child: Row(
      children: const [
        SizedBox(width: 4), // Padding to align properly
        Icon(Icons.arrow_back),
        /*SizedBox(width: 4), // Space between icon and text
        Text('Back', style: TextStyle(fontSize: 16)),*/
      ],
    ), // Back button icon
    
    onPressed: () {
      // Define the back button's action
      // Navigates back to the previous screen
    },
  );

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cart Page with Slidable',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CartPage(),
    );
  }
}

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {

  // Mock data for the cart items
  List<Map<String, dynamic>> cartItems = [
    {'name': 'Item 1', 'price': 10.0, 'quantity': 1, 'photos':['https://placehold.co/600x400/000000/FFFFFF/png']},
    {'name': 'Item 2', 'price': 15.0, 'quantity': 2, 'photos':['https://placehold.co/600x400/000000/FFFFFF/png']},
    {'name': 'Item 3', 'price': 20.0, 'quantity': 1, 'photos':['https://placehold.co/600x400/000000/FFFFFF/png']},
    {'name': 'Item 4', 'price': 20.0, 'quantity': 1, 'photos':['https://placehold.co/600x400/000000/FFFFFF/png']},
    {'name': 'Item 5', 'price': 20.0, 'quantity': 1, 'photos':['https://placehold.co/600x400/000000/FFFFFF/png']},
  ];

  

  String content = '';
  bool isLoading = false;

  //List<Map<String, dynamic>> jsonObject = jsonDecode(fetchWebContent());

  Future<String?> getPrefs(pref) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? value = prefs.getString(pref);
    return value;
  }

  Future<void> fetchWebContent() async{
    String cookies = '';
    Map userInfo = {};
    getPrefs('cookies').then((c){
      cookies = c ?? '';
      
    });
    getPrefs('userInfo').then((c){
      String userInfoStr = c ?? '{}';
      userInfo = jsonDecode(userInfoStr);
      
    });
    final url = Uri.parse('http://152.53.119.239:5000/products');
    // final url = Uri.parse('127.0.0.1:5000/get_cart/${userInfo['_id']}');

    try {
      final response = await http.get(
        url,
        headers: {
          'Cookie': cookies, // Add cookies to headers
        },
        );
      print('Response status: ${response.statusCode}');
      print(response.body);
      if (response.statusCode == 200) {
        setState(() {
          List<dynamic> jsonData = jsonDecode(response.body);
          cartItems = jsonData.map((item) => item as Map<String, dynamic>).toList();
          content = response.body;
          isLoading = false;
        });
      } else {
        setState(() {
          content = 'Failed to load content: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error occrued: $e');
      //print('Response status: ${response.statusCode}');
      setState(() {
        content = 'Error occurred: $e';
        isLoading = false;
      });
    }
  }

  Future<bool> removeFromCart(String id, int quantity) async {
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
    final url = Uri.parse('http://127.0.0.1:5000/remove_from_cart/${userInfo["_id"]}/');
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

  // Calculate the total price of items in the cart
  double get totalPrice =>
      cartItems.fold(0.0, (sum, item) => sum + item['price'] * item['quantity']);

  double deliveryPrice = 5.0;

  // Remove an item from the cart
  void removeItem(int index) {
    bool status = false;
    removeFromCart(cartItems[index]['_id'], 1).then((s){
      status = s;
    });

    if (status == false){
      print("An error occured whie trying to delete cart item");
    } else{
      setState(() {
        cartItems[index]['quantity']-=1;
      });
      if (cartItems[index]['quantity']>=0){
        setState(() {
          cartItems.removeAt(index);
        });
      }
    }    
  }

  void checkLoggedIn(context){
    if (getPrefs('userInfo') == Null || getPrefs('cookies') == Null){
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    
    cartItems = [
    {
        "_id": "67a8a99c364485eb1bc0cb44",
        "category": "Men's Clothing",
        "description": "The fabric, made from recycled polyester, absorb and wicks away perspiration for a drier feeling. It dries more quickly than a cotton T-shirt.\r\n\r\nOur design team developed this breathable men's running T-shirt to keep you dry in warm weather when running",
        "name": "Men's Running Quick Dry T-Shirt - Red",
        "photos": [
            "https://res.cloudinary.com/dldgeyki5/image/upload/v1739106715/mjk56p7ch1kof9dhtvux.png"
        ],
        "price": 17.7,
        "stock_quantity": 112
    },
    {
        "_id": "67a8b40ca037601816cd03a1",
        "category": "Men's Clothing",
        "description": "King Street Men's Long Sleeve Stripe Formal Shirt",
        "name": "King Street Men's Long Sleeve Stripe Formal Shirt",
        "photos": [
            "https://res.cloudinary.com/dldgeyki5/image/upload/v1739109386/yrkxruxwbxdfgve8aoig.jpg"
        ],
        "price": 3500.0,
        "stock_quantity": 20
    },
    {
        "_id": "67a8b4b6a037601816cd03a2",
        "category": "Women's Clothing",
        "description": "Envogue DAZZLE Women's Chic Party Dress",
        "name": "Envogue DAZZLE Women's Chic Party Dress",
        "photos": [
            "https://res.cloudinary.com/dldgeyki5/image/upload/v1739109557/it7qry2yqjtsrrxto0af.jpg",
            "https://res.cloudinary.com/dldgeyki5/image/upload/v1739109558/lxhcg9puius4ijsv8eyh.jpg"
        ],
        "price": 4500.0,
        "stock_quantity": 35
    },
    {
        "_id": "67a8b51ea037601816cd03a3",
        "category": "Footwear",
        "description": "Men's Chic Casual Sneakers",
        "name": "Men's Chic Casual Sneakers",
        "photos": [
            "https://res.cloudinary.com/dldgeyki5/image/upload/v1739109660/qypom6lveyvrddobnzzi.jpg",
            "https://res.cloudinary.com/dldgeyki5/image/upload/v1739109661/eeeknnubcldbd5bszz7g.jpg",
            "https://res.cloudinary.com/dldgeyki5/image/upload/v1739109662/m69x6oacgs8o28wy4xqq.jpg"
        ],
        "price": 8750.0,
        "stock_quantity": 15
    },
    {
        "_id": "67a8b62fa037601816cd03a4",
        "category": "Footwear",
        "description": "Modano Women's Chic Casual Sandal",
        "name": "Modano Women's Chic Casual Sandal",
        "photos": [
            "https://res.cloudinary.com/dldgeyki5/image/upload/v1739109935/k2vdelvfd7x0mkhkkod6.jpg"
        ],
        "price": 3990.0,
        "stock_quantity": 25
    },
    {
        "_id": "67a8b698a037601816cd03a5",
        "category": "Footwear",
        "description": "Modano Women's Chic Casual Sandal Heels",
        "name": "Modano Women's Chic Casual Sandal Heels",
        "photos": [
            "https://res.cloudinary.com/dldgeyki5/image/upload/v1739110039/yi7dlxmknt1vef39mfoq.jpg"
        ],
        "price": 4350.0,
        "stock_quantity": 35
    },
    {
        "_id": "67a8b75fa037601816cd03a6",
        "category": "Kids' Clothing",
        "description": "Miss Modano Kids Girls Short Sleeve Casual Frock",
        "name": "Miss Modano Kids Girls Short Sleeve Casual Frock",
        "photos": [
            "https://res.cloudinary.com/dldgeyki5/image/upload/v1739110238/qmmqgx1leab7kic7pmqg.jpg"
        ],
        "price": 7750.0,
        "stock_quantity": 30
    },
    {
        "_id": "67a8b80ba037601816cd03a7",
        "category": "Accessories",
        "description": "TITAN Men's Watch",
        "name": "TITAN Men's Watch",
        "photos": [
            "https://res.cloudinary.com/dldgeyki5/image/upload/v1739110411/b3hyvoxgcxkhtfsqquqy.jpg"
        ],
        "price": 24990.0,
        "stock_quantity": 5
    }
];
    fetchWebContent();
    for (int i=0;i<cartItems.length;i++) {
      cartItems[i]['quantity'] = 1; // Add or update the 'amount' field to 1
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("Checkout", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      /*appBar: AppBar(
        title: Text("Checkout", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        /*title:Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          
          children:[
            backButton,
            /*SizedBox(
              width: 105,
              //child:backButton,
            ),*/
            
            const SizedBox(height: 12),
            const Text(
              'Cart',
              style: TextStyle(
                fontSize: 35, // Set the font size
                fontWeight: FontWeight.bold, // Optional: Set font weight
              ),
            ),
          ],
        ),*/
        //centerTitle: true,
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        automaticallyImplyLeading: false, // Prevent default back button
        toolbarHeight: 130,
        //leading: backButton
      ),*/

      
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,// number of items in the cart
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return Slidable(
                    key: ValueKey(item['name']),
                    endActionPane: ActionPane(
                      extentRatio: 0.3,
                      motion: ScrollMotion(),
                      children: [
                        // Like Button
                        SlidableAction(
                          onPressed: (context) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${item['name']} liked!')),
                            );
                          },
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.black,
                          icon: Icons.favorite,
                          flex: 1, // Takes 1 units of space
                          //label: 'Like',
                        ),
                        SlidableAction(
                          onPressed: (context) => removeItem(index),
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.black,
                          icon: Icons.delete,
                          flex: 1, // Takes 1 units of space
                          //label: 'Delete',
                        ),
                      ],
                    ),
                    child: Card(// cart item display card
                      margin: EdgeInsets.symmetric(vertical: 5.0),
                      child: ListTile(
                        leading: Image.network( // image
                          item['photos'][0], // Replace this with your image URL
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover, // Ensures the image fills the space
                        ),
                        title: Text(item['name']),
                        subtitle:
                            Text('Price: \$${item['price']} x ${item['quantity']}'),
                      ),
                    ),
                  );
                },
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Items (${(cartItems.length)}):',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.white),
                      ),
                      Text(
                        '\$${(totalPrice).toStringAsFixed(2)}', // Example value for total items
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8), // Add spacing between rows
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Standard Delivery:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.white),
                      ),
                      Text(
                        '\$${deliveryPrice.toStringAsFixed(2)}', // Example delivery cost
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8), // Add spacing between rows
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        '\$${(totalPrice+deliveryPrice).toStringAsFixed(2)}', // Final total cost
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black, // Background color
                  backgroundColor: Colors.white, // Text and icon color
                ),
                onPressed: () {
                  // Handle checkout logic here
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Proceeding to Checkout...')),
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CheckoutScreen(),
                    ),
                  );
                  //Navigator.pushNamed(context, '/checkout');
                },
                child: Text('Checkout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
