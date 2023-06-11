import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:untitled1/module/auth/interfaces/screens/authentication_screen.dart';

import '../../../size_config.dart';

class DiscountBanner extends StatelessWidget {
  const DiscountBanner({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the desired screen here
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AuthenticationScreen()),
        );
      },
      child: Container(
        // height: 90,
        width: double.infinity,
        margin: EdgeInsets.all(getProportionateScreenWidth(20)),
        padding: EdgeInsets.symmetric(
          horizontal: getProportionateScreenWidth(20),
          vertical: getProportionateScreenWidth(15),
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF4A3298),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/meta.svg.png',
              width: getProportionateScreenWidth(60),
            ),
            const SizedBox(width: 10),
            Text.rich(
              TextSpan(
                style: const TextStyle(color: Colors.white),
                children: [
                  const TextSpan(text: 'To Continue Shopping, \n'),
                  TextSpan(
                    text: 'Connect to Metamask',
                    style: TextStyle(
                      fontSize: getProportionateScreenWidth(22),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
