import 'dart:convert';
import 'package:day_planner_web/models/event.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EventRepository {

  static Future<List<Event>> getEvents() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? url = "${sp.getString('url')}events";
    String? token = sp.getString('token');

    http.Response response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'bearer $token',
      }
    );

    return json.decode(response.body).map((events) => Event.fromJson(events)).toList().cast<Event>();
  }
}