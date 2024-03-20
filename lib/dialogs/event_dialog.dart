import 'package:day_planner/repositories/event_repository.dart';
import 'package:flutter/material.dart';

import '../models/event.dart';

class EventDialog {

  Event? event;
  final bool create;

  EventDialog({
    this.event,
    required this.create
  });

  static final _formKey = GlobalKey<FormState>();
  static TextEditingController summaryController = TextEditingController();

  String getDialogTitle() {
    return create ? "Créer un évènement" : "Modifier un évènement";
  }

  String loadSummary() {
    return create ? "" : event!.summary;
  }

  // static Future<void> newToDoTaskDialogBuilder(BuildContext context) {
  //   return showDialog<void>(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return SimpleDialog(
  //         title: const Text('Ajouter une tâche'),
  //         children: <Widget>[
  //           Switch(
  //             value: false,
  //             activeColor: Colors.blueAccent,
  //             onChanged: (bool value) => b = value
  //           )
  //         ],
  //       );
  //     },
  //   );
  // }

  Future<void> loginDialogBuilder(BuildContext context) {
    DateTime dt = DateTime.now();
    TimeOfDay? startT = TimeOfDay.now();
    TimeOfDay? endT = TimeOfDay.now();

    summaryController.text = loadSummary();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(getDialogTitle()),
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Titre'),
                      controller: summaryController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Saisir un titre';
                        }
                        return null;
                      },
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.hourglass_top),
                      label: const Text("Heure de début"),
                      onPressed: () async {
                          startT = await showTimePicker(
                              context: context,
                              barrierDismissible: false,
                              initialTime: startT!,
                              hourLabelText: "Heure",
                              minuteLabelText: "Minute",
                              initialEntryMode: TimePickerEntryMode.inputOnly,
                              builder: (BuildContext context, Widget? child) {
                                return MediaQuery(
                                    data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                                    child: child!
                                );
                              }
                          );
                        },
                    ),
                    TextButton.icon(
                        icon: const Icon(Icons.hourglass_bottom),
                        label: const Text("Heure de fin"),
                        onPressed: () async {
                          endT = await showTimePicker(
                              context: context,
                              barrierDismissible: false,
                              initialTime: endT!,
                              barrierLabel: "CC",
                              hourLabelText: "Heure",
                              minuteLabelText: "Minute",
                              initialEntryMode: TimePickerEntryMode.inputOnly,
                              builder: (BuildContext context, Widget? child) {
                                return MediaQuery(
                                    data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                                    child: child!
                                );
                              }
                          );
                        }
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          Event e = Event(
                            summary: summaryController.text,
                            startDt: DateTime(dt.year, dt.month, dt.day, startT!.hour, startT!.minute),
                            endDt: DateTime(dt.year, dt.month, dt.day, endT!.hour, endT!.minute)
                          );

                          bool r = await EventRepository.createEvent(e);
                          if (r) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("OK")));
                          }
                        }
                      },
                      child: const Text('Valider'),
                    )
                  ]
              )
            )
          ],
        );
      },
    );
  }

}