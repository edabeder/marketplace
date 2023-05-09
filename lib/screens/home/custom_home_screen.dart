import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:postgres/postgres.dart';
import '../../NewCartScreens/Product.dart';
import '../../infrastructures/service/cubit/web3_cubit.dart';
import '../../module/PostgresDBConnector.dart';
import '/components/coustom_bottom_nav_bar.dart';
import '/enums.dart';

import 'components/body.dart';

class CustomHomeScreen extends StatefulWidget {

  static String routeName = '/home';

  @override
  State<CustomHomeScreen> createState() => _CustomHomeScreenState();
}

class _CustomHomeScreenState extends State<CustomHomeScreen> {

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Body(),
      bottomNavigationBar: CustomBottomNavBar(selectedMenu: MenuState.home),
    );
  }
}


