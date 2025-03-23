import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import 'results_screen.dart';

class MatchingScreen extends StatefulWidget {
  const MatchingScreen({super.key});

  @override
  _MatchingScreenState createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  // Function to pick an image
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Function to upload image and navigate to results
  Future<void> _uploadImage() async {
    if (_selectedImage == null) {
      _showSnackbar("Please select an image first.");
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      List<Map<String, dynamic>> recommendations = await ApiService.uploadImage(_selectedImage!);
      
      // Navigate to results screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsScreen(recommendations: recommendations),
        ),
      );
    } catch (e) {
      _showSnackbar("Upload failed: ${e.toString()}");
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  // Function to show error messages
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Match Accessories"), backgroundColor: Colors.black),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _selectedImage != null
                    ? Image.file(_selectedImage!, fit: BoxFit.cover)
                    : Icon(Icons.image, size: 50, color: Colors.white),
              ),
            ),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: _isUploading ? null : _uploadImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: _isUploading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Upload Image", style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
