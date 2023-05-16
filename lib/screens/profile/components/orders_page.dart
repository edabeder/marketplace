import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List<Order> orders = [];

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final response =
        await http.get(Uri.parse('http://10.0.2.2:3000/api/history'));

    if (response.statusCode == 200) {
      // İstek başarılı, verileri al ve liste olarak sakla
      final List<dynamic> data = json.decode(response.body);
      orders = data.map((item) => Order.fromJson(item)).toList();

      setState(() {});
    } else {
      // İstek başarısız, hata mesajını göster veya uygun işlemi yap
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to fetch orders. Please try again.'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders'),
      ),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return ListTile(
            title: Text('Order ID: ${order.id}'),
            subtitle:
                Text('Product: ${order.productName}, Amount: ${order.amount}'),
          );
        },
      ),
    );
  }
}

class Order {
  final int id;
  final String productName;
  final int amount;

  Order({
    required this.id,
    required this.productName,
    required this.amount,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      productName: json['product_name'],
      amount: json['amount'],
    );
  }
}
