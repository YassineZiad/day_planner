import 'dart:async';

import 'package:day_planner/components/event_component.dart';
import 'package:day_planner/models/event.dart';
import 'package:flutter/material.dart';

@immutable
class CurrentTimeLine extends StatefulWidget {

  final DateTime day;
  final int distance;
  final String displayTime;
  final List<Event> events;

  const CurrentTimeLine({
    super.key,
    required this.day,
    required this.distance,
    required this.displayTime,
    required this.events
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

      var currentHour = currentTime.hour < 10 ? "0${currentTime.hour}" :currentTime.hour;
      var currentMinute = currentTime.minute < 10 ? "0${currentTime.minute}" : currentTime.minute;
      displayTime = "$currentHour:$currentMinute";

      distance = currentTime.hour * 60 + currentTime.minute;
    });
  }

  static String showHours(int i) {
    return (i < 10) ? '0$i:00' : '$i:00';
  }

  BoxDecoration getHourRowDecoration(int i) {
    var border = const Border(top: BorderSide(), left: BorderSide());
    if (i == 23) {
      border = const Border(top: BorderSide(), left: BorderSide(), bottom: BorderSide());
    }
    return BoxDecoration(border: border);
  }

  BoxDecoration getEventRowDecoration(int i) {
    var border = const Border(top: BorderSide(), left: BorderSide(), right: BorderSide());
    if (i == 23) {
      border = const Border(top: BorderSide(), left: BorderSide(), right: BorderSide(), bottom: BorderSide());
    }
    return BoxDecoration(border: border);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
        children: <Widget>[
          Container(
              padding: const EdgeInsets.all(0),
              child: Table(
                columnWidths: <int, TableColumnWidth>{
                  0: const FixedColumnWidth(120),
                  1: FixedColumnWidth(MediaQuery.of(context).size.width / 2)
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
                                height: 60,
                                width: 100,
                                decoration: getHourRowDecoration(i),
                                child: Text(showHours(i),
                                    textAlign: TextAlign.center))),
                        TableCell(
                            verticalAlignment: TableCellVerticalAlignment.top,
                            child: Container(
                              // Events
                                height: 60,
                                width: 900,
                                decoration: getEventRowDecoration(i))),
                      ],
                    )
                ],
              )
          ),
          Positioned(
              top: distance.toDouble(),
              right: 5,
              child: Text(displayTime, style: TextStyle(
                  foreground: Paint()..style = PaintingStyle.stroke..strokeWidth = 3..color = Colors.white,
                  fontWeight: FontWeight.bold
              ))
          ),
          Positioned(
              top: distance.toDouble(),
              right: 5,
              child: Text(displayTime, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
          ),
          Positioned(
              top: distance.toDouble(),
              left: 0,
              right: 0, //1350
              child: Container(
                height: 2,
                color: Colors.red,
              )
          ),
          for (Event e in widget.events) (EventComponent(event: e, color: Colors.black26))
        ]
    );

  }
}

/*
Positioned(
    top: distance.toDouble(),
    right: 5,
    child: Text(displayTime, style: TextStyle(
        foreground: Paint()..style = PaintingStyle.stroke..strokeWidth = 3..color = Colors.white,
        fontWeight: FontWeight.bold
    ))
),
Positioned(
    top: distance.toDouble(),
    right: 5,
    child: Text(displayTime, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
),
Positioned(
    top: distance.toDouble(),
    left: 0,
    right: 0, //1350
    child: Container(
      height: 2,
      color: Colors.red,
    )
)


Text(displayTime, style: TextStyle(
      foreground: Paint()..style = PaintingStyle.stroke..strokeWidth = 3..color = Colors.white,
      fontWeight: FontWeight.bold
    )
),
Text(displayTime, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
Container(
  height: 2,
  color: Colors.red,
)
 */