
import 'package:day_planner_web/components/event_component.dart';
import 'package:day_planner_web/models/event.dart';
import 'package:flutter/material.dart';

class CurrentTimeLine extends StatelessWidget {

  final int distance;
  final String currentTime;
  List<Event> events;

  CurrentTimeLine({
    super.key,
    required this.distance,
    required this.currentTime,
    required this.events
  });

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

  static String showHours(int i) {
    return (i < 10) ? '0$i:00' : '$i:00';
  }

  @override
  Widget build(BuildContext context) {

    return Stack(
      children: <Widget>[
        Positioned(
          top: distance.toDouble(),
          left: 0,
          right: 0, //1350
          child: Container(
            height: 2,
            color: Colors.red,
          )
        ),
        Positioned(
            top: distance.toDouble(),
            right: 5,
            child: Text(currentTime, style: TextStyle(
              foreground: Paint()..style = PaintingStyle.stroke..strokeWidth = 6..color = Colors.white,
              fontWeight: FontWeight.bold
            ))
        ),
        Positioned(
            top: distance.toDouble(),
            right: 5,
            child: Text(currentTime, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
        ),
        for (Event e in events) (EventComponent(event: e, color: Colors.black26)),
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
        )
      ]
    );
  }
}