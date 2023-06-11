import 'package:flutter/material.dart';
import '../../size_config.dart';
import '/components/coustom_bottom_nav_bar.dart';
import '/enums.dart';

import 'components/body.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  static String routeName = '/profile';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text('Profile', style: TextStyle(fontSize: getProportionateScreenWidth(20))),
        backgroundColor: Color(0xFFfe6796),
      ),
      body: const Body(),
      bottomNavigationBar:
          const CustomBottomNavBar(selectedMenu: MenuState.profile),
    );
  }
}
