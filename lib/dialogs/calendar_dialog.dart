import 'package:flutter/material.dart';

class CalendarDialog {

  static void calendarDialogBuilder(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return const SimpleDialog(
          title: Text('Calendrier'),
          children: <Widget>[

          ],
        );
      },
    );
  }

}