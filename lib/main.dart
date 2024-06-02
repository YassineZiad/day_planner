
import 'package:day_planner/components/current_time_line.dart';
import 'package:day_planner/components/notes_container.dart';
import 'package:day_planner/repositories/event_repository.dart';
import 'package:day_planner/repositories/task_repository.dart';
import 'package:day_planner/repositories/user_repository.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import 'configs/theme_config.dart';
import 'dialogs/calendar_dialog.dart';
import 'dialogs/login_dialog.dart';
import 'dialogs/settings_dialog.dart';
import 'models/event.dart';
import 'models/task.dart';
import 'models/user.dart';

void main() {
  initializeDateFormatting('fr_FR', null).then((_) => runApp(MyApp()));
}

void initSP() async {
  SharedPreferences sp = await SharedPreferences.getInstance();
  sp.setString('url', "https://localhost:8000/api/");
}

class MyApp extends StatelessWidget {

  final ValueNotifier<ThemeMode> _notifier = ValueNotifier(ThemeMode.light);

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Icon icon = const Icon(Icons.dark_mode_outlined);

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _notifier,
      builder: (_, themeMode, __) {
        return MaterialApp(
          theme: DayPlannerLight().getThemeData(),
          darkTheme: DayPlannerDark().getThemeData(),
          themeMode: themeMode,
          home: DayPlannerPage(
              title: "Day Planner",
              themeToggle: IconButton(
                icon: icon,
                onPressed: () => {
                  if (themeMode == ThemeMode.light) {
                    _notifier.value = ThemeMode.dark,
                    icon = const Icon(Icons.light_mode_outlined)
                  } else {
                    _notifier.value = ThemeMode.light,
                    icon = const Icon(Icons.dark_mode_outlined)
                  }
                },
              )
          )
        );
      },
    );
  }
}

class DayPlannerPage extends StatefulWidget {

  final String title;
  final Widget themeToggle;

  const DayPlannerPage({
    super.key,
    required this.title,
    required this.themeToggle
  });

  @override
  _DayPlannerPageState createState() => _DayPlannerPageState();
}

class _DayPlannerPageState extends State<DayPlannerPage> {

  late bool _connected;
  late User? _user;

  DateTime currentTime = DateTime.now();
  String displayTime = "00:00";
  int timelineDistance = 0;

  late DateTime _date;
  late Widget _notesContainer;

  List<Event> events = [];
  List<Task> normalTasks = [];
  List<Task> priorityTasks = [];

  @override
  void initState() {
    super.initState();
    initSP();

    _connected = false;
    _user = null;

    _date = DateTime.now();
    _notesContainer = NotesContainer(day: _date, normalTasks: normalTasks, priorityTasks: priorityTasks, getEvents: getEvents);
  }

  String getDateLabel() {
    final DateFormat formatter = DateFormat('EEEE dd LLLL yyyy', "fr");
    return formatter.format(_date);
  }

  Future<void> getEvents() async {
    setState(() {
      events.clear();
    });

    var futureEvents = EventRepository.getEventsByDate(DateFormat('yyyy-MM-dd').format(_date));
    futureEvents.then((dayEvents) => {
      events.addAll(dayEvents),
      setState(() {})
    });
  }

  Future<void> getTasks() async {
    setState(() {
      normalTasks.clear();
      priorityTasks.clear();
    });

    var futureTasks = TaskRepository.getTasksByDate(DateFormat('yyyy-MM-dd').format(_date));
    futureTasks.then((dayTasks) {
      List<Task> pTasks = [], nTasks = [];
      for (Task task in dayTasks) {
        task.priority ? pTasks.add(task) : nTasks.add(task);
      }

      setState(() {
        priorityTasks.addAll(pTasks) ;
        normalTasks.addAll(nTasks);
        _notesContainer = NotesContainer(day: _date, normalTasks: normalTasks, priorityTasks: priorityTasks, getEvents: getEvents);
      });
    });
  }

  void login() {
    LoginDialog.buildUserDialog(_user, _connected, context).then((v) async => {

      if (_connected != LoginDialog.isConnected) {
        _connected = LoginDialog.isConnected,
        if (_connected) {
          _user = await UserRepository.getCurrentUser(),
          getEvents(),
          getTasks()
        }
        else
        {
          events.clear(),
          _user = null
        },
        setState(() {})
      },

    });
  }

  pickDay() async {
    DateTime? pickedDate = await showDialog<DateTime>(
      context: context,
      builder: (context) => CalendarDialog(date: _date)
    );

    setState(() => _date = pickedDate ?? _date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
        title: Text(widget.title),
        actions: [
          widget.themeToggle,
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: "Jour",
            onPressed: () async => {

              await pickDay(),

              if (_connected) {
                getEvents(),
                getTasks(),
                setState(() {
                  _notesContainer = NotesContainer(day: _date, normalTasks: normalTasks, priorityTasks: priorityTasks, getEvents: getEvents);
                })
              }
            }
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            tooltip: _connected ? _user!.nickname : "Se connecter",
            onPressed: () => login()
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: "Paramètres",
            onPressed: () => SettingsDialog.show(context)
                .then((value) {
              if(_connected) {
                getEvents();
                getTasks();
              }
            })
          )
        ]
      ),
      body: GridView(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1),
        children: [
          getPageLayoutByPlatform(),
        ],
      ),
    );
  }

  Widget getPageLayoutByPlatform() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return Column(
        children: [
          Column(
            children: <Widget>[
              Text(getDateLabel(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30), locale: const Locale("fr")),
              CurrentTimeLine(day: _date, distance: timelineDistance, displayTime: displayTime, events: events, getEvents: getEvents)
            ],
          ),
          if (_connected)
            SizedBox(child: _notesContainer)
          else
            SizedBox(
                width: MediaQuery.of(context).size.width / 3,
                child: const Center(heightFactor: 0, child: Text("Connectez-vous pour accéder à votre planner"))
            )
        ],
      );
    } else if (kIsWeb || defaultTargetPlatform == TargetPlatform.windows) {
      return Row(
        children: [
          Column(
            children: <Widget>[
              Text(getDateLabel(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30), locale: const Locale("fr")),
              Expanded(
                  child: SingleChildScrollView(
                    child: CurrentTimeLine(day: _date, distance: timelineDistance, displayTime: displayTime, events: events, getEvents: getEvents),
                  )
              )
            ],
          ),
          if (_connected)
            _notesContainer
          else
            SizedBox(
                width: MediaQuery.of(context).size.width / 3,
                child: const Center(heightFactor: 0, child: Text("Connectez-vous pour accéder à votre planner"))
            )
        ],
      );
    } else {
      return const Text("Désolé. L'application DayPlanner n'est pas disponible sur votre plateforme.");
    }
  }

}
