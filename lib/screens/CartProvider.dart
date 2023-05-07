import 'package:flutter/cupertino.dart';

import '../models/Cart.dart';
import '../models/Product.dart';

class CartProvider with ChangeNotifier {
  final List<Cart> _cartItems = [];

  List<Cart> get cartItems => _cartItems;

  void addToCart(Product product) {
    bool isExist = false;
    for (int i = 0; i < _cartItems.length; i++) {
      if (_cartItems[i].product.id == product.id) {
        _cartItems[i].numOfItem++;
        isExist = true;
        break;
      }
    }
    if (!isExist) {
      _cartItems.add(Cart(product: product, numOfItem: 1));
    }
    notifyListeners();
  }
}
