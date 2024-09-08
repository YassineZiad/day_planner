import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import "package:day_planner/extensions/object_extension.dart";
import 'package:day_planner/configs/app_config.dart';

/// Dialog de sélection de la date.
///
/// Date selection dialog.
class CalendarDialog extends StatefulWidget {

  final DateTime date;

  const CalendarDialog({
    super.key,
    required this.date
  });

  @override
  State createState() => _CalendarDialogState();
}

/// Etat de [CalendarDialog].
///
/// State of [CalendarDialog].
class _CalendarDialogState extends State<CalendarDialog> {

  late DateTime? _date;
  late bool _dateChanged;

  final TextEditingController _monthController = TextEditingController();
  late int? _selectedMonth;
  late List<DropdownMenuEntry<int>> _monthsEntries;

  final TextEditingController _yearController = TextEditingController();
  late int? _selectedYear;
  late List<DropdownMenuEntry<int>> _yearsEntries;


  @override
  void initState() {
    super.initState();
    _dateChanged = false;
    _monthsEntries = getMonths();
    _yearsEntries = getYears();

    _date = widget.date;
    _selectedMonth = _date!.month;
    _selectedYear = _date!.year;
  }

  /// Retourne tous les mois de l'année en français.
  ///
  /// Returns every month in french locale.
  static List<DropdownMenuEntry<int>> getMonths() {
    List<DropdownMenuEntry<int>> months = [];
    for (int month = 1; month <= 12; month++) {
      months.add(
          DropdownMenuEntry(label: DateFormat('LLLL', "fr").format(DateTime(0, month)).capitalize(), value: month)
      );
    }

    return months;
  }

  /// Retourne les 25 années avant et après l'année actuelle.
  ///
  /// Returns the 25 years before and after the current year.
  static List<DropdownMenuEntry<int>> getYears() {
    List<DropdownMenuEntry<int>> years = [];
    for (int year = (DateTime.now().year - 25); year <= (DateTime.now().year + 25); year++) {
      years.add(
          DropdownMenuEntry(label: "$year", value: year)
      );
    }

    return years;
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Calendrier'),
      children: <Widget>[
        Row(
          children: [
            DropdownMenu<int>(
              initialSelection: _selectedMonth,
              controller: _monthController,
              requestFocusOnTap: true,
              label: const Text('Mois'),
              onSelected: (int? month) {
                setState(() {
                  _selectedMonth = month;
                  _dateChanged = true;
                });
              },
              dropdownMenuEntries: _monthsEntries,
            ),
            DropdownMenu<int>(
              initialSelection: _selectedYear,
              controller: _yearController,
              requestFocusOnTap: true,
              label: const Text('Année'),
              onSelected: (int? year) {
                setState(() {
                  _selectedYear = year;
                  _dateChanged = true;
                });
              },
              dropdownMenuEntries: _yearsEntries,
            ),
            Visibility(
              visible: _dateChanged,
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _dateChanged = false;
                    _date = DateTime(_selectedYear!, _selectedMonth!);
                  });
                },
                icon: const Icon(Icons.search)))
          ],
        ),
        Flex(direction: Axis.vertical, children: getMonthDays(_date!, context))
      ],
    );
  }

  /// Retourne une liste de [OutlinedButton] correspondant aux jours du mois sélectionné.
  ///
  /// Returns a lit of [OutlinedButton] containing the day of selected month.
  static List<Widget> getMonthDays(DateTime date, BuildContext context) {
    int nbDays = DateUtils.getDaysInMonth(date.year, date.month);

    List<Flex> flexes = [];
    List<Widget> weekDays = [];

    DateTime firstMonthDay = DateTime(date.year, date.month, 1);
    int firstMonthDayInWeek = 7 - firstMonthDay.weekday + 1;
    var dateBefore = firstMonthDay.add(Duration(days: -(7 - firstMonthDayInWeek)));


    for (int daysBeforeFirst = 0; daysBeforeFirst < (7 - firstMonthDayInWeek); daysBeforeFirst++) {
      var day = dateBefore.day + daysBeforeFirst;
      weekDays.add(
          OutlinedButton(
            onPressed: null,
            child: Text(day < 10 ? "0$day": "$day"),
          )
      );
    }

    for (int d = 1; d <= nbDays; d++) {
      weekDays.add(
          OutlinedButton(
            onPressed: () {
              Navigator.pop(
                  context,
                  DateTime(date.year, date.month, d)
              );
            },
            child: Text(
                d.asTimeString(),
                style: defaultTargetPlatform == TargetPlatform.android ? TextStyle(fontSize: DayPlannerConfig.fontSizeS) : null
            ),
          )
      );

      if (weekDays.length % 7 == 0){
        flexes.add(
            Flex(direction: Axis.horizontal, children: [
              for (Widget day in weekDays) day
            ])
        );
        weekDays.clear();
      }

    }

    if (weekDays.isNotEmpty) {
      if (weekDays.length < 7) {
        for (int daysAfterLast = 1; daysAfterLast <= (7 - weekDays.length) + 1; daysAfterLast++) {
          weekDays.add(
              OutlinedButton(
                onPressed: null,
                child: Text(
                    daysAfterLast.asTimeString(),
                    style: defaultTargetPlatform == TargetPlatform.android ? TextStyle(fontSize: DayPlannerConfig.fontSizeS) : null),
              )
          );
        }
      }

      flexes.add(
          Flex(direction: Axis.horizontal, children: [
            for (Widget day in weekDays) day
          ])
      );
    }

    return flexes;
  }

}