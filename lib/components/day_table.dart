import 'package:flutter/material.dart';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class DayTable<T extends Object?> extends StatelessWidget {

  const DayTable({super.key});

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
    return Container(
        padding: const EdgeInsets.all(0),
        child: Table(
          columnWidths: const <int, TableColumnWidth>{
            0: FixedColumnWidth(120),
            1: FlexColumnWidth()
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: <TableRow>[
            for (int i=0; i < 24; i++)
              TableRow(
                key: ValueKey("Hour$i"),
                children: <Widget>[
                  TableCell(
                      verticalAlignment: TableCellVerticalAlignment.top,
                      child: Container( // Hours
                          height: 60,
                          width: 100,
                          decoration: getHourRowDecoration(i),
                          child: Text(showHours(i), textAlign: TextAlign.center)
                      )
                  ),
                  TableCell (
                    verticalAlignment: TableCellVerticalAlignment.top,
                    child: Container( // Events
                        height: 60,
                        width: 900,
                        decoration: getEventRowDecoration(i)
                      )
                    ),
                ],
              )
          ],
        )
    );
  }

  static String showHours(int i) {
    return (i < 10) ? '0$i:00' : '$i:00';
  }

}
