import 'dart:async';

import 'package:day_planner/extensions/object_extension.dart';
import 'package:flutter/material.dart';

import 'package:day_planner/configs/theme_config.dart';
import 'package:day_planner/components/event_component.dart';
import 'package:day_planner/configs/app_config.dart';
import 'package:day_planner/models/event.dart';

/// Tableau des évènements avec affichage des heures de la journée.
///
/// Table of events with display of hours.
@immutable
class CurrentTimeLine extends StatefulWidget {

  final DateTime day;
  final List<Event> events;

  final Function getEvents;

  const CurrentTimeLine({
    super.key,
    required this.day,
    required this.events,
    required this.getEvents
  });

  @override
  _CurrentTimeLineState createState() => _CurrentTimeLineState();

}

/// Etat de [CurrentTimeLine].
///
/// [CurrentTimeLine] state.
class _CurrentTimeLineState extends State<CurrentTimeLine> {

  DateTime currentTime = DateTime.now();
  String displayTime = "00:00";
  int distance = 0;

  late DateTime day;
  late List<Event> events;

  @override
  void initState() {
    super.initState();
    day = widget.day;
    events = widget.events;

    // Met à jour l'affichage de l'heure actuelle toutes les secondes
    // Updates current hour display every second
    Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime());
  }

  /// Met à jour l'affichage de l'heure actuelle. Ne recharge pas tout le widget.
  ///
  /// Update current time display without loading.
  void _updateTime() {
    setState(() {
      currentTime = DateTime.now();
      displayTime = "${currentTime.hour.asTimeString()}:${currentTime.minute.asTimeString()}";

      distance = currentTime.hour * DayPlannerConfig.hourRowSize + currentTime.minute * (DayPlannerConfig.hourRowSize ~/ 60);
    });
  }

  /// Retourne une bordure.
  ///
  /// Returns a border.
  static BorderSide _getBorderSide(BuildContext context) => BorderSide(color: Theme.of(context).extension<Palette>()!.quinary);


  /// Retourne les bordures de la colonne des heures.
  ///
  /// Returns hour column borders.
  BoxDecoration _getHourRowDecoration(int i) {
    var border = Border(top: _getBorderSide(context), left: _getBorderSide(context));
    if (i == 23) {
      border = Border(top: _getBorderSide(context), left: _getBorderSide(context), bottom: _getBorderSide(context));
    }
    return BoxDecoration(border: border);
  }

  /// Retourne les bordures de la colonne des évènements.
  ///
  /// Returns events column borders.
  BoxDecoration _getEventRowDecoration(int i) {
    var border = Border(top: _getBorderSide(context), left: _getBorderSide(context), right: _getBorderSide(context));
    if (i == 23) {
      border = Border(top: _getBorderSide(context), left: _getBorderSide(context), right: _getBorderSide(context), bottom: _getBorderSide(context));
    }
    return BoxDecoration(border: border);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
        children: <Widget>[
          for (Event e in widget.events) (EventComponent(event: e, getEvents: widget.getEvents)),
          IgnorePointer(child: Container(
              padding: const EdgeInsets.all(0),
              child: Table(
                columnWidths: <int, TableColumnWidth>{
                  0: const FixedColumnWidth(120),
                  1: FixedColumnWidth(DayPlannerConfig.eventsColumnWidth(context))
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: <TableRow>[
                  for (int i = 0; i < 24; i++)
                    TableRow(
                      children: <Widget>[
                        TableCell(
                            verticalAlignment: TableCellVerticalAlignment.top,
                            child: Container(
                              // Colonne des heures
                              // Hours column
                                height: DayPlannerConfig.hourRowSize.toDouble(),
                                width: 100,
                                decoration: _getHourRowDecoration(i),
                                child: Text("${i.asTimeString()}:00", textAlign: TextAlign.center))),
                        TableCell(
                            verticalAlignment: TableCellVerticalAlignment.top,
                            child: Container(
                              // Colonne des évènements
                              // Events column
                                height: DayPlannerConfig.hourRowSize.toDouble(),
                                width: 900,
                                decoration: _getEventRowDecoration(i))),
                      ],
                    )
                ],
              )
          )),
          Positioned(
              top: distance.toDouble(),
              right: 5,
              child: Text(displayTime, style: TextStyle(
                  // Colorie le contour du temps actuel en la couleur du fond pour rester visible sur tous les themes
                  // Colors the outline of current time to the background color so that it stays visible for every theme
                  foreground: Paint()..style = PaintingStyle.stroke..strokeWidth = 3..color = Theme.of(context).extension<Palette>()!.background,
                  fontWeight: FontWeight.bold
              ))
          ),
          Positioned(
              top: distance.toDouble(),
              right: 5,
              child: Text(displayTime, style: TextStyle(color: Theme.of(context).extension<Palette>()!.cancelled, fontWeight: FontWeight.bold))
          ),
          Positioned(
              top: distance.toDouble(),
              left: 0,
              right: 0,
              child: Container(
                height: 2,
                color: Theme.of(context).extension<Palette>()!.cancelled,
              )
          ),
        ]
    );
  }
}