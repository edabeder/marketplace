import 'package:flutter/material.dart';

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
      ),
      body: const Body(),
    );
  }
}
