import 'dart:io';

import 'package:day_planner/components/current_time_line.dart';
import 'package:day_planner/components/notes_container.dart';
import 'package:day_planner/repositories/event_repository.dart';
import 'package:day_planner/repositories/task_repository.dart';
import 'package:day_planner/repositories/user_repository.dart';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:day_planner/configs/theme_config.dart';
import 'package:day_planner/dialogs/calendar_dialog.dart';
import 'package:day_planner/dialogs/login_dialog.dart';
import 'package:day_planner/dialogs/settings_dialog.dart';
import 'package:day_planner/extensions/custom_http_overrides.dart';
import 'package:day_planner/models/event.dart';
import 'package:day_planner/models/task.dart';
import 'package:day_planner/models/user.dart';

/// Lancement de l'application
///
/// Application launch
void main() {
  HttpOverrides.global = CustomHttpOverrides();
  initializeDateFormatting('fr_FR', null).then((_) => runApp(MyApp()));
}

/// Initialise les [SharedPreferences]
///
/// Initialize [SharedPreferences]
void initSP() async {
  SharedPreferences sp = await SharedPreferences.getInstance();
  if (defaultTargetPlatform == TargetPlatform.android) {
    sp.setString('url', "https://192.168.237.112:8000/api/");
  }
  else {
    sp.setString('url', "https://localhost:8000/api/");
  }
}

/// [Widget] racine de l'application DayPlanner
///
/// Root [Widget] of DayPlanner app
class MyApp extends StatelessWidget {

  // Permet de changer le thème
  // Enables theme switching
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

/// [Widget] principal de l'application DayPlanner où sont contenus tous les autres composants
///
/// Main [Widget] of DayPlanner app containing all the app components
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

/// Etat de [DayPlannerPage]
///
/// State of [DayPlannerPage]
class _DayPlannerPageState extends State<DayPlannerPage> {

  late bool _connected;
  late bool _showNotes;
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
    _showNotes = false;
    _user = null;

    _date = DateTime.now();
    _notesContainer = NotesContainer(day: _date, normalTasks: normalTasks, priorityTasks: priorityTasks, getEvents: getEvents);
  }

  /// Retourne la date sélectionnée ou par défaut en français sous [String]
  ///
  /// Returns selected or default date as [String] with french locale
  String getDateLabel() {
    final DateFormat formatter = DateFormat('EEEE dd LLLL yyyy', "fr");
    return formatter.format(_date);
  }

  /// Chargement des évènements
  ///
  /// Events load
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

  /// Chargement des tâches
  ///
  /// Tasks loading
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

  /// Lance [LoginUserDialog] et connecte l'utilisateur si ses identifiants sont correctes
  ///
  /// Launches [LoginUserDialog] and connects the user if his credentials are corrects
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
          _user = null,
          _showNotes = false
        },
        setState(() {})
      },

    });
  }

  /// Permet à l'utilisateur de choisir un jour
  ///
  /// User can choose day to display
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
      body: getPageLayoutByPlatform(),
    );
  }

  /// Affiche le rendu de la page pour l'utilisateur en fonction de la plateforme utilisée
  ///
  /// Displays page layout according to the used platform
  Widget getPageLayoutByPlatform() {
    // Android
    if (defaultTargetPlatform == TargetPlatform.android) {
      return Column(
        children: [
          Center(child: Text(getDateLabel(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30), locale: const Locale("fr"))),
          if (!_connected)
            const Center(child: Text("Connectez-vous pour accéder à votre planner."))
          else
            Center(
              child: ElevatedButton.icon(
                icon: Icon(_showNotes ? Icons.calendar_today : Icons.notes),
                label: Text(_showNotes ? "Evènements" : "Tâches"),
                onPressed: ()  {
                  setState(() {
                    _showNotes = !_showNotes;
                  });
                },
              )),
          if (!_showNotes || !_connected)
            Expanded(
                child: SingleChildScrollView(
                    child: Expanded(child: CurrentTimeLine(day: _date, events: events, getEvents: getEvents))
                )
            )
          else if (_showNotes && _connected)
            _notesContainer
        ],
      );
    // Web - Windows
    } else if (kIsWeb || defaultTargetPlatform == TargetPlatform.windows) {
      return GridView(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1),
        children: [
          Row(
            children: [
              Column(
                children: <Widget>[
                  Text(getDateLabel(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30), locale: const Locale("fr")),
                  Expanded(
                      child: SingleChildScrollView(
                        child: CurrentTimeLine(day: _date, events: events, getEvents: getEvents),
                      )
                  )
                ],
              ),
              if (_connected)
                _notesContainer
              else
                SizedBox(
                    width: MediaQuery.of(context).size.width / 3,
                    child: const Center(heightFactor: 0, child: Text("Connectez-vous pour accéder à votre planner."))
                )
            ],
          ),
        ],
      );
    // Autres - Others
    } else {
      return const Center(child: Text("Désolé. L'application DayPlanner n'est pas disponible sur votre plateforme."));
    }
  }

}
