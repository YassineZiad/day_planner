import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarDialog {

  static List<Widget> getMonthDays(BuildContext context) {
    var date = DateTime.now();
    int nbDays = DateUtils.getDaysInMonth(date.year, date.month);

    List<Flex> flexes = [];
    List<Widget> weekDays = [];
    for (int d = 1; d <= nbDays; d++) {
      weekDays.add(
          OutlinedButton(
            onPressed: () {
              Navigator.pop(
                context,
                DateTime(date.year, date.month, d)
              );
            },
            child: Text(d < 10 ? "0$d": "$d"),
          )
      );

      if (d % 7 == 0){
        flexes.add(
            Flex(direction: Axis.horizontal, children: [
              for (Widget day in weekDays) day
            ])
        );
        weekDays.clear();
      }

    }

    if (weekDays.isNotEmpty) {
      flexes.add(
          Flex(direction: Axis.horizontal, children: [
            for (Widget day in weekDays) day
          ])
      );
    }

    return flexes;
  }

  static Widget calendarDialogBuilder(BuildContext context) {
    return SimpleDialog(
      title: const Text('Calendrier'),
      children: <Widget>[
        Text(DateFormat('LLLL yyyy', "fr").format(DateTime.now())),
        Flex(direction: Axis.vertical, children: getMonthDays(context))
      ],
    );
  }

}