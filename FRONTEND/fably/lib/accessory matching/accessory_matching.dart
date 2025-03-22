import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
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
    Map<String, XFile?> _images = {
        'belts': null,
        'chains': null,
        'glasses': null,
        'gloves': null,
        'handbags': null,
        'hats': null,
        'rings': null,
        'shoes': null,
        'socks': null,
        'watches': null,

        'outfit': null,
    };

    Map<String, dynamic> _results = {};
    bool _isLoading = false;

    Future<void> _pickImage(String type) async {
        XFile? image = await _picker.pickImage(source: ImageResource.gallery);
        if (image != null) {
            setState(() {
                _images[type] = image;
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
            appBar: AppBar(
                title: Text('Accessory Matching'),
                backgroundColor: Colors.black,
                actions: [
                ],
            )
            );
    }
}






