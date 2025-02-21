// cart class for the cart objects.
class Cart {
  late final int? id;
  final String? productId;
  final String? productName;

  final int? initPrice;
  final int? productPrice;

  final int? size;

  final ValueNotifier<int>? quantity;

  final String? unitTag;
  final String? image;
  final String? status;

  //cart constructor to initialize values.
  Cart({
    required this.id,
    required this.productId,
    required this.productName,
    required this.initPrice,
    required this.productPrice,
    required this.size,
    required this.quantity,
    required this.unitTag,
    required this.image,
    required this.status,
  });

  // getting data variables from mapping of cart.
  Cart.fromMap(Map<dynamic, dynamic> data):
        id = data['id'],
        productId = data['productId'],
        productName = data['productName'],
        productPrice = data['productPrice'],
        size = data['size'],
        initPrice = ValueNotifier(data['initPrice']),
        unitTag = data['unitTag'],
        image = data['image'],
        status = data['status'];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'initPrice': initPrice,
      'productPrice': productPrice,
      'size': size,
      'quantity': quantity?.value,
      'unitTag': unitTag,
      'image': image,
      'status': status,
    };
  }
}