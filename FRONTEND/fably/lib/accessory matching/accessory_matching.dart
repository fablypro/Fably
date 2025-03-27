import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:image_picker/image_picker.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mime/mime.dart';

void main() { runApp(AccessoryMatchApp()); }

class AccessoryMatchApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: 'Accessory Matcher',
            theme: ThemeData( primarySwatch: Colors.blue, ),
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
    Map<String, XFile?> _imageFiles = {};
    Map<String, String> _accessoryColors = {};
    Map<String, String> _outfitColors = {};
    Map<String, String> _outfitTypes = {};
    Map<String, dynamic> _results = {};
    bool _isLoading = false;

    final List<String> _accessoryTypes = ['belts', 'chains', 'glasses', 'gloves', 'handbags', 'hats', 'rings', 'shoes', 'socks', 'watches'];

    final List<String> _ouftitCatgories = ['activewear', 'bohemian', 'casual', 'eveningwear', 'formal', 'indie', 'knitwear', 'loungewear', 'retro', 'romantic', 'smartcasual', 'sporty', 'vintage'];

    final List<String> _colorsList = ['Amber', 'Black', 'Blue', 'Emerald', 'Gold', 'Green', 'Grey', 'Indigo', 'Jade', 'Lemon', 'Lilac', 'Lime', 'Midnight Blue', 'Mint Green', 'Navy Blue', 'Olive', 'Orange', 'Peach', 'Pink', 'Platinum', 'Plum', 'Purple', 'Red', 'Rose', 'Ruby', 'Sapphire', 'Scarlet', 'Silver', 'Turquoise', 'Ultramarine', 'Violet', 'White', 'Yellow', 'Zucchini'];
    
    @override
    void initState() {
        super.initState();
        for (var type in _accessoryTypes) {
            _accessoryColors[type] = '';
            _imageFiles[type] = null;
        }

        for (var type in _ouftitCatgories) {
            _outfitColors[type] = '';
            _outfitTypes[type] = '';
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
        });

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

            var response = await dio.Dio().post('Fably/BACKEND/python accessory matching py files/static/images', data: formData);
            setState(() {
              _results = response.data;
              _isLoading = true;
            });
        }
        catch (e) {
            setState(() {
              _results = {'error': e.toString()};
              _isLoading = false;
            });
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
                            Text('Accessories', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500)),
                            ..._accessoryTypes.map((type) {
                                    Column(
                                        children: [
                                            Text('Choose ${type.toUpperCase()} Color'),
                                            DropdownButtonFormField<String>(
                                                value: _accessoryColors[type],
                                                items: _colorsList.map((String value) {
                                                    return DropdownMenuItem<String>(
                                                        value: value,
                                                        child: Text(value),
                                                    );
                                                }).toList(), 
                                                onChanged: (String? newValue) {
                                                    setState(() {
                                                        _accessoryColors[type] = newValue!;
                                                    });
                                                },
                                                decoration: InputDecoration(labelText: "Choose ${type.toUpperCase()} Color"),
                                            ),
                                            SizedBox(height: 10),
                                            ElevatedButton(
                                                onPressed: () => _pickImage(type), 
                                                child: Text('Upload ${type.toUpperCase()} Image'),
                                            ),
                                            if (_imageFiles[type] != null) Image.file(File(_imageFiles[type]!.path), height: 100),
                                            SizedBox(height: 20),
                                        ],
                                    );
                                    Text('Outfits', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500));
                                    for (var type in _ouftitCatgories) {
                                        Column(
                                            children: [
                                                DropdownButtonFormField(
                                                    value: _outfitTypes[type],
                                                    items: _ouftitCatgories.map((String value) {
                                                        return DropdownMenuItem<String>(
                                                            value: value,
                                                            child: Text(value),
                                                        );
                                                    }).toList(), 
                                                    onChanged: (String? newValue) {
                                                        setState(() {
                                                            _outfitTypes[type] = newValue!;
                                                        });
                                                    },
                                                    decoration: InputDecoration(labelText: "Choose Outfit Style"),
                                                ),
                                                SizedBox(height: 10),
                                                ElevatedButton(
                                                    onPressed: () => _pickImage(type), 
                                                    child: Text('Upload ${type.toUpperCase()} Image'),
                                                ),
                                                if (_imageFiles[type] != null) Image.file(File(_imageFiles[type]!.path), height: 100),
                                                SizedBox(height: 20),
                                            ],
                                        );
                                        ElevatedButton(
                                            onPressed: _uploadImages,
                                            child: Column(
                                                children: [
                                                    Text('Match Images'),
                                                    if (_results.isNotEmpty) Text(jsonEncode(_results), style: TextStyle(fontSize: 16.0)),
                                                ],
                                            ),
                                        );
                                    }
                                }
                            ),
                        ],
                    ),
                ),
            ),
        );
    }
}






