import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:untitled1/screens/home/home_screen.dart';
import '../../../components/default_button.dart';
import 'package:flutter/material.dart';
import '../splash/splash_screen.dart';
import '/components/custom_surfix_icon.dart';
import '/components/form_error.dart';
import '/helper/keyboard.dart';
import '/screens/login_success/login_success_screen.dart';

import '../../../components/default_button.dart';
import '../../../constants.dart';
import '../../../size_config.dart';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatelessWidget {
  static String routeName = "/register_page";
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Add User',
      home: AddUserScreen(),
    );
  }
}

class AddUserScreen extends StatefulWidget {
  @override
  _AddUserScreenState createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {

  String dropdownValue = 'Buyer'; // initial dropdown value
  bool isRegistered = false;
  final _formKey = GlobalKey<FormState>();
  final _fnameController = TextEditingController();
  final _lnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordController2 = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthdayController = TextEditingController();

  @override
  void dispose() {
    _fnameController.dispose();
    _lnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordController2.dispose();
    _phoneController.dispose();
    _birthdayController.dispose();
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
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else if (dropdownValue == 'Seller') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SplashScreen()),
      );
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final url = 'http://10.0.2.2:3000/api/users';
      final response = await Dio().post(url, data: {
        'fName': _fnameController.text,
        'lname': _lnameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'password2': _passwordController2.text,
        'phone': _phoneController.text,
        'birthday': _birthdayController.text,
      });

      print("normal deneme");
      if ( await response.statusCode == 201) {
        print("is denemesi");
        // Kullanıcı başarıyla eklendi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User added to database'),
          ),
        );

        print("if denemesi 2");

        // return true if registration was successful
      }
    }// return false if form validation failed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add User'),
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
                  decoration: InputDecoration(
                    labelText: 'First Name',
                  ),
                  validator: (value) => _validateFormField(value, 'First Name'),
                ),
                TextFormField(
                  controller: _lnameController,
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                  ),
                  validator: (value) => _validateFormField(value, 'Last Name'),
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => _validateFormField(value, 'Email'),
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                  ),
                  obscureText: true,
                  validator: (value) => _validateFormField(value, 'Password'),
                ),
                TextFormField(
                  controller: _passwordController2,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (_passwordController.text != value) {
                      return 'Passwords do not match';
                    }
                    return _validateFormField(value, 'Confirm Password');
                  },
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                      _validateFormField(value, 'Phone Number'),
                ),
                TextFormField(
                  controller: _birthdayController,
                  decoration: InputDecoration(
                    labelText: 'Birthday (MM/DD/YYYY)',
                  ),
                  keyboardType: TextInputType.datetime,
                  validator: (value) => _validateFormField(value, 'Birthday'),
                ),
                SizedBox(
                  height: 16.0,
                ),


                ElevatedButton(
                  onPressed: ()  {
                    print("hello");
                    print(isRegistered);
                    _submitForm();

                    print(isRegistered);

                  },
                  child: Text('Add User Deneme'),
                ),

                SizedBox(height: 20),
                ElevatedButton(
                  child: Text('Register'),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
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
