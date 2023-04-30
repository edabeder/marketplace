import 'package:flutter/material.dart';
import 'package:untitled1/main.dart';
import 'package:untitled1/module/auth/interfaces/screens/authentication_screen.dart';
import '/screens/cart/cart_screen.dart';

import '../../../size_config.dart';
import 'search_field.dart';

class HomeHeader extends StatelessWidget {

  const HomeHeader({
    Key? key,
  }) : super(key: key);




  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SearchField(),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (BuildContext context) => const CartScreen()),
            ),
            icon: const Icon(Icons.shopping_cart),
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => MyHomePage(),
              ),
            ),
            icon: const Icon(Icons.home),
          ),

          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded ),
          ),
        ],
      ),
    );
  }
}
