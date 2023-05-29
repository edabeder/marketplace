import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../constants.dart';
import '../../../size_config.dart';

class SearchField extends StatelessWidget {
  const SearchField({
    Key? key,
  }) : super(key: key);

  Future<List<dynamic>> searchProducts(String query) async {
    final response = await http
        .get(Uri.parse('http://10.0.2.2:3000/api/products/search/$query'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to search products');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: SizeConfig.screenWidth * 0.4,
      decoration: BoxDecoration(
        color: kSecondaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        onSubmitted: (value) async {
          final results = await searchProducts(value);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchResultScreen(results: results),
            ),
          );
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(
            horizontal: getProportionateScreenWidth(20),
            vertical: getProportionateScreenWidth(9),
          ),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          hintText: 'Search product',
          prefixIcon: const Icon(Icons.search),
        ),
      ),
    );
  }
}

class SearchResultScreen extends StatelessWidget {
  final List<dynamic> results;

  const SearchResultScreen({Key? key, required this.results}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results'),
      ),
      body: ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          final product = results[index];
          return ListTile(
            title: Text(product['pName']),
            subtitle: Text(product['brand']),
          );
        },
      ),
    );
  }
}
