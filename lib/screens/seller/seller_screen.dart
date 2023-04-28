import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SellerScreen extends StatefulWidget {
  @override
  _SellerScreenState createState() => _SellerScreenState();
}

class _SellerScreenState extends State<SellerScreen> {
  final List<Map<String, dynamic>> _products = [];

  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  File? _imageFile;

  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().getImage(source: source);

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }

    } catch (e) {
      print(e);
    }
  }

  void _addProduct() {
    String brand = _brandController.text.trim();
    String name = _nameController.text.trim();
    String price = _priceController.text.trim();
    String category = _categoryController.text.trim();

    Map<String, dynamic> newProduct = {
      'brand': brand,
      'name': name,
      'price': price,
      'category': category,
      'image': _imageFile != null ? _imageFile?.path : null,
    };

    setState(() {
      _products.add(newProduct);
    });

    _brandController.clear();
    _nameController.clear();
    _priceController.clear();
    _categoryController.clear();
    setState(() {
      _imageFile?.delete(); // delete the file if it exists
      _imageFile = null;
    });
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                  onPressed: () => _pickImage(ImageSource.gallery),
                  child: Text('Gallery'),
                ),
                ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.camera),
                  child: Text('Camera'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _brandController,
                decoration: InputDecoration(
                  hintText: 'Product Brand',
                ),
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
              onPressed: _isLoading ? null : _addProduct,
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Text('Add Product'),
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
    );
  }
}
