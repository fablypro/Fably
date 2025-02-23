import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../utils/requests.dart';

class SelectProductPage extends StatefulWidget {
  @override
  _SelectProductPageState createState() => _SelectProductPageState();

  File? userImage;

  SelectProductPage({super.key, this.userImage});

}



class _SelectProductPageState extends State<SelectProductPage> {
  List<dynamic> products = [];
  bool isLoading = true;

  void _showMessage(String message) {
    print(message);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchProducts();
    });
  }

  Future<void> fetchProducts() async {
    final requests = BackendRequests(); // Replace with your backend URL
    try {
      final response = await requests.getRequest('products');

      if (response.statusCode == 200 || response.statusCode == 201 ) {
        setState(() {
          products = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching products: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Virtual Try-On Selection'),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? Center(child: Text('No products available'))
              : Padding(
                padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: products.length,// number of items in the cart
                          itemBuilder: (context, index) {
                            final item = products[index];
                            return Card(// cart item display card
                              margin: EdgeInsets.symmetric(vertical: 5.0),
                              
                              child: ListTile(
                                leading: Image.network( // image
                                  item['photos'][0], // Replace this with your image URL
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover, // Ensures the image fills the space
                                ),
                                title: Text(item['name']),
                                onTap: () {
                                    _showMessage("Virtual Try-On function...");
                                  },
                                /*subtitle:
                                    Text('Price: \$${item['price']} x ${item['quantity']} = \$${(item['price'] * item['quantity']).toStringAsFixed(2)}'),*/
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final dynamic product;
  final VoidCallback onSelect;

  const ProductCard({super.key, required this.product, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            child: Image.network(
              product['image'],
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported, size: 100),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'],
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  product['description'] ?? '',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onSelect,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            child: Text('Select'),
          ),
        ],
      ),
    );
  }
}
