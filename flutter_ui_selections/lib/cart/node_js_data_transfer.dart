import 'package:http/http.dart';
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_ui_selections/cart/cart.dart';

class NodeJsDataTransfer {
  static;
}

class CartProvider with ChangeNotifier {
  NodeJsDataTransfer nodeJsDataTransfer = NodeJsDataTransfer();

  List<Cart> cart = [];

  Future<List<Cart>> getData() async {
    cart =;
  }
}