import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:untitled1/module/auth/interfaces/screens/authentication_screen.dart';
import 'package:untitled1/screens/profile/new_auth_screen.dart';
import 'package:untitled1/screens/profile/return_product.dart';

class Order {
  final DateTime transactionDate;
  final int amount;
  final int productId;
  final int sellerId;
  final int customerId;

  Order({
    required this.transactionDate,
    required this.amount,
    required this.productId,
    required this.sellerId,
    required this.customerId,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      transactionDate: DateTime.parse(json['transactiondate']),
      amount: json['amount'],
      productId: json['productid'],
      sellerId: json['sellerid'],
      customerId: json['customerid'],
    );
  }
}

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Order> orders = [];
  late String globalUserId;

  @override
  void initState() {
    super.initState();
    globalUserId = GlobalData.globalUserId;
    if (globalUserId.isEmpty) {
      fetchGlobalUserId(); // Fetch the global user ID
    } else {
      fetchOrders();
    }
  }

  Future<void> fetchGlobalUserId() async {
    final url = Uri.parse('http://10.0.2.2:3000/api/get-global-user-id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      String customerId = jsonResponse['customerId']
          .toString(); // Convert the customer ID to String
      setState(() {
        globalUserId = customerId;
        GlobalData.globalUserId = customerId;
      });
      fetchOrders();
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to fetch global user ID. Please try again.'),
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

  Future<void> fetchOrders() async {
    final response = await http
        .get(Uri.parse('http://10.0.2.2:3000/api/history/$globalUserId'));

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
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
        title: const Text('Orders'),
        backgroundColor: Color(0xFFfe6796),
      ),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          Order order = orders[index];

          return ListTile(
            title: Text('Amount: ${order.amount}'),
            subtitle: Text('Transaction Date: ${order.transactionDate.toString()}'),
            trailing: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  NewAuthenticationScreen()),
                );

              },
              style: ElevatedButton.styleFrom(
                primary: Color(0xFFfe6796), // Change the background color here
              ),
              child: Text('Return'),
            ),
          );
        },
      ),

    );
  }
}

class GlobalData {
  static String globalUserId = '';
}
