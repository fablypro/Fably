// necessary packages.
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// cart class for the cart objects.
class Cart {
  final int? id;
  final String? productId;
  final String? productName;
  final int? productPrice;
  final ;
  final ;
  final String? image;

  //cart constructor to initialize values.
  Cart(
    {
      required this.id,
      required this.productId,
      required this.productName,
      required this.productPrice,
      required this.image,
    }
  );

  Cart.fromMap(Map<dynamic, dynamic> data)
      : id = data['id'],
        productId = data['productId'],
  productName = data['productName'];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
    };
  }
}