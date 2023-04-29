import 'package:flutter/material.dart';
import 'package:untitled1/Metamask/metamask_screen.dart';
import 'package:untitled1/module/auth/interfaces/screens/authentication_screen.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:web3dart/web3dart.dart';
import '../../../configs/web3_config.dart';
import '/screens/cart/cart_screen.dart';

import '../../../size_config.dart';
import 'search_field.dart';

class HomeHeader extends StatelessWidget {

  HomeHeader({
    Key? key,
  }) : super(key: key);




  Widget build(BuildContext context) {
    return Padding(
      padding:
      EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SearchField(),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CartScreen()),
            ),
            icon: Icon(Icons.shopping_cart),
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AuthenticationScreen(),
              ),
            ),
            icon: Icon(Icons.home),
          ),

          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_rounded ),
          ),
        ],
      ),
    );
  }
}
