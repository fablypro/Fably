import 'package:flutter/material.dart';

class TryOnPage extends StatelessWidget {
  final String clothingImageUrl;
  final String personImageUrl;
  final String tryOnImageUrl;
  final String productName;

  const TryOnPage({
    super.key,
    required this.clothingImageUrl,
    required this.personImageUrl,
    required this.tryOnImageUrl,
    required this.productName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back to the previous screen
          },
        ),
        backgroundColor: Colors.black,
        title: const Text(
          "Try-On History",
          style: TextStyle(
            fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: true, // Centers the title
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Row(
                children:[
                  Expanded(
                    child:Text(
                      productName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ]
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            const Text(
                              'Clothing',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Image.network(
                              clothingImageUrl,
                              height: 150,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 150.0,
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Icon(
                                      Icons.error,
                                      color: Colors.red,
                                      size: 40.0,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            const Text(
                              'Person',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Image.network(
                              personImageUrl,
                              height: 150,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 150.0,
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Icon(
                                      Icons.error,
                                      color: Colors.red,
                                      size: 40.0,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(
                thickness: 1.5,
                color: Colors.grey,
              ),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const Text(
                        'Try-On Result',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Image.network(
                        tryOnImageUrl,
                        height: 400,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 400.0,
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(
                                Icons.error,
                                color: Colors.red,
                                size: 40.0,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
