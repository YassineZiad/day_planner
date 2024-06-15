import 'package:day_planner/dialogs/event_update_dialog.dart';
import 'package:day_planner/repositories/event_repository.dart';
import 'package:flutter/material.dart';

import '../configs/theme_config.dart';
import '../models/event.dart';

class EventDialog {

  Event? event;
  final bool create;
  DateTime day;

  EventDialog({
    this.event,
    required this.create,
    required this.day
  });

  static final _eventFormKey = GlobalKey<FormState>();
  static final TextEditingController _summaryController = TextEditingController();

  String getDialogTitle() {
    return create ? "Créer un évènement" : "Modifier un évènement";
  }

  String loadSummary() {
    return create ? "" : event!.summary;
  }

  static Future<TimeOfDay> showStartTimePicker(BuildContext context, TimeOfDay startT) async {
    TimeOfDay? pickerTime = await showTimePicker(
        context: context,
        helpText: "Début de l'évènement",
        barrierDismissible: false,
        initialTime: startT,
        confirmText: "Confirmer",
        cancelText: "Annuler",
        hourLabelText: "Heure",
        minuteLabelText: "Minute",
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
              child: child!
          );
        }
    );
    return pickerTime ?? startT;
  }

  static Future<TimeOfDay> showEndTimePicker(BuildContext context, TimeOfDay endT) async {
    TimeOfDay? pickerTime = await showTimePicker(
        context: context,
        helpText: "Fin de l'évènement",
        barrierDismissible: false,
        initialTime: endT,
        confirmText: "Confirmer",
        cancelText: "Annuler",
        hourLabelText: "Heure",
        minuteLabelText: "Minute",
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
              child: child!
          );
        }
    );
    return pickerTime ?? endT; //pickerTime == null ? endT : pickerTime
  }

  Future<void> show(BuildContext context) async {
    AlertDialog confirmDelete = AlertDialog(
      title: const Text("Supprimer"),
      content: const Text("Êtes-vous sûr de vouloir supprimer l'évènement ?"),
      icon: const Icon(Icons.delete_forever),
      actions: [
        TextButton(
          child: const Text("Annuler"),
          onPressed:  () => Navigator.pop(context),
        ),
        TextButton(
          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Theme.of(context).extension<Palette>()!.cancelled)),
          child: const Text("Supprimer"),
          onPressed:  () {
            EventRepository.deleteEvent(this.event!);
            Navigator.pop(context);
            Navigator.pop(context);
          },
        )
      ],
    );

    DateTime dt = this.day;
    TimeOfDay? startT = create ? TimeOfDay.now() : TimeOfDay(hour: event!.startDt.hour, minute: event!.startDt.minute);
    TimeOfDay? endT = create ? TimeOfDay.now() : TimeOfDay(hour: event!.endDt.hour, minute: event!.endDt.minute);

    _summaryController.text = loadSummary();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(getDialogTitle()),
          children: <Widget>[
            Form(
              key: _eventFormKey,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Titre'),
                      controller: _summaryController,
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
                          startT = await showStartTimePicker(context, startT!);
                        },
                    ),
                    TextButton.icon(
                        icon: const Icon(Icons.hourglass_bottom),
                        label: const Text("Heure de fin"),
                        onPressed: () async {
                          endT = await showEndTimePicker(context, endT!);
                        }
                    ),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            if (_eventFormKey.currentState!.validate()) {
                              Event e = Event(
                                  summary: _summaryController.text,
                                  startDt: DateTime(dt.year, dt.month, dt.day, startT!.hour, startT!.minute),
                                  endDt: DateTime(dt.year, dt.month, dt.day, endT!.hour, endT!.minute)
                              );

                              bool r;
                              if (create) {
                                r = await EventRepository.createEvent(e);
                              } else {
                                e.id = event!.id;
                                r = await EventRepository.updateEvent(e);
                              }

                              Navigator.pop(context);

                              if (r) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Effectué avec succès !")));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erreur: Un évènement ne peut pas en chevaucher un autre.")));
                              }

                            }
                          },
                          child: const Text('Valider'),
                        ),
                        if (!create)
                          ElevatedButton(
                            onPressed: () async {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return confirmDelete;
                                  }
                              );
                            },
                            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Theme.of(context).extension<Palette>()!.cancelled)),
                            child: const Text('Supprimer')
                          )
                      ],
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