import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class UserRepository {

  static Future<User?> getCurrentUser() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? url = "${sp.getString('url')}currentUser";
    String? token = sp.getString('token');
    
    http.Response response = await http.get(
      Uri.parse(url),
      headers: <String, String> {
        'Authorization': 'bearer $token',
        'Content-Type': 'application/json'
      }
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body)! as Map<String, dynamic>);
    } else {
      return null;
    }
  }

  static Future<bool> login(String username, String password) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? url = "${sp.getString('url')}login_check";

    http.Response response = await http.post(
      Uri.parse(url),
      headers: <String, String> {
        'Content-Type': 'application/json'
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
    }
    return false;
  }

  static Future<bool> register(String nickname, String mail, String password) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? url = "${sp.getString('url')}register";

    http.Response response = await http.post(
      Uri.parse(url),
      headers: <String, String> {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'nickname': nickname,
        'mail': mail,
        'password': password
      }),
    );

    if (response.statusCode == 201) {
      return true;
    }
    return false;
  }

  static Future<void> disconnect() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString('token', "");
  }

  static Future<bool> deleteUser() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? url = "${sp.getString('url')}users";
    String? token = sp.getString('token');

    http.Response response = await http.delete(
        Uri.parse(url),
        headers: <String, String> {
          'Authorization': 'bearer $token',
          'Content-Type': 'application/json',
        }
    );

    return (response.statusCode == 204);
  }

}