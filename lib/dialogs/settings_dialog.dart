import 'package:day_planner/configs/app_config.dart';
import 'package:flutter/material.dart';

class SettingsDialog extends StatefulWidget {

  const SettingsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return const SettingsDialog();
      },
    );
  }

  @override
  State<StatefulWidget> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog>{
  double sliderValue = DayPlannerConfig.hourRowSize.toDouble();

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Paramètres'),
      children: <Widget>[
        Column(
          children: [
            Text("Affichage des heures", style: TextStyle(fontSize: DayPlannerConfig.fontSizeS)),
            Slider(
              value: sliderValue,
              min: 60,
              max: 120,
              divisions: 2,
              label: "${sliderValue.round().toString()}px",
              onChanged: (double value) {
                setState(() {
                  sliderValue = value;
                });
              },
            ),
            ElevatedButton(
              onPressed: () {
                if (DayPlannerConfig.hourRowSize != sliderValue) {
                  DayPlannerConfig.hourRowSize = sliderValue.toInt();
                }
                Navigator.pop(context);
              },
              child: const Text("Valider")
            )
          ],
        ),
      ],
    );
  }

}