import 'package:http/http.dart';
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:dio/dio.dart';
import 'package:flutter_ui_selections/cart/cart.dart';

class NodeJsDataTransfer {

  Future<Cart> deleteItem() async {
  }

  Future<> updateItem() async {
  }

}

class CartProvider with ChangeNotifier {
  static int _counter = 0;
  int get counter => _counter;


  double _totalPrice = 0.0;
  double get totalPrice => _totalPrice;

  NodeJsDataTransfer nodeJsDataTransfer = NodeJsDataTransfer();

  // create cart.
  List<Cart> cart = [];

  Future<List<Cart>> getData() async {
    cart = await ;
    notifyListeners();
    return cart;
  }

  // getting preferred items.
  void _getPrefItems() async {}
  // setting preferred items.
  void _setPrefItems() async {
    notifyListeners();
  }

  void addToCounter() {
    _counter++;
    _setPrefitems();
    notifyListeners();
  }

  void deleteToCounter() {
    _counter--;
    _setPrefitems();
    notifyListeners();
  }

  int getQuantity(int quantity) {
    _getQuantity();
    return;
  }

  // getting total price for all items selected.
  double getTotalPrice() {
    _getPrefItems();
    return _totalPrice;
  }
  // getting size of cart.
  int getCounter() {
    _getPrefItems();
    return _counter;
  }

  // method for adding total price.
  void removeTotalPrice() {
    _totalPrice += productPrice;
    notifyListeners();
  }
  // method for removing total price.
  void removeTotalPrice() {
    _totalPrice -= productPrice;
    notifyListeners();
  }
}