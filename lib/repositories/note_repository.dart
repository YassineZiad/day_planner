import 'dart:convert';
import 'package:day_planner/models/note.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Effectue toutes les requêtes à l'API pour la classe métier [Note].
///
/// Performs every API requests for the [Note] class.
class NoteRepository {

  static Future<bool> createNote(Note n) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? url = "${sp.getString('url')}notes";
    String? token = sp.getString('token');

    http.Response response = await http.post(
      Uri.parse(url),
      headers: <String, String> {
        'Authorization': 'bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'day': n.day,
        'text': n.text
      }),
    );

    return (response.statusCode == 201);
  }

  static Future<Note?> getNote(String day) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? url = "${sp.getString('url')}notes/${day}";
    String? token = sp.getString('token');

    http.Response response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'bearer $token'
        }
    );

    return response.body == "null" ? null : Note.fromJson(jsonDecode(response.body) as Map<dynamic, dynamic>);
  }

  static Future<bool> updateNote(Note n) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? url = "${sp.getString('url')}notes/${n.day}";
    String? token = sp.getString('token');

    http.Response response = await http.put(
      Uri.parse(url),
      headers: <String, String> {
        'Authorization': 'bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'text': n.text
      }),
    );

    return (response.statusCode == 202);
  }

  static Future<bool> deleteNote(String day) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? url = "${sp.getString('url')}notes/${day}";
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