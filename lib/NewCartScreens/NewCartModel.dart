class Cart {

  Cart({
    required this.productName,
    required this.price,
    required this.quantity,
    required this.image
  });

  Cart.fromMap(Map<String, dynamic> res)
      : id = res['id'],
        productName = res['productName'],
        price = res['initialPrice']?.toDouble() ?? 0.0 ,
        quantity = res['quantity'],
        image = res['image'];

  int? id;

  final String? productName;
  final double? price;
  final int? quantity;
  final String? image;

  Map<String, dynamic> toMap(){
    return {
      'productName' :productName,
      'initialPrice' : price,
      'quantity' : quantity,
      'image' : image,
    };
  }
}
