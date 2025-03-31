import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:image_picker/image_picker.dart';
import 'package:loading_overlay/loading_overlay.dart';
//import 'package:file_picker/file_picker.dart';
//import 'package:mime/mime.dart';

void main() { runApp(AccessoryMatchApp()); }

class AccessoryMatchApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: 'Accessory Matcher',
            theme: ThemeData(primarySwatch: Colors.blue,),
            home: AccessoryMatcher(),
        );
    }
}

class AccessoryMatcher extends StatefulWidget {
    @override
    _AccessoryMatcherState createState() => _AccessoryMatcherState();
}

class _AccessoryMatcherState extends State<AccessoryMatcher> {

    final ImagePicker _picker = ImagePicker();
    
    final Map<String, XFile?> _imageFiles = {};
    final Map<String, String> _accessoryColors = {};
    final Map<String, String> _outfitColors = {};
    final Map<String, String> _outfitTypes = {};

    Map<String, dynamic> _results = {};
    bool _isLoading = false;

    final List<String> _accessoryTypes = ['belts', 'chains', 'glasses', 'gloves', 'handbags', 'hats', 'rings', 'shoes', 'socks', 'watches'];

    final List<String> _ouftitCatgories = ['activewear', 'bohemian', 'casual', 'eveningwear', 'formal', 'indie', 'knitwear', 'loungewear', 'retro', 'romantic', 'smartcasual', 'sporty', 'vintage'];

    final List<String> _colorsList = ['Amber', 'Black', 'Blue', 'Emerald', 'Gold', 'Green', 'Grey', 'Indigo', 'Jade', 'Lemon', 'Lilac', 'Lime', 'Midnight Blue', 'Mint Green', 'Navy Blue', 'Olive', 'Orange', 'Peach', 'Pink', 'Platinum', 'Plum', 'Purple', 'Red', 'Rose', 'Ruby', 'Sapphire', 'Scarlet', 'Silver', 'Turquoise', 'Ultramarine', 'Violet', 'White', 'Yellow', 'Zucchini'];
    
    @override
    void initState() {
        super.initState();
        for (var type in _accessoryTypes) {
            _accessoryColors[type] = ''; // image upload for accessory colors.
            _imageFiles[type] = null; // image upload for accessories.
        }

        for (var type in _ouftitCatgories) {
            _outfitColors[type] = ''; // image upload for outfit colors.
            _outfitTypes[type] = ''; // image upload for outfit types.
            _imageFiles[type] = null; // image upload for outfits.
        }
    }

    Future<void> _pickImage(String type) async {
        XFile? image = await _picker.pickImage(source: ImageSource.gallery);
        if (image != null) {
            setState(() {
                _imageFiles[type] = image;
            });
        }
    }

    Future<void> _uploadImages() async {
        setState(() {
            _isLoading = false;
            _results = {};
        }); // setting states for loading and results.

        try {
            var formData = dio.FormData();

            _imageFiles.forEach((key, value) async {
                if (value != null) {
                    formData.files.add(MapEntry(key, await dio.MultipartFile.fromFile(value.path)));
                }
            });
            
            _accessoryColors.forEach((key, value) { formData.fields.add(MapEntry('accessory_${key}_color', value)); });

            _outfitTypes.forEach((key, value) { formData.fields.add(MapEntry('outfit_${key}_type', value)); });

            _outfitColors.forEach((key, value) { formData.fields.add(MapEntry('outfit_${key}_color', value)); });

            var response = await dio.Dio().post(
              'http://127.0.0.1:5000/match', 
              data: formData
            );
            
            setState(() {
              _results = response.data;
              _isLoading = true;});
        }
        catch (e) {
            setState(() {
              _results = {'error': e.toString()};
              _isLoading = false;});
        }
    }

    Widget _buildSection(String title, Map<String, dynamic> data) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${title}', style: TextStyle(fontWeight: FontWeight.w500),),
            for (var key in data.keys)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text('$key: ${jsonEncode(data[key])}'),
              ),
            SizedBox(height: 10,),
          ],
      );
    }

    Widget _buildResults() {
      if (_results.isNotEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20,),
            Text("Matching Results: ", style: TextStyle(fontSize: 18.5, fontWeight: FontWeight.bold),),
            SizedBox(height: 10,),
            if (_results['error'] != null) Text("Error: ${_results['error']}", style: TextStyle(color: Colors.red),),

            if (_results['feature similarity'] != null) _buildSection("Feature Similarity", _results['feature similarity']),
            if (_results['image color match'] != null) _buildSection("Image Color Match", _results['image color match']),
            if (_results['image color delta e'] != null) _buildSection("Image Color Delta E", _results['image color delta e']),
            if (_results['provided color match'] != null) _buildSection("Provided Color Match", _results['provided color match']),
          ],
        );
      } else {
        return SizedBox.shrink();
      }
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(title: Text('Accessory Matching')),
            body: LoadingOverlay(
                    isLoading: _isLoading, 
                    child: SingleChildScrollView(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                        children: [
                            Text('Accessory Matching With Outfits', style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
                            SizedBox(height: 20),
                            Text('Outfit Image', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500)),
                            DropdownButtonFormField<String>(
                              value: _outfitTypes.keys.firstWhere(
                                (k) => _imageFiles[k] != null, 
                                orElse: () => null), 
                              items: _ouftitCatgories.map((String value) {
                                return DropdownMenuItem(
                                  value: value, 
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                // clearing previous outift selections.
                                setState(() {
                                  for (var key in _ouftitCatgories) {
                                    _imageFiles[key] = null;
                                  }
                                  _pickImage(newValue!);
                                });
                              },
                              decoration: InputDecoration(labelText: "Choose Outfit Style"),
                            ),
                            SizedBox(height: 10),
                            if (_imageFiles.keys.any((k) => _ouftitCatgories.contains(k) &&
                                 _imageFiles[k] != null))
                              Image.file(
                                File(),
                              ),
                            
                            SizedBox(height: 20),
                            Text('Accessory Images', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500)),
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: _accessoryTypes.map((type) {
                                return Column(
                                );
                              }).toList(),
                            ),

                            SizedBox(height: 20),
                            Text('Accessory Images', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500)),
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: _accessoryTypes.map((type) {
                                return DropdownButtonFormField(
                                );
                              }).toList(),
                            ),

                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _uploadImages, 
                              child: Text("Match Outfits With Accessories"),
                            ),
                            _buildResults(),
                        ],
                    ),
                ),
            ),
        );
    }
}






