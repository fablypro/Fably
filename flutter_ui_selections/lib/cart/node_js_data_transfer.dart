import 'package:http/http.dart';
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:dio/dio.dart';
import 'package:flutter_ui_selections/cart/cart.dart';

class NodeJsDataTransfer {
  static;
}

class CartProvider with ChangeNotifier {
  NodeJsDataTransfer nodeJsDataTransfer = NodeJsDataTransfer();

  List<Cart> cart = [];

  Future<List<Cart>> getData() async {
    cart = await ;
    notifyListeners();
  }

  void addCounter() {
    _counter++;
    _setPrefitems();
    notifyListeners();
  }

  void deleteCounter() {
    _counter--;
    _setPrefitems();
    notifyListeners();
  }

  int getQuantity(int quantity) {
    _getQuantity();
  }

  double getTotalPrice() {
    _getPrefItems();
    return _totalPrice;
  }
  void removeTotalPrice() {
    _totalPrice = _totalPrice + _itemPrice;
    notifyListeners();
  }
}