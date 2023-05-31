import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '/configs/themes.dart';

class SignUp extends StatelessWidget {
  const SignUp({super.key});

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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fnameController = TextEditingController();
  final TextEditingController _lnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordController2 = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();

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
      const String url = 'http://10.0.2.2:3000/api/users';
      final Response response = await Dio().post(url, data: {
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
          const SnackBar(
            content: Text('User added to database'),
          ),
        );
      } else {
        // İstek başarısız oldu
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
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
        title: const Text('Add User'),
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
                  validator: (String? value) => _validateFormField(value, 'First Name'),
                ),
                TextFormField(
                  controller: _lnameController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                  ),
                  validator: (String? value) => _validateFormField(value, 'Last Name'),
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (String? value) => _validateFormField(value, 'Email'),
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                  ),
                  obscureText: true,
                  validator: (String? value) => _validateFormField(value, 'Password'),
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
                  validator: (String? value) => _validateFormField(value, 'Birthday'),
                ),
                const SizedBox(
                  height: 16.0,
                ),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Ade User'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
