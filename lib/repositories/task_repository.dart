import 'dart:convert';

import 'package:day_planner/models/task.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class TaskRepository {

  static Future<Task> createTask(Task t) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? url = "${sp.getString('url')}tasks";
    String? token = sp.getString('token');

    http.Response response = await http.post(
      Uri.parse(url),
      headers: <String, String> {
        'Authorization': 'bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'label': t.label,
        'done' : t.done,
        'priority': t.priority,
        'day': t.day
      }),
    );

    return Task.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<List<Task>> getTasksByDate(String day) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? url = "${sp.getString('url')}tasks/$day";
    String? token = sp.getString('token');

    http.Response response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'bearer $token',
      }
    );

    return json.decode(response.body).map((tasks) => Task.fromJson(tasks)).toList().cast<Task>();
  }

  static Future<Task> getTaskById(int id) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? url = "${sp.getString('url')}tasks/id/$id";
    String? token = sp.getString('token');

    http.Response response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'bearer $token',
        }
    );

    return Task.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<bool> updateTask(Task t) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? url = "${sp.getString('url')}tasks/${t.id}";
    String? token = sp.getString('token');

    http.Response response = await http.put(
      Uri.parse(url),
      headers: <String, String> {
        'Authorization': 'bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'label': t.label,
        'done' : t.done,
        'priority': t.priority,
        'day': t.day
      }),
    );

    return (response.statusCode == 202);
  }

  static Future<bool> deleteTask(Task t) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? url = "${sp.getString('url')}tasks/${t.id}";
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