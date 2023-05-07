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
        .get(Uri.parse('http://10.0.2.2:3000/api/products/search/:query'));
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
<<<<<<< HEAD
        onChanged: (value) async {
          final results = await searchProducts(value);
          print(results);
        },
=======
        onChanged: (String value) => print(value),
>>>>>>> b0653e36bdbdac788c099518c252e9dbc8dfcb27
        decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(20),
                vertical: getProportionateScreenWidth(9)),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            hintText: 'Search product',
            prefixIcon: const Icon(Icons.search)),
      ),
    );
  }
}
