// cart class for the cart objects.
class Cart {
  late final int? id;
  final String? productId;
  final String? productName;
  final int? productPrice;
  final String? unitTag;
  final String? image;

  //cart constructor to initialize values.
  Cart(
    {required this.id,
      required this.productId,
      required this.productName,
      required this.productPrice,
      required this.unitTag,
      required this.image,
    });

  Cart.fromMap(Map<dynamic, dynamic> data):
        id = data['id'],
        productId = data['productId'],
        productName = data['productName'],
        productPrice = data['productPrice'],
        unitTag = data['unitTag'],
        image = data['image'];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productPrice': productPrice,
      'unitTag': unitTag,
      'image': image,
    };
  }
}