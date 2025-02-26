import 'package:flutter/material.dart';

/*void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Review Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ReviewPage(),
    );
  }
}*/

class ReviewPage extends StatefulWidget {
  const ReviewPage({Key? key}) : super(key: key);

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  late double averageRating;
  final String itemName = "Awesome Item";
  final List<Map<String, dynamic>> reviews = [];
  int selectedRating = 0; // Rating input for new review
  final TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Mock reviews for demonstration
    reviews.addAll([
      {"username": "User1", "rating": 4, "comment": "Great product!"},
      {"username": "User2", "rating": 5, "comment": "Exceeded expectations."},
      {"username": "User3", "rating": 3, "comment": "Good but could improve."},
    ]);

    // Calculate the average rating
    averageRating = reviews.isEmpty
        ? 0.0
        : reviews.map((e) => e["rating"] as int).reduce((a, b) => a + b) /
            reviews.length;
  }

  void addReview() {
    if (selectedRating > 0 && commentController.text.isNotEmpty) {
      setState(() {
        reviews.add({
          "username": "NewUser", // Replace with actual user data
          "rating": selectedRating,
          "comment": commentController.text,
        });
        // Recalculate average rating
        averageRating = reviews.map((e) => e["rating"] as int).reduce((a, b) => a + b) / reviews.length;
        // Reset input fields
        selectedRating = 0;
        commentController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review added successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a rating and comment.')),
      );
    }
  }

  Widget _buildStars(double rating, {double starSize = 20, bool interactive = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: interactive
              ? () {
                  setState(() {
                    selectedRating = index + 1;
                  });
                }
              : null,
          child: Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: starSize,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigates back when pressed
          },
        ),
        title: const Text(
          "Reviews",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true, // Centers the AppBar text
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item name
            Text(
              itemName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Average rating with stars
            Row(
              children: [
                Text(
                  "Average Rating: ${averageRating.toStringAsFixed(1)}",
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 10),
                _buildStars(averageRating),
              ],
            ),
            const SizedBox(height: 24),
            // Reviews list
            Expanded(
              child: ListView.builder(
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  final review = reviews[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review["username"],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _buildStars(review["rating"].toDouble()),
                              const SizedBox(width: 8),
                              Text(
                                "${review["rating"]}/5",
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            review["comment"],
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Add Review Section
            const Divider(),
            const Text(
              "Add Your Review",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildStars(selectedRating.toDouble(), interactive: true),
            const SizedBox(height: 8),
            TextField(
              controller: commentController,
              decoration: const InputDecoration(
                hintText: "Write your comment here...",
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: addReview,
              style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(color: Colors.black), // For text color
              ),
              child: const Text(
                "Submit Review",
                style: TextStyle(color: Colors.black), // Ensure text color is black
              ),
            ),
          ],
        ),
      ),
    );
  }
}
