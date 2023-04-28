import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

class SignUp extends StatelessWidget {
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
      if (response.statusCode == 201) {
        // Kullanıcı başarıyla eklendi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User added to database'),
          ),
        );
      } else {
        // İstek başarısız oldu
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding user to database'),
          ),
        );
      }
    }
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
                  onPressed: _submitForm,
                  child: Text('Ade User'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
