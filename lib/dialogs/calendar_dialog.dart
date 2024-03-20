import 'package:flutter/material.dart';

class CalendarDialog extends StatelessWidget {

  static Future<void> calendarDialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Calendrier'),
          children: <Widget>[

          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }

}