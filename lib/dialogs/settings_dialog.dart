import 'package:flutter/material.dart';

class SettingsDialog extends StatelessWidget {

  static Future<void> settingsDialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Paramètres'),
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