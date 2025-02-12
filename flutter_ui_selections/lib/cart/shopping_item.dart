// cart class for the cart objects.
class Item {
  final String prodName;
  final int prodPrice;
  final String unit;
  final String img;

  //cart constructor to initialize values.
  Item({
        required this.prodName,
        required this.prodPrice,
        required this.unit,
        required this.img,
      });

  Map toJson() {
    return {
      "prodName: ": prodName,
      "prodPrice: ": prodPrice,
      "unit: ": unit,
      "img: ": img,
    };
  }
}