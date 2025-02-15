// cart class for the cart objects.
class Cart {
  late final int? id;
  final String? productId;
  final String? productName;
  final int? productPrice;
  final int? size;
  final String? unitTag;
  final String? image;
  final String? status;

  //cart constructor to initialize values.
  Cart(
    {required this.id,
      required this.productId,
      required this.productName,
      required this.productPrice,
      required this.size,
      required this.unitTag,
      required this.image,
      required this.status,
    });

  Cart.fromMap(Map<dynamic, dynamic> data):
        id = data['id'],
        productId = data['productId'],
        productName = data['productName'],
        productPrice = data['productPrice'],
        size = data['size'],
        unitTag = data['unitTag'],
        image = data['image'],
        status = data['status'];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productPrice': productPrice,
      'size': size,
      'unitTag': unitTag,
      'image': image,
      'status': status,
    };
  }
}