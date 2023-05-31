import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants.dart';
import '../../helper/keyboard.dart';
import '../../main.dart';
import '../../size_config.dart';

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

  /*void addProduct(String brand, String name, int sellerID, int price,
      ByteData picture, String category) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/products'),
        body: {
          'brand': brand,
          'pName': name,
          'sellerID': sellerID,
          'price': price,
          'pPicture': picture,
          'category': category,
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
    }
  }*/

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
          'price': _priceController.text,
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

  /*Future<ByteData?> _pickImage(ImageSource source) async {
    final completer = Completer<ByteData?>();
    try {
      final pickedFile = await ImagePicker().getImage(source: source);
      print(pickedFile?.readAsBytes());
      print("Hello");
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        final bytes = await imageFile.readAsBytes();
        print(bytes);
        print("hi");
        completer.complete(ByteData.view(bytes.buffer));
      } else {
        completer.complete(null);
      }
    } catch (e) {
      print(e);
      completer.completeError(e);
    }
    return completer.future;
  }*/

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
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => MyHomePage(),
              ),
            ),
            icon: const Icon(Icons.home),
          ),
        ]
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                      height: 100,
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
                      shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                      shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      primary: Colors.white,
                      backgroundColor: kPrimaryColor,
                    ),
                    child: Text('Camera'),
                  ),
                ],
              ),
              SizedBox(height: 20),
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
                      : Text('Add Product',
                    style: TextStyle(
                      fontSize: getProportionateScreenWidth(18),
                      color: Colors.white,),),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      addProduct();
                      KeyboardUtil.hideKeyboard(context);
                    }
                  },
                style: TextButton.styleFrom(
                  shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  primary: Colors.white,
                  backgroundColor: kPrimaryColor,
                ),
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
    );
  }
}
