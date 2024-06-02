import 'dart:async';

import 'package:day_planner/configs/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../components/event_component.dart';
import '../configs/app_config.dart';
import '../models/event.dart';

@immutable
class CurrentTimeLine extends StatefulWidget {

  final DateTime day;
  final int distance;
  final String displayTime;
  final List<Event> events;

  final Function getEvents;

  const CurrentTimeLine({
    super.key,
    required this.day,
    required this.distance,
    required this.displayTime,
    required this.events,
    required this.getEvents
  });

  @override
  _CurrentTimeLineState createState() => _CurrentTimeLineState();

}

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

    Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime());
  }

  void _updateTime() {
    setState(() {
      currentTime = DateTime.now();

      var currentHour = currentTime.hour < 10 ? "0${currentTime.hour}" : currentTime.hour;
      var currentMinute = currentTime.minute < 10 ? "0${currentTime.minute}" : currentTime.minute;
      displayTime = "$currentHour:$currentMinute";

      distance = currentTime.hour * AppConfig.hourRowSize + currentTime.minute * (AppConfig.hourRowSize ~/ 60);
    });
  }

  static String showHours(int i) {
    return (i < 10) ? '0$i:00' : '$i:00';
  }

  static BorderSide getBorderSide(BuildContext context) => BorderSide(color: Theme.of(context).extension<Palette>()!.quinary);

  BoxDecoration getHourRowDecoration(int i) {
    var border = Border(top: getBorderSide(context), left: getBorderSide(context));
    if (i == 23) {
      border = Border(top: getBorderSide(context), left: getBorderSide(context), bottom: getBorderSide(context));
    }
    return BoxDecoration(border: border);
  }

  BoxDecoration getEventRowDecoration(int i) {
    var border = Border(top: getBorderSide(context), left: getBorderSide(context), right: getBorderSide(context));
    if (i == 23) {
      border = Border(top: getBorderSide(context), left: getBorderSide(context), right: getBorderSide(context), bottom: getBorderSide(context));
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
                  1: FixedColumnWidth(AppConfig.eventsColumnWidth(context))
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: <TableRow>[
                  for (int i = 0; i < 24; i++)
                    TableRow(
                      key: ValueKey("Hour$i"),
                      children: <Widget>[
                        TableCell(
                            verticalAlignment: TableCellVerticalAlignment.top,
                            child: Container(
                              // Hours
                                height: AppConfig.hourRowSize.toDouble(),
                                width: 100,
                                decoration: getHourRowDecoration(i),
                                child: Text(showHours(i),
                                    textAlign: TextAlign.center))),
                        TableCell(
                            verticalAlignment: TableCellVerticalAlignment.top,
                            child: Container(
                              // Events
                                height: AppConfig.hourRowSize.toDouble(),
                                width: 900,
                                decoration: getEventRowDecoration(i))),
                      ],
                    )
                ],
              )
          )),
          Positioned(
              top: distance.toDouble(),
              right: 5,
              child: Text(displayTime, style: TextStyle(
                  foreground: Paint()..style = PaintingStyle.stroke..strokeWidth = 3..color = Theme.of(context).extension<Palette>()!.background,
                  fontWeight: FontWeight.bold
              ))
          ),
          Positioned(
              top: distance.toDouble(),
              right: 5,
              child: Text(displayTime, style: TextStyle(color: Theme.of(context).extension<Palette>()!.darkKey, fontWeight: FontWeight.bold))
          ),
          Positioned(
              top: distance.toDouble(),
              left: 0,
              right: 0, //1350
              child: Container(
                height: 2,
                color: Theme.of(context).extension<Palette>()!.darkKey,
              )
          ),
        ]
    );
  }
}