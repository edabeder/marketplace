import 'package:flutter/material.dart';
import 'package:untitled1/screens/splash/splash_screen.dart';

import '../../size_config.dart';
import 'components/body.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In', style: TextStyle(fontSize: getProportionateScreenWidth(20),) ),
        backgroundColor: Color(0xFFfe6796),
        leading: IconButton(
          icon: Icon(Icons.arrow_back ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (BuildContext context) => SplashScreen(),),);
          },
        ),
      ),
      body: const Body(),
    );
  }
}
