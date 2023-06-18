import 'package:flutter/material.dart';
import 'package:untitled1/HomePage.dart';
import 'package:untitled1/screens/home/components/trialProduct.dart';
import 'package:untitled1/screens/home/custom_home_screen.dart';
import 'package:untitled1/screens/home/homeComponent.dart';

import '../../../size_config.dart';
import 'categories.dart';
import 'discount_banner.dart';
import 'home_header.dart';
import 'popular_product.dart';
import 'special_offers.dart';

class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: getProportionateScreenHeight(20)),
            const HomeHeader(),
            SizedBox(height: getProportionateScreenWidth(10)),
            const DiscountBanner(),
            //const Categories(),
            //const SpecialOffers(),
            SizedBox(height: getProportionateScreenWidth(20)),
            //const PopularProducts(),
            HomeProducts(),
            SizedBox(height: getProportionateScreenWidth(30)),

          ],
        ),
      ),
    );
  }
}
