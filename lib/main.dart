
import 'package:day_planner_web/components/current_time_line.dart';
import 'package:day_planner_web/components/notes_component.dart';
import 'package:day_planner_web/repositories/event_repository.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io' show Platform;

import 'package:shared_preferences/shared_preferences.dart';

import 'components/calendar_dialog.dart';
import 'components/login_dialog.dart';
import 'components/settings_dialog.dart';
import 'models/event.dart';

void main() {
  initSP();
  runApp(const MyApp());
}

void initSP() async {
  SharedPreferences sp = await SharedPreferences.getInstance();
  sp.setString('url', "https://localhost:8000/api/");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Day Planner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Day Planner'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  DateTime currentTime = DateTime.now();
  String displayTime = "00:00";
  int timelineDistance = 0;

  List<Event> events = [];

  @override
  void initState() {
    super.initState();
    _updateTime();

    var now = DateTime.now();
    Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime());
  }

  void _updateTime() {
    setState(() {
      currentTime = DateTime.now();

      var currentHour = currentTime.hour < 10 ? "0${currentTime.hour}" : currentTime.hour;
      var currentMinute = currentTime.minute < 10 ? "0${currentTime.minute}" : currentTime.minute;
      displayTime = "$currentHour:$currentMinute";

      timelineDistance = currentTime.hour * 60 + currentTime.minute;
    });
  }

  Future<void> getEvents() async {
    var futureEvents = EventRepository.getEvents();
    futureEvents.then((dayEvents) => events.addAll(dayEvents));

    SharedPreferences sp = await SharedPreferences.getInstance();
    String? token = sp.getString('token');


    // if (token != null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(content: Text("e"))
    //   );
    //   var futureEvents = EventRepository.getEvents();
    //   futureEvents.then((events) => events.addAll(events));
    // }
  }

  void login() {
    events.clear();
    LoginDialog.loginDialogBuilder(context).then((value) => {
      getEvents()
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(onPressed: () => CalendarDialog.calendarDialogBuilder(context), icon: const Icon(Icons.calendar_month)),
          IconButton(
            icon: const Icon(Icons.account_circle),
            tooltip: 'Se connecter',
            onPressed: () => login()
          ),
          IconButton(onPressed: () => SettingsDialog.settingsDialogBuilder(context), icon: const Icon(Icons.settings))
        ]
      ),
      body: GridView(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1),
        children: [
          Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CurrentTimeLine(distance: timelineDistance, currentTime: displayTime, events: events)
                ],
              ),

              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  NotesComponent()
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}

