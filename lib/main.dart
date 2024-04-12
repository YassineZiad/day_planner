
import 'package:day_planner/components/current_time_line.dart';
import 'package:day_planner/components/expandable_fab.dart';
import 'package:day_planner/components/notes_component.dart';
import 'package:day_planner/models/note.dart';
import 'package:day_planner/repositories/event_repository.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:async';
import 'dart:io' show Platform;

import 'package:shared_preferences/shared_preferences.dart';

import 'dialogs/calendar_dialog.dart';
import 'dialogs/login_dialog.dart';
import 'dialogs/event_dialog.dart';
import 'dialogs/settings_dialog.dart';
import 'models/event.dart';

void main() {
  initializeDateFormatting('fr_FR', null).then((_) => runApp(const MyApp()));
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

  late bool _connected;

  DateTime currentTime = DateTime.now();
  String displayTime = "00:00";
  int timelineDistance = 0;

  late DateTime _date;
  late Widget _notesComponent;

  List<Event> events = [];

  @override
  void initState() {
    super.initState();
    initSP();

    _connected = false;

    _date = DateTime.now();
    _notesComponent = NotesComponent(day: _date);
  }

  String getDateLabel() {
    final DateFormat formatter = DateFormat('EEEE dd LLLL yyyy', "fr");
    return formatter.format(_date);
  }

  Future<void> getEvents() async {
    events.clear();

    var futureEvents = EventRepository.getEventsByDate(DateFormat('yyyy-MM-dd').format(_date));
    futureEvents.then((dayEvents) => {
      events.addAll(dayEvents),
      setState(() {})
    });

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
    LoginDialog.loginDialogBuilder(context).then((value) => {
      _connected = true,
      getEvents(),
      setState(() {})
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: "Jour",
            onPressed: () async => {

              _date = (await showDialog<DateTime>(
                context: context,
                builder: (context) => CalendarDialog.calendarDialogBuilder(context)
              ))!,

              getEvents(),
              _notesComponent = NotesComponent(day: _date),
              setState(() {}),
            }
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            tooltip: "Se connecter",
            onPressed: () => login()
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: "Paramètres",
            onPressed: () => SettingsDialog.settingsDialogBuilder(context)
          )
        ]
      ),

      floatingActionButton: ExpandableFab(
        distance: 112,
        children: [
          const ActionButton(
            icon: Icon(Icons.edit_note),
            tooltip: "Tâche"
          ),
          ActionButton(
            onPressed: () => EventDialog(create: true, day: _date).loginDialogBuilder(context).then((v) => getEvents()),
            icon: const Icon(Icons.calendar_month_outlined),
            tooltip: "Evènement"
          )
        ],
      ),
      body: GridView(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1),
        children: [
          Row(
            children: [
              Column(
                children: <Widget>[
                  Text(getDateLabel(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30), locale: const Locale("fr")),
                  CurrentTimeLine(day: _date, distance: timelineDistance, displayTime: displayTime, events: events)
                ],
              ),
              if (_connected)
                _notesComponent
              else
                const Text("Connectez-vous pour accéder à votre planner")
            ],
          ),
        ],
      ),
    );
  }
}
