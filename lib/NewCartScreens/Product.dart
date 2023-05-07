import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';

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
  List<Product> productList = [];
  List<Product> cart = [];
  List<int> sellers = [];
  List<String> productNames = [];
  List<double> prices = [];

void getProducts(PostgreSQLConnection connection) async
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
void buyProducts()
{
  for(Product p in cart)
   {
    sellers.add(p.sellerID);
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
}