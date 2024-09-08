import 'dart:io';

import 'package:day_planner/components/current_time_line.dart';
import 'package:day_planner/configs/app_config.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:day_planner/configs/theme_config.dart';
import 'package:day_planner/dialogs/calendar_dialog.dart';
import 'package:day_planner/models/event.dart';
import 'package:day_planner/models/task.dart';
import 'package:day_planner/models/user.dart';

/// [Widget] racine de l'application DayPlanner
///
/// Root [Widget] of DayPlanner app
class TestApp extends StatelessWidget {

  // Permet de changer le thème
  // Enables theme switching
  final ValueNotifier<ThemeMode> _notifier = ValueNotifier(ThemeMode.light);

  TestApp({super.key});

  Event getEventTimeRange(Event event, double top, double height) {

    // Calcul de l'heure de début de l'évènement
    // Calculate event start time
    int startHour = (top / DayPlannerConfig.hourRowSize).floor();
    int startMinute = ((top % DayPlannerConfig.hourRowSize) / DayPlannerConfig.hourRowSize * 60).round();
    DateTime newStartDt = DateTime(event.startDt.year, event.startDt.month, event.startDt.day, startHour, startMinute);

    // Calcul de l'heure de fin de l'évènement
    // Calculate event end time
    double endPosition = top + height;
    int endHour = (endPosition / DayPlannerConfig.hourRowSize).floor();
    int endMinute = ((endPosition % DayPlannerConfig.hourRowSize) / DayPlannerConfig.hourRowSize * 60).round();
    DateTime newEndDt = DateTime(event.endDt.year, event.endDt.month, event.endDt.day, endHour, endMinute);

    // Création du nouvel évènement avec les nouvelles valeurs de temps
    // Create the new event with the new time values
    Event e = Event(
        id: event.id,
        summary: event.summary,
        startDt: newStartDt,
        endDt: newEndDt
    );

    return e;
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('fr_FR', null);
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
  late User? _user;

  DateTime currentTime = DateTime.now();
  String displayTime = "00:00";
  int timelineDistance = 0;

  late DateTime _date;

  List<Event> events = [];
  List<Task> normalTasks = [];
  List<Task> priorityTasks = [];

  @override
  void initState() {
    super.initState();

    _connected = false;
    _user = null;

    _date = DateTime.now();
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
  void getEvents() {
    setState(() {
      events.clear();
    });

    DateTime testedDT = DateTime(_date.year, _date.month, _date.day, 0, 0);

    Event event1 = Event(summary: "Evènement de test", startDt: testedDT.add(const Duration(hours: 11)), endDt: testedDT.add(const Duration(hours: 13)));
    Event event2 = Event(summary: "Evènement de test", startDt: testedDT.add(const Duration(hours: 15)), endDt: testedDT.add(const Duration(hours: 17)));
    Event event3 = Event(summary: "Evènement de test", startDt: testedDT.add(const Duration(hours: 20)), endDt: testedDT.add(const Duration(hours: 23)));

    setState(() {
      events.add(event1);
      events.add(event2);
      events.add(event3);
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
                onPressed: () {}
            ),
            IconButton(
                icon: const Icon(Icons.account_circle),
                tooltip: _connected ? _user!.nickname : "Se connecter",
                onPressed: () {}
            ),
            IconButton(
                icon: const Icon(Icons.settings),
                tooltip: "Paramètres",
                onPressed: () {}
            )
          ]
      ),
      body: Row(children: [
          CurrentTimeLine(day: _date, events: events, getEvents: getEvents),
          const Text(("Connectez-vous pour accéder à votre planner."))
      ]),
    );
  }

}
