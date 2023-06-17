import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';
import 'package:untitled1/NewCartScreens/NewCartModel.dart';
import 'package:untitled1/NewCartScreens/NewDBHelper.dart';
import 'package:web3dart/web3dart.dart';
import 'package:untitled1/module/PostgresDBConnector.dart';
import '../screens/profile/order_screen.dart';

class Product {
  Product({
    required this.brand,
    required this.productName,
    required this.sellerID,
    required this.productID,
    required this.category,
    required this.price,
    required this.img,
  });
  Product.empty();

  static bool isSeller = false;
  String brand = '';
  String productName = '';
  int sellerID = 0;
  String buyerID = '';
  int productID = 0;
  String category = '';
  double price = 0;
  String img = '';
  int amount = 0;
  late PostgreSQLConnection connection;
  List<Product> productList = [];
  List<Product> cart = [];
String sellerAddress = '';
  DBHelper? dbHelper = DBHelper();

  List<Product>? getCart() {
    return cart;
  }

  void setConnection() async {
    connection = await PostgresDBConnector().connection;

    await getProducts();
    await fetchGlobalUserId();
}


    Future<void>  getProducts() async {
    List<Map<String, Map<String, dynamic>>> result =
        await connection.mappedResultsQuery('SELECT * FROM public.product');

    if (result.length >= 1) {
      for (Map<String, Map<String, dynamic>> element in result) {
        var productData = element['product']!;
        var myProduct = Product(
          brand: productData['brand'],
          productName: productData['pname'],
          sellerID: productData['sellerid'],
          productID: productData['id'],
          category: productData['category'],
          price: double.parse(productData['productprice']?.toString() ?? '0'),
          img: productData['ppicture'] ?? '',
        );
        productList.add(myProduct);
      }
    }
    printCart(productList);
  }

    Future<void>  fillCartList() async {
    setConnection();
    List<Cart> cartList = await dbHelper!.getCartList();
    for (Product p in productList) {
      for (Cart cartItem in cartList) { 
        if (p.productID == cartItem.id) {
          int quantity = cartItem.quantity ?? 0; // Convert to non-nullable int
          amount = quantity;
          for (int i = 0; i < quantity; i++) {
            cart.add(p);
            print('Added ${p.productName}');
          }
          break; // Break the inner loop and move to the next product
        }
      }
    }
  }

// button to purchase the cart
    Future<void>  buyProducts() async
{
  await fillCartList();
  for(Product p in cart)
   {  
        List<Map<String, Map<String, dynamic>>> result = await connection
    .mappedResultsQuery('INSERT INTO public.history (transactiondate, amount, productid, sellerid, customerid) values (@date, @amount, @pid, @sid, @cid)',
         substitutionValues: {
       'date': '2023-05-08',
       'amount': amount,
       'pid': p.productID,
       'sid': p.sellerID,
       'cid': int.parse(GlobalData.globalUserId),
       });
    sellerAddress = await getSellerAddress(p.sellerID);
    print('seller address:' + sellerAddress);
   }
}
void printCart(List<Product> list)
{
  for(Product p in list)
   {
    print(p.brand + " " + p.category + " " + p.productID.toString()
      + " " + p.price.toString()  + " " + p.img + " " + p.sellerID.toString() + " " + p.productName);
   }
}
Future<String> getSellerAddress(int id) async {
  List<Map<String, Map<String, dynamic>>> result = await connection.mappedResultsQuery(
    'SELECT walletaddress FROM public.seller WHERE id = @aId',
    substitutionValues: {'aId': id},
  );

  if (result.length == 1) {
    String walletAddress = result[0]['seller']?['walletaddress'];
    return walletAddress ?? '';
  } else {
    // Handle the case when no or multiple results are returned
    return '';
  }
}
  Future<void> fetchGlobalUserId() async {
    final url = Uri.parse('http://10.0.2.2:3000/api/get-global-user-id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      String customerId = jsonResponse['customerId']
          .toString(); // Convert the customer ID to String

        buyerID = customerId;
        GlobalData.globalUserId = customerId;

    } 
  }
}

