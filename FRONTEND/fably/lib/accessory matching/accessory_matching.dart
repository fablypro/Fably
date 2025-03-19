import 'package: flutter/material.dart';
import 'dart: convert';
import 'dart: io';
import 'package: image_picker/image_picker.dart';
import 'package: http/http.dart' as http;

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
    ImagePicker _picker = ImagePicker();
}






