import 'dart:convert';

import 'package:fably/screens/scanner/individual_try_on.dart';
import 'package:fably/utils/requests.dart';
import 'package:flutter/material.dart';

class VtonHistoryPage extends StatefulWidget {
  const VtonHistoryPage({Key? key}) : super(key: key);

  @override
  _VtonHistoryPageState createState() => _VtonHistoryPageState();
}

class _VtonHistoryPageState extends State<VtonHistoryPage> {
  // Dummy data representing VTON history
  List<dynamic> vtonHistory = [];

  @override
  void initState() {
    super.initState();
    // Fetch or initialize the VTON history data
    fetchVtonHistory();
  }

  void _showMessage(String message) {
    print(message);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> getVtonStatus(index) async {
    final requests = BackendRequests();

    try {
      final response = await requests.postRequest("vton/fetch_url/", body: {
        "vton_id": vtonHistory[index]['vtonId'],
        "item_id": vtonHistory[index]['itemId'],
      });

      if (response.statusCode == 200) {
        if (response.body == "processing") {
          _showMessage("Still processing image");
        } else {
          setState(() {
            vtonHistory[index]['status'] = "completed";
          });
          _showMessage("Your try on is ready");
        }
        //_showMessage('POST request successful: ${response.body}');
      } else {
        print('Failed to send POST request: ${response.statusCode}');
      }
    } catch (error) {
      print('Error occurred while sending POST request: $error');
    }
  }

  void fetchVtonHistory() async {
    // Simulating an API call or database fetch
    final requests = BackendRequests();

    final response = await requests.getRequest('vton_history/');

    if (response.statusCode == 200) {
      print(response.body);
      setState(() {
        vtonHistory = jsonDecode(response.body);
      });
      //image_url = response.body;
    } else {
      _showMessage('Fetching Failed: ${response.body}');
    }
  }

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
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true, // Centers the title
      ),
      body: vtonHistory.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: vtonHistory.length,
              itemBuilder: (context, index) {
                final item = vtonHistory[index];
                return InkWell(
                  onTap: () {
                    // if the image is still processing
                    if (vtonHistory[index]['status'] == 'processing') {
                      getVtonStatus(index);
                    } else {
                      String itemName = vtonHistory[index]['name'];
                      String personImageUrl = vtonHistory[index]['personPhoto'];
                      String clothPhoto = vtonHistory[index]['clothPhoto'];
                      String vtonPhoto = vtonHistory[index]['imageUrl'];

                      // Navigator.push here.
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TryOnPage(
                            clothingImageUrl: clothPhoto,
                            personImageUrl: personImageUrl,
                            tryOnImageUrl: vtonPhoto,
                            productName: itemName,
                          ),
                        ),
                      );

                    }
                  },
                  borderRadius: BorderRadius.circular(
                      10), // Ensure ripple effect matches card shape
                  child: Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: item["status"] == "processing"
                                ? SizedBox(
                                    height:
                                        180, // Match the image height for alignment
                                    width: double.infinity,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment
                                          .center, // Center vertically
                                      crossAxisAlignment: CrossAxisAlignment
                                          .center, // Center horizontally
                                      children: [
                                        Icon(
                                          Icons.hourglass_empty,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          "Processing",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : AspectRatio(
                                    aspectRatio: 3 / 4,
                                    child: Image.network(
                                      item["imageUrl"]!,
                                      height: 180,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(Icons.error,
                                            size: 50);
                                      },
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            item["name"] ?? "Unknown Item",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
