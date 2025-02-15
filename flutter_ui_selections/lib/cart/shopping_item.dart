// cart class for the cart objects.
class Item {
  final String prodName;
  final int prodPrice;
  final int size;
  final String unit;
  final String img;
  final String status;

  //cart constructor to initialize values.
  Item({
        required this.prodName,
        required this.prodPrice,
        required this.size,
        required this.unit,
        required this.img,
        required this.status,
      });

  Map toJson() {
    return {
      "prodName": prodName,
      "prodPrice": prodPrice,
      "size": size,
      "unit": unit,
      "img": img,
      "status": status,
    };
  }
}