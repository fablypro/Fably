import 'package:flutter/material.dart';

class ResultsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> recommendations;

  const ResultsScreen({super.key, required this.recommendations});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Accessory Recommendations")),
      body: recommendations.isEmpty
          ? Center(child: Text("No accessories found. Try another image."))
          : ListView.builder(
              itemCount: recommendations.length,
              itemBuilder: (context, index) {
                var item = recommendations[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: item.containsKey('image_url')
                        ? Image.network(item['image_url'], width: 50, height: 50, fit: BoxFit.cover)
                        : Icon(Icons.image, size: 50),
                    title: Text(item['name'] ?? 'Unknown Accessory'),
                    subtitle: Text("Match Score: ${item['score'].toString()}"),
                  ),
                );
              },
            ),
    );
  }
}
