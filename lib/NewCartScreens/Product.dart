import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';
import 'package:web3dart/web3dart.dart';

class Product
{

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

  String brand = '';
  String productName = '';
  int sellerID = 0;
  int productID = 0;
  String category = '';
  double price = 0;
  String img = '';
  double total = 0;
  var connection;
  List<Product> productList = [];
  List<Product> cart = [];
  List<dynamic> sellers = [];
  List<String> productNames = [];
  List<double> prices = [];

void setConnection(PostgreSQLConnection conn)
{
  connection = conn;
}
void getProducts() async
{
   List<Map<String, Map<String, dynamic>>> result = await connection
    .mappedResultsQuery('SELECT * FROM public.product');


  if (result.length >= 1) {
     for (Map<String, Map<String, dynamic>> element in result) {
    var productData = element['product']!;
    var myProduct = Product(
      brand: productData['brand'],
      productName: productData['pname'],
      sellerID: productData['sellerid'],
      productID: productData['id'],
      category: productData['category'],
      price: double.parse(productData['productprice']),
      img: productData['ppicture'] ?? '',
    );
    productList.add(myProduct);       
     }
   }
   
}
void addToCart(Product p)
{
  cart.add(p);
  total += p.price;
}
void buyProducts() async
{
  for(Product p in cart)
   {
    
    sellers.add(await getSellerAddress(p.sellerID));
    productNames.add(p.productName);
    prices.add(p.price);
   }
   print("total: " + total.toString());
}
void printCart()
{
  for(Product p in cart)
   {
    print(p.brand + " " + p.category + " " + p.productID.toString()
      + " " + p.price.toString()  + " " + p.img + " " + p.sellerID.toString() + " " + p.productName);
   }
}
 Future<dynamic> getSellerAddress(int id) async
 {
  List<Map<String, Map<String, dynamic>>> result = await connection
    .mappedResultsQuery('SELECT walletaddress FROM public.seller WHERE id = @aId',
         substitutionValues: {
       'aId': id,
       });


  if (result.length == 1) {
     for (Map<String, Map<String, dynamic>> element in result) {
      //EthereumAddress address = EthereumAddress.fromHex(element['walletaddress']?['value']);
      return result;
     }
   }
   throw Exception('Seller not found');
 }
}