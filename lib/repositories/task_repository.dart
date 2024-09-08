import 'dart:convert';

import 'package:day_planner/models/task.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

/// Effectue toutes les requêtes à l'API pour la classe métier [Task].
///
/// Performs every API requests for the [Task] class.
class TaskRepository {

  /// Crée une nouvelle tâche.
  ///
  /// Creates a new task.
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

  /// Retourne toutes les tâches de la journée.
  ///
  /// Returns every task from the day.
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

  /// Met à jour une tâche.
  ///
  /// Updates task.
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

  /// Supprime une tâche.
  ///
  /// Deletes task.
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