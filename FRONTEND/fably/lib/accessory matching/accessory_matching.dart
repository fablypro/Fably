import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:loading_overlay/loading_overlay.dart';
import 'package:file_picker/file_picker.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:path/path.dart' as path;

void main() {
    runApp(MyApp());
}

class MyApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: 'Accessory Matcher',
            theme: ThemeData(
                primarySwatch: Colors.blue,
            ),
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
    Map<String, XFile?> _colors = {};
    Map<String, XFile?> _results = {};

    bool _isLoading = false;


    final List<String> _accessoryTypes = ['belts', 'chains',
                                    'glasses', 'gloves',
                                    'handbags', 'hats',
                                    'rings', 'shoes',
                                    'socks', 'watches'];

    final List<String> _ouftitTypes = ['activewear', 'bohemian',
                                    'casual', 'eveningwear',
                                    'formal', 'indie',
                                    'knitwear', 'loungewear',
                                    'retro', 'romantic',
                                    'smartcasual', 'sporty',
                                    'vintage'];

    @override
    void initState() {
        super.initState();
        for (var type in _accessoryTypes) {
            _colors[type] = '';
        }

        for (var type in _ouftitTypes) {
            _colors[type] = '';
        }
    }

    Future<void> _pickImage(String accessoryType, String ouftitType) async {
        XFile? image = await _picker.pickImage(source: ImageResource.gallery);
        if (image != null) {
            setState(() {
                _imageFiles[accessoryType] = image;
            });
        };

        if (image != null) {
            setState(() {
                _imageFiles[accessoryType] = image;
            });
        };
    }

    Future<void> _uploadImages() async {
        setState(() {
            _isLoading = true;
            _results = {};
        });

        final var uri = Uri.parse('uri');

        try {
            var request = http.MultipartRequest('POST', uri);
        }
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(title: Text('Accessory Matching')),
            body: _isLoading
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                        children: [
                            Text('Accessory Matching With Outfits',
                            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
                            SizedBox(height: 20),
                            for ()
                        ],
                    ),
                ),
        );
    }
}






