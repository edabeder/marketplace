import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:untitled1/screens/home/components/discount_banner.dart';

import '../../constants.dart';
import '../../helper/keyboard.dart';
import '../../main.dart';
import '../../size_config.dart';
import '../profile/components/profile_menu.dart';
import '../sign_in/sign_in_screen.dart';
import 'new_discount_banner.dart';

class SellerScreen extends StatefulWidget {
  @override
  _SellerScreenState createState() => _SellerScreenState();
}

class _SellerScreenState extends State<SellerScreen> {
  final List<Map<String, dynamic>> _products = [];

  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _sellerIDController = TextEditingController();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _pictureController = TextEditingController();
  final _categoryController = TextEditingController();

  File? _imageFile;
  String? brand;
  String? name;
  int? sellerID;
  int? price;
  ByteData? picture;
  String? category;
  var pickedImage;

  bool _isLoading = false;

  String? _validateFormField(String? value, String fieldName) {
    if (value?.isEmpty ?? true) {
      return '$fieldName is required';
    }
    return null;
  }
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

  Future<void> addProduct() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Convert image to base64-encoded string
      List<int> imageBytes = await _imageFile!.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/products'),
        body: {
          'brand': _brandController.text,
          'pname': _nameController.text,
          'sellerid': _sellerIDController.text,
          'productprice': _priceController.text,
          'ppicture': pickedImage.toString(),
          'category': _categoryController.text,
        },
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        print('New product added: $responseData');
      } else {
        print('Error adding product: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error adding product: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().getImage(source: source);
      print(await pickedFile?.readAsBytes()); // Değişiklik yapıldı
      print("Hello");
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }

      // bytes DB'ye çekilecek

      //final result = await postgres.query(''); Bytea Querysi  buraya yazılacak
      //final byteaValue = result.first[0] as List<int>;
      //final imageData = Uint8List.fromList(byteaValue); Tekrar resim formatına çevirecek

      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        final bytes = await imageFile.readAsBytes();
        print(bytes);
        print("hi");
      }
    } catch (e) {
      print(e);
    }
  }

  void _deleteProduct(int index) {
    setState(() {
      _products.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Seller Screen'),
          backgroundColor: Color(0xFFfe6796),
          actions: <Widget>[
          ]),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 20),
                  _imageFile != null
                      ? Image.file(
                          _imageFile!,
                          height: 100,
                        )
                      : Container(
                          height: 50,
                          color: Colors.grey[300],
                        ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          pickedImage = _pickImage(ImageSource.gallery);
                        },
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          primary: Colors.white,
                          backgroundColor: kPrimaryColor,
                        ),
                        child: Text('Gallery'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          pickedImage = _pickImage(ImageSource.camera);
                        },
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          primary: Colors.white,
                          backgroundColor: kPrimaryColor,
                        ),
                        child: Text('Camera'),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  NewDiscountBanner(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: _brandController,
                      decoration: InputDecoration(
                        hintText: 'Product Brand',
                      ),
                      validator: (value) =>
                          _validateFormField(value, 'Product Brand'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Product Name',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _sellerIDController,
                      decoration: InputDecoration(
                        hintText: 'Seller ID',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Product Price',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _categoryController,
                      decoration: InputDecoration(
                        hintText: 'Product Category',
                      ),
                    ),
                  ),
                  ElevatedButton(
                    child: _isLoading
                        ? CircularProgressIndicator()
                        : Text(
                            'Add Product',
                            style: TextStyle(
                              fontSize: getProportionateScreenWidth(18),
                              color: Colors.white,
                            ),
                          ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        addProduct();
                        KeyboardUtil.hideKeyboard(context);
                      }
                    },
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      primary: Colors.white,
                      backgroundColor: kPrimaryColor,
                    ),
                  ),
                  ProfileMenu(
                    text: 'Log Out',
                    icon: 'assets/icons/Log out.svg',
                    press: () => logout(context),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final product = _products[index];
                        return ListTile(
                          leading: product['image'] != null
                              ? Image.file(
                                  File(product['image']),
                                  height: 50,
                                )
                              : Container(
                                  height: 50,
                                  width: 50,
                                  color: Colors.grey[300],
                                ),
                          title: Text('${product['brand']} ${product['name']}'),
                          subtitle: Text('\$${product['price']}'),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteProduct(index),
                          ),

                        );
                      },
                    ),
                  ),


                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
