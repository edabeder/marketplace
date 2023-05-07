import 'package:flutter/material.dart';
import '/components/coustom_bottom_nav_bar.dart';
import '/enums.dart';

import 'components/body.dart';

class CustomHomeScreen extends StatelessWidget {
  const CustomHomeScreen({super.key});

  static String routeName = '/home';
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Body(),
      bottomNavigationBar: CustomBottomNavBar(selectedMenu: MenuState.home),
    );
  }
}
