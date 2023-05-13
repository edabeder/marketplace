import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Order {
  final DateTime transactionDate;
  final int amount;
  final int productId;
  final int sellerId;
  final int customerId;
  final int row;

  Order({
    required this.transactionDate,
    required this.amount,
    required this.productId,
    required this.sellerId,
    required this.customerId,
    required this.row,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      transactionDate: DateTime.parse(json['transactiondate']),
      amount: json['amount'],
      productId: json['productid'],
      sellerId: json['sellerid'],
      customerId: json['customerid'],
      row: json['row'],
    );
  }
}

class GlobalData {
  static String globalUserId = '';
}

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Order> orders = [];

  @override
  void initState() {
    super.initState();
    GlobalData.globalUserId =
        ''; // Kullanıcı giriş yaptığında bu değişkene değer atanacak
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final url = Uri.parse(
        'http://10.0.2.2:3000/api/history/${GlobalData.globalUserId}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body) as List<dynamic>;
      List<Order> fetchedOrders =
          jsonList.map((json) => Order.fromJson(json)).toList();

      setState(() {
        orders = fetchedOrders;
      });
    } else {
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
          Order order = orders[index];

          return ListTile(
            title: Text('Amount: ${order.amount}'),
            subtitle:
                Text('Transaction Date: ${order.transactionDate.toString()}'),
          );
        },
      ),
    );
  }
}
