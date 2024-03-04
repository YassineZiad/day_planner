import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserRepository {

  Future<bool> login(String username, String password) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? url = "${sp.getString('url')}login_check";

    http.Response response = await http.post(
      Uri.parse(url),
      headers: <String, String> {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password
      }),
    );

    var body = json.decode(response.body);
    if (body['token'] != null && response.statusCode == 200) {
      sp.setString('token', body['token']);
      return true;
    } else {
      return false;
    }

  }

  // Future<String> getUsers() async {
  //   final response = await http.get(url, headers: {
  //     'Content-Type': 'application/json',
  //     'Accept': 'application/json',
  //     'Authorization': 'bearer $token',
  //   });
  //   return token;
  // }
}