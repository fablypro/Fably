import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants.dart';

class ApiService {
  static Future<List<Map<String, dynamic>>> uploadImage(File imageFile) async {
    try {
      var request = http.MultipartRequest("POST", Uri.parse("${Constants.baseUrl}/upload"));
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonData = jsonDecode(responseData);
        
        if (jsonData.containsKey('recommended_accessories')) {
          return List<Map<String, dynamic>>.from(jsonData['recommended_accessories']);
        } else {
          throw Exception("Invalid response format: Missing 'recommended_accessories'");
        }
      } else {
        throw Exception("Failed to upload image. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error uploading image: $e");
    }
  }
}
