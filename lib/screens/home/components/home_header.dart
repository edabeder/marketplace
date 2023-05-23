import 'package:badges/badges.dart' as badges;
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/main.dart';
import 'package:untitled1/module/auth/interfaces/screens/authentication_screen.dart';
import 'package:untitled1/screens/sign_up/register_page.dart';
import 'package:untitled1/screens/sign_up/sign_up_screen.dart';
import '../../../NewCartScreens/NewCartProvider.dart';
import '../../../NewCartScreens/new_cart_screen.dart';
import '/screens/cart/cart_screen.dart';

import '../../../size_config.dart';
import 'search_field.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CartProvider cart  = Provider.of<CartProvider>(context);
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
              MaterialPageRoute(
                  builder: (BuildContext context) => const CartScreen()),
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
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => RegisterPage(),
              ),
            ),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          InkWell(
            onTap: (){
              Navigator.push(context,MaterialPageRoute(builder: (BuildContext context) => const NewCartScreen()));
            },
            child: const Icon(Icons.shopping_bag_outlined),
          ),
        ],
      ),
    );
  }
}
