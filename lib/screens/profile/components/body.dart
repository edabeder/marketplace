import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled1/module/home/interfaces/screens/home_screen.dart';

import '../../../infrastructures/service/cubit/web3_cubit.dart';
import '../../../theme.dart';
import '../../sign_in/sign_in_screen.dart';
import 'package:flutter/material.dart';
import '../order_screen.dart';
import 'profile_menu.dart';
import 'profile_pic.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class Body extends StatelessWidget {
  const Body({super.key});

  Future<void> logout(BuildContext context) async {
    final response =
        await http.post(Uri.parse('http://10.0.2.2:3000/api/logout'));
    if (response.statusCode == 200) {
      // İstek başarılı, logout işlemi tamamlandı
      // İstediğiniz ek işlemleri burada yapabilirsiniz

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => const SignInScreen()),
      );
    } else {
      // İstek başarısız, hata mesajını göster veya uygun işlemi yap
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Logout failed. Please try again.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  Future<void> getOrders(BuildContext context, String customerId) async {
    final response = await http
        .get(Uri.parse('http://10.0.2.2:3000/api/history/$customerId'));
    if (response.statusCode == 200) {
      // İstek başarılı, orders verilerini kullanabilirsiniz
      // İstediğiniz işlemleri burada yapabilirsiniz
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => const OrdersScreen()),
      );
    } else {
      // İstek başarısız, hata mesajını göster veya uygun işlemi yap
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to fetch orders. Please try again.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          //const ProfilePic(),
          const SizedBox(height: 20),
          // ProfileMenu(
          //   text: 'My Account',
          //   icon: 'assets/icons/User Icon.svg',
          //   press: () => {},
          // ),
          // ProfileMenu(
          //   text: 'Notifications',
          //   icon: 'assets/icons/Bell.svg',
          //   press: () {},
          // ),
          // ProfileMenu(
          //   text: 'Settings',
          //   icon: 'assets/icons/Settings.svg',
          //   press: () {},
          // ),
          ProfileMenu(
              text: 'Orders',
              icon: 'assets/icons/Question mark.svg',
              press: () => getOrders(context, '5')),
          ProfileMenu(
            text: 'Log Out',
            icon: 'assets/icons/Log out.svg',
            press: () => logout(context),
          ),
        ],
      ),
    );
  }
}
