import 'dart:convert';
import 'package:day_planner/models/event.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class EventRepository {

  static Future<bool> createEvent(Event e) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? url = "${sp.getString('url')}events";
    String? token = sp.getString('token');

    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

    http.Response response = await http.post(
      Uri.parse(url),
      headers: <String, String> {
        'Authorization': 'bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'summary': e.summary,
        'startDT': formatter.format(e.startDt),
        'endDT': formatter.format(e.endDt)
      }),
    );

    return (response.statusCode == 201);
  }

  static Future<List<Event>> getEventsByDate(String day) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? url = "${sp.getString('url')}events/$day";
    String? token = sp.getString('token');

    http.Response response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'bearer $token',
      }
    );

    return json.decode(response.body).map((events) => Event.fromJson(events)).toList().cast<Event>();
  }

  static Future<Event> getEventById(int id) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? url = "${sp.getString('url')}events/id/$id";
    String? token = sp.getString('token');

    http.Response response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'bearer $token',
        }
    );

    return Event.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<bool> updateEvent(Event e) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? url = "${sp.getString('url')}events/${e.id}";
    String? token = sp.getString('token');

    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

    http.Response response = await http.put(
      Uri.parse(url),
      headers: <String, String> {
        'Authorization': 'bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'summary': e.summary,
        'startDT': formatter.format(e.startDt),
        'endDT': formatter.format(e.endDt)
      }),
    );

    return (response.statusCode == 202);
  }

  static Future<bool> deleteEvent(Event e) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? url = "${sp.getString('url')}events/${e.id}";
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