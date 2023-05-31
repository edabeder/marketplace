import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../constants.dart';
import '../../size_config.dart';
import '../home/custom_home_screen.dart';
import '../../../components/default_button.dart';
import 'package:flutter/material.dart';
import '../seller/seller_screen.dart';
import '../sign_in/sign_in_screen.dart';
import '../splash/splash_screen.dart';
import '/configs/themes.dart';

import 'dart:async';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  static String routeName = '/register_page';
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Add User',
      home: AddUserScreen(),
      color: Color(0xFFfe6796),
    );
  }
}

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  _AddUserScreenState createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  String dropdownValue = 'Buyer'; // initial dropdown value
  String? userType;
  bool isRegistered = false;
  final _formKey = GlobalKey<FormState>();
  final _fnameController = TextEditingController();
  final _lnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordController2 = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _sellerController = TextEditingController();
  final _customerController = TextEditingController();

  @override
  void dispose() {
    _fnameController.dispose();
    _lnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordController2.dispose();
    _phoneController.dispose();
    _birthdayController.dispose();
    _sellerController.dispose();
    _customerController.dispose();
    super.dispose();
  }

  String? _validateFormField(String? value, String fieldName) {
    if (value?.isEmpty ?? true) {
      return '$fieldName is required';
    }
    return null;
  }

  void _navigateToHome() {
    if (dropdownValue == 'Buyer') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CustomHomeScreen()),
      );
    } else if (dropdownValue == 'Seller') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => const SplashScreen()),
      );
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final url = 'http://10.0.2.2:3000/api/register';
      final response = await Dio().post(url, data: {
        'fname': _fnameController.text,
        'lname': _lnameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'password2': _passwordController2.text,
        'phonenumber': _phoneController.text,
        'dateofbirth': _birthdayController.text,
        'isseller': userType,
      });

      print('normal deneme');
      if (response.statusCode == 201) {
        print('is denemesi');
        // Kullanıcı başarıyla eklendi
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User added to database'),
          ),
        );

        print('if denemesi 2');

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => const SignInScreen()),
        );

        // return true if registration was successful
      }
    } // return false if form validation failed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add User'),
        backgroundColor: Color(0xFFfe6796),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _fnameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                  ),
                  validator: (String? value) =>
                      _validateFormField(value, 'First Name'),
                ),
                TextFormField(
                  controller: _lnameController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                  ),
                  validator: (String? value) =>
                      _validateFormField(value, 'Last Name'),
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (String? value) =>
                      _validateFormField(value, 'Email'),
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                  ),
                  obscureText: true,
                  validator: (String? value) =>
                      _validateFormField(value, 'Password'),
                ),
                TextFormField(
                  controller: _passwordController2,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                  ),
                  obscureText: true,
                  validator: (String? value) {
                    if (_passwordController.text != value) {
                      return 'Passwords do not match';
                    }
                    return _validateFormField(value, 'Confirm Password');
                  },
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (String? value) =>
                      _validateFormField(value, 'Phone Number'),
                ),
                TextFormField(
                  controller: _birthdayController,
                  decoration: const InputDecoration(
                    labelText: 'Birthday (MM/DD/YYYY)',
                  ),
                  keyboardType: TextInputType.datetime,
                  validator: (String? value) =>
                      _validateFormField(value, 'Birthday'),
                ),
                SizedBox(height: 16),
                Text('User type:'),
                RadioListTile(
                  title: Text('Customer'),
                  value: 'Customer',
                  groupValue: userType,
                  onChanged: (value) {
                    setState(() {
                      userType = value.toString();
                    });
                  },
                ),
                RadioListTile(
                  title: Text('Seller'),
                  value: 'Seller',
                  groupValue: userType,
                  onChanged: (value) {
                    setState(() {
                      userType = value.toString();
                    });
                  },
                ),
                SizedBox(
                  height: 16.0,
                ),
                ElevatedButton(
                  onPressed: () {
                    _submitForm();
                  },
                  style: TextButton.styleFrom(
                    shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    primary: Colors.white,
                    backgroundColor: kPrimaryColor,
                  ),
                  child: Text('Add User Deneme' ,  style: TextStyle(fontSize: getProportionateScreenHeight(18),
                      color: Colors.white)),
                ),
                ElevatedButton(
                  child:  Text('Home screen' ,  style: TextStyle(fontSize: getProportionateScreenHeight(18),
                      color: Colors.white)),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CustomHomeScreen()),
                  ),
                  style: TextButton.styleFrom(
                    shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    primary: Colors.white,
                    backgroundColor: kPrimaryColor,
                  ),
                ),
                ElevatedButton(
                  child: Text('Seller Screen',  style: TextStyle(fontSize: getProportionateScreenHeight(18),
                    color: Colors.white)),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => SellerScreen()),
                  ),
                  style: TextButton.styleFrom(
                    shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    primary: Colors.white,
                    backgroundColor: kPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
