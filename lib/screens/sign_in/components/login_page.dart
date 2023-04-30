import 'dart:convert';
import 'package:http/http.dart' as http;

const String apiUrl = 'http://localhost:3000/api/login';

Future<String> loginUser(String email, String password) async {
  final http.Response response = await http.post(Uri.parse(apiUrl), body: {
    'email': email,
    'password': password,
  });

  final responseJson = json.decode(response.body);

  if (response.statusCode == 200) {
    return responseJson['message'];
  } else {
    throw Exception(responseJson['message']);
  }
}
